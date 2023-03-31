#!/bin/bash

###################################
# ホットペッパーAPIレスポンス集約
###################################


# このシェルスクリプトのパス
# Rundeck からの実行であるか場合は オプション「ORIGINAL_FILE_PATH」で渡されたフルパスにする
shellscript_path=$0
if [ ! -z "${RD_OPTION_ORIGINAL_FILE_PATH}" ]; then
    shellscript_path="${RD_OPTION_ORIGINAL_FILE_PATH}"
fi

# このシェルスクリプトが所属する機能グループ名
# （このシェルの親ディレクトリ名を格納）
module_group_name=$(cd $(dirname "${shellscript_path}"); basename $(pwd))

# 処理名
# （このシェルスクリプトの名前を拡張子なしで格納）
this_process_name=$(basename "${shellscript_path}" .sh)

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
: > "${TMP_HOTPEPPER_RESPONSE_JOIN_CSV}"
return_code=$?
if [ ${return_code} -ne 0 ]; then
    logmsg ${LL_ERR} "レスポンス集約用CSVの初期化でエラーが発生しました"
    logmsg ${LL_ERR} "「:」コマンドリダイレクト戻り値：${status}"
    logmsg ${LL_ERR} "CSVファイルパス：${TMP_HOTPEPPER_RESPONSE_JOIN_CSV}"
    exit 1
fi


# レスポンスデータ集約実行
logmsg ${LL_INFO} "レスポンスデータ集約実行"
file_count=$(ls ${TMP_HOTPEPPER_RESPONSE_JSONS} 2> /dev/null | wc -l)
if [ "${file_count}" -gt 0 ]; then
    for index in $(seq 1 "${file_count}"); do
        # 対象駅名
        station_name=$(sed -n ${index}p "${TMP_HOTPEPPER_REQUEST_CSV}" | awk -F ',' '{print $1}')
        store_type=$(sed -n ${index}p "${TMP_HOTPEPPER_REQUEST_CSV}" | awk -F ',' '{print $2}')
        # 対象の駅名に対応するレスポンスJSONファイルのパス
        responsefile=$(ls ${TMP_HOTPEPPER_RESPONSE_JSONS} | sed -n ${index}p)
        logmsg ${LL_INFO} "集約対象 … 店タイプ：$(printf '%-16s\n' ${store_type}) 駅名：${station_name}"
        
        
        # jqクエリ分岐とスキップのためにデータ件数を取得して分岐
        response_data_cnt=$(cat "${responsefile}" | jq -r '.results.results_returned')
        jq_query=""
        # 0件、該当キーがない場合はスキップ
        if [ "${response_data_cnt}" = "0" ] || [ "${response_data_cnt}" = "null" ]; then
            logmsg ${LL_WARN} "レスポンスデータがありません。スキップします"
            continue
        fi
        # 結果件数が数値でない場合もスキップ（そのようなデータがあるかは未確認）
        if [[ ! "${response_data_cnt}" =~ ^[0-9]+$ ]]; then
            logmsg ${LL_WARN} "レスポンスデータ件数が数値ではありません。スキップします"
            continue
        fi
        
        # 1データずつ格納
        let response_data_cnt--
        for data_index in $(seq 0 "${response_data_cnt}"); do
            # 実行クエリ作成
            # @note 取得項目に変更がある場合は、ここの指定を変更する
            jq_query=".results.shop[${data_index}] | [.name, .id, .access, .address, .open, .photo.pc.l] | @tsv"
            
            # 集約実行
            : > "${STD_ERR_FILE}"
            cat "${responsefile}"                                                                                                       2>> "${STD_ERR_FILE}" \
                | jq -r "${jq_query}"                                                                                                   2>> "${STD_ERR_FILE}" \
                | sed 's/"//g'                                                                                                          2>> "${STD_ERR_FILE}" \
                | awk -v stationname="${station_name}" -v storetype="${store_type}" 'BEGIN{OFS="\t"}{print stationname, storetype, $0}' 2>> "${STD_ERR_FILE}" \
                >> "${TMP_HOTPEPPER_RESPONSE_JOIN_CSV}"
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
    done
    logmsg ${LL_INFO} "レスポンスデータ集約完了"
else
    logmsg ${LL_WARN} "ホットペッパーAPIレスポンス一時JSONファイルがありませんでした"
fi


# 出力確認用ファイルの削除
removetmp

logmsg ${LL_INFO} "正常終了"
exit 0
