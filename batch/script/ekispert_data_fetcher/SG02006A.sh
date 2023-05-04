#!/bin/bash

###################################
# 駅すぱあとAPI実行
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


# 既存一時ファイルの削除
logmsg ${LL_INFO} "既存レスポンス格納用一時ファイル削除処理"
file_count=$(ls ${TMP_EKISPERT_RESPONSE_JSONS} 2> /dev/null | wc -l)
if [ "${file_count}" -ne 0 ]; then
    logmsg ${LL_INFO} "ファイル削除前...\n$(ls ${TMP_EKISPERT_RESPONSE_JSONS} 2> /dev/null)"
    logmsg ${LL_INFO} "ファイル削除：${TMP_EKISPERT_RESPONSE_JSONS}"
    rm ${TMP_EKISPERT_RESPONSE_JSONS}
    return_code=$?
    logmsg ${LL_INFO} "ファイル削除後...\n$(ls ${TMP_EKISPERT_RESPONSE_JSONS} 2> /dev/null)"
    if [ ${return_code} -ne 0 ]; then
        logmsg ${LL_ERR} "ファイル削除エラー" -r
        logmsg ${LL_ERR} "rmコマンド戻り値：${return_code}" -r
        removetmp
        logmsg ${LL_ERR} "異常終了"
        exit 1
    fi
    logmsg ${LL_INFO} "既存レスポンス格納用一時ファイル削除処理完了"
else
    logmsg ${LL_INFO} "既存一時ファイルが無いので削除処理をスキップします"
fi


# API実行開始
logmsg ${LL_INFO} "駅すぱあとデータ取得開始"
record_cnt=0
for record in $(cat "${TMP_EKISPERT_REQUEST_CSV}" | sed '/^$/d'); do
    let record_cnt++
    st_name=$(echo "${record}" | awk -F ',' '{print $1}')
    st_code=$(echo "${record}" | awk -F ',' '{print $2}')
    logmsg ${LL_INFO} "レコードカウント：$(printf '%-6s\n' ${record_cnt}) コード：$(printf '%-6s\n' ${st_code}) 駅名：${st_name}" -o
    
    # st_code の有無でパラメータの指定を変更
    uri_param=""
    if [ -z "${st_code}" ]; then
        uri_param="name=${st_name}"
    else
        uri_param="name=${st_name}&code=${st_code}"
    fi
    
    # リクエスト整形
    key_dummy_str="@@@@@@@@"
    request_url="http://api.ekispert.jp/v1/json/station?key=${key_dummy_str}&${uri_param}"
    logmsg ${LL_INFO}  "実行リクエスト：${request_url}"
    request_url=$(echo "${request_url}" | sed "s/${key_dummy_str}/${ES_API_KEY}/")
    
    # 書き出し先一時ファイルの決定
    record_cnt_zero_pad=$(printf '%03d\n' ${record_cnt})
    outfile=$(echo "${TMP_EKISPERT_RESPONSE_JSONS}" | sed "s/${SEQ_FILES_EXT}/${record_cnt_zero_pad}/")
    logmsg ${LL_INFO}  "出力ファイル：${outfile}"
    
    # APIリクエスト実行
    curl -Ss -X GET "${request_url}" > "${STD_OUT_FILE}" 2> "${STD_ERR_FILE}"
    return_code=$?
    
    # エラー判定
    if [ ${return_code} -ne 0 ] || [ -s "${STD_ERR_FILE}" ]; then
        logmsg ${LL_ERR} "curl実行エラー" -r
        logmsg ${LL_ERR} "curlコマンド戻り値：${return_code}" -r
        logmsg ${LL_ERR} "curlコマンド標準出力メッセージ...\n$(cat ${STD_OUT_FILE})" -r
        logmsg ${LL_ERR} "curlコマンドエラーメッセージ...\n$(cat ${STD_ERR_FILE})" -r
        removetmp
        logmsg ${LL_ERR} "異常終了"
        exit 1
    fi
    
    # 最低限の加工をして保存
    cat "${STD_OUT_FILE}" | jq . > "${outfile}" 2> "${STD_ERR_FILE}"
    return_code=$?
    
    # エラー判定
    if [ ${return_code} -ne 0 ] || [ -s "${STD_ERR_FILE}" ]; then
        logmsg ${LL_ERR} "取得ファイル加工エラー" -r
        logmsg ${LL_ERR} "jqコマンド戻り値：${return_code}" -r
        logmsg ${LL_ERR} "jqコマンドエラーメッセージ...\n$(cat ${STD_ERR_FILE})" -r
        removetmp
        logmsg ${LL_ERR} "異常終了"
        exit 1
    fi
done

logmsg ${LL_INFO} "駅すぱあとデータ取得完了"
logmsg ${LL_INFO} "リクエスト実行数：${record_cnt}" -o


removetmp
logmsg ${LL_INFO} "正常終了"
exit 0
