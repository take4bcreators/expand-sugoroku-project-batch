#!/bin/bash

###################################
# 駅すぱあとAPI実行
###################################


# このシェルスクリプトが所属する機能グループ名
# （このシェルの親ディレクトリ名を格納）
module_group_name=$(cd $(dirname $0); basename $(pwd))

# 処理名
# （このシェルスクリプトの名前を拡張子なしで格納）
this_process_name=$(basename $0 .sh)

# このプロジェクトのトップディレクトリのパス（.bash_profile で定義済み）
PROJECT_BATCH_ROOT="${PROJECT_BATCH_ROOT}"
# 共通設定読み込みファイルの存在チェックと読み込み
if [ -z "${PROJECT_BATCH_ROOT}" ]; then
    echo "ERROR 環境変数 PROJECT_BATCH_ROOT が設定されていません"
    exit 1
fi
if [ ! -f "${PROJECT_BATCH_ROOT}/config/common_env.sh" ]; then
    echo "ERROR 共通設定読み込みファイルが存在しません"
    exit 1
fi
# shellcheck source=../../../config/common_env.sh
source "${PROJECT_BATCH_ROOT}/config/common_env.sh"


### 共通設定読み込み ######################
# 共通設定読み込み
if [ ! -f "${PROJECT_BATCH_ROOT}/config/common_env.sh" ]; then
    echo "ERROR 必要なファイルが存在しません"
    echo '対象：${PROJECT_BATCH_ROOT}/config/common_env.sh'
    echo "実際：${PROJECT_BATCH_ROOT}/config/common_env.sh"
    exit 1
fi
# shellcheck source=../../../config/common_env.sh
source "${PROJECT_BATCH_ROOT}/config/common_env.sh"

# 共通モジュール読み込み
if [ -z "${COMMON_LIB_SH}" ]; then
    echo "ERROR 必要な変数が設定されていません"
    echo "対象：COMMON_LIB_SH"
    exit 1
fi
if [ ! -f "${COMMON_LIB_SH}" ]; then
    echo "ERROR 必要なファイルが存在しません"
    echo '対象：${COMMON_LIB_SH}'
    echo "実際：${COMMON_LIB_SH}"
    exit 1
fi
# shellcheck source=../common/common_function.sh
source "${COMMON_LIB_SH}" "${this_process_name}.sh" "${LOG_DIR}" "${module_group_name}"

# 認証情報読み込みファイルの存在チェックと読み込み
if [ ! -f "${APP_ENV}" ]; then
    echo "ERROR 必要なファイルが存在しません"
    echo '対象：${APP_ENV}'
    echo "実際：${APP_ENV}"
    exit 1
fi
# shellcheck source=../../../env/app.env
source "${APP_ENV}"


### メイン処理 ##########################
logmsg ${LL_INFO} "実行開始"
dumpinfo


# レスポンス集約用CSVファイルの初期化
: > "${TMP_EKISPERT_RESPONSE_JOIN_CSV}"
return_code=$?
if [ ${return_code} -ne 0 ]; then
    logmsg ${LL_ERR} "レスポンス集約用CSVの初期化でエラーが発生しました"
    logmsg ${LL_ERR} "「:」コマンドリダイレクト戻り値：${status}"
    logmsg ${LL_ERR} "CSVファイルパス：${TMP_EKISPERT_RESPONSE_JOIN_CSV}"
    exit 1
fi


# レスポンスデータ集約実行
logmsg ${LL_INFO} "レスポンスデータ集約実行"
response_files=$(echo "${TMP_EKISPERT_RESPONSE_JSON}" | sed "s/${SEQ_DUMMY_STR}/${SEQ_DUMMY_STR_FOR_SEARCH}/")
file_count=$(ls ${response_files} 2> /dev/null | wc -l)
if [ "${file_count}" -gt 0 ]; then
    for index in $(seq 1 "${file_count}"); do
        # 対象駅名
        station_name=$(sed -n ${index}p "${TMP_EKISPERT_REQUEST_CSV}" | awk -F ',' '{print $1}')
        # 対象の駅名に対応するレスポンスJSONファイルのパス
        responsefile=$(ls ${response_files} | sed -n ${index}p)
        logmsg ${LL_INFO} "集約対象：${station_name}"
        
        # jqクエリ分岐、スキップのためにデータ件数を取得して分岐
        response_data_cnt=$(cat "${responsefile}" | jq -r '.ResultSet.max')
        jq_query=""
        if [ "${response_data_cnt}" -eq 0 ]; then
            logmsg ${LL_WARN} "レスポンスデータがありません。スキップします"
            continue
        elif [ "${response_data_cnt}" -eq 1 ]; then
            jq_query='.ResultSet.Point.GeoPoint | [.lati_d, .longi_d] | @csv'
        else
            jq_query='.ResultSet.Point[0].GeoPoint | [.lati_d, .longi_d] | @csv'
        fi
        
        # 集約実行
        : > "${STD_ERR_FILE}"
        cat "${responsefile}"                                                               2>> "${STD_ERR_FILE}" \
            | jq -r "${jq_query}"                                                           2>> "${STD_ERR_FILE}" \
            | sed 's/"//g'                                                                  2>> "${STD_ERR_FILE}" \
            | awk -v stationname="${station_name}" 'BEGIN{OFS=","}{print stationname, $0}'  2>> "${STD_ERR_FILE}" \
            >> "${TMP_EKISPERT_RESPONSE_JOIN_CSV}"
        return_codes=(${PIPESTATUS[@]})
        total_return_code=$(echo "${return_codes[@]}" | awk '{for(i=1;i<=NF;i++){sum+=$i}}END{print sum}')
        
        # エラー判定
        if [ ${total_return_code} -ne 0 ] || [ -s "${STD_ERR_FILE}" ]; then
            logmsg ${LL_ERR} "集約処理実行エラー"
            logmsg ${LL_ERR} "catコマンド戻り値：${return_codes[0]}"
            logmsg ${LL_ERR} " jqコマンド戻り値：${return_codes[1]}"
            logmsg ${LL_ERR} "sedコマンド戻り値：${return_codes[2]}"
            logmsg ${LL_ERR} "awkコマンド戻り値：${return_codes[3]}"
            logmsg ${LL_ERR} "コマンドエラーメッセージ...\n$(cat ${STD_ERR_FILE})"
            removetmp
            logmsg ${LL_ERR} "異常終了"
            exit 1
        fi
    done
    logmsg ${LL_INFO} "レスポンスデータ集約完了"
else
    logmsg ${LL_WARN} "駅すぱあとAPIレスポンス一時JSONファイルがありませんでした"
fi


# 出力確認用ファイルの削除
removetmp

logmsg ${LL_INFO} "正常終了"
exit 0
