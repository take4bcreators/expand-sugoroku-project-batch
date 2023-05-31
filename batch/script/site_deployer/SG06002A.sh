#!/bin/bash

###################################
# サイトデプロイ
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


# デプロイ時のレスポンス保存ファイルの存在確認
if [ ! -f "${TMP_DEPLOY_CURL_RES_LOG}" ]; then
    logmsg ${LL_ERR} "デプロイレスポンスファイルが存在しません" -r
    logmsg ${LL_ERR} "ファイルパス：${TMP_DEPLOY_CURL_RES_LOG}" -r
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi

# 必須変数の存在確認
## ステータス確認時のレスポンス保存ファイル
if [ -z "${TMP_CHECK_STATUS_CURL_RES_LOG}" ]; then
    logmsg ${LL_ERR} "必要な環境変数が設定されていません" -r
    logmsg ${LL_ERR} "対象：TMP_CHECK_STATUS_CURL_RES_LOG" -r
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi
## ステータス確認の最大試行回数
if [ -z "${CHECK_STATUS_MAX_TRY_TIMES}" ]; then
    logmsg ${LL_ERR} "必要な環境変数が設定されていません" -r
    logmsg ${LL_ERR} "対象：CHECK_STATUS_MAX_TRY_TIMES" -r
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi


# 最後に実行したデプロイのデプロイIDを取得
deploy_id=$(jq -r '.id' "${TMP_DEPLOY_CURL_RES_LOG}")
return_code=$?
if [ ${return_code} -ne 0 ] || [ -z "${deploy_id}" ]; then
    logmsg ${LL_ERR} "デプロイID取得エラー" -r
    logmsg ${LL_ERR} "コマンド戻り値：${return_code}" -r
    logmsg ${LL_ERR} "デプロイID：${deploy_id}" -r
    removetmp
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi

# リクエスト情報ログ出力
logmsg ${LL_INFO} "実行リクエスト...
curl -Ss -X GET -H \"Authorization: Bearer XXXXXX\"
                \"https://api.netlify.com/api/v1/deploys/${deploy_id}\"" -o


# 自動リトライのためのループ
logmsg ${LL_INFO} "Netlifyデプロイステータス確認開始 最大試行回数：${CHECK_STATUS_MAX_TRY_TIMES}"
for try_times in $(seq 1 ${CHECK_STATUS_MAX_TRY_TIMES});do
    logmsg ${LL_INFO} "Netlifyデプロイステータス確認 [${try_times}回目]"
    
    # デプロイステータス取得実行
    curl -Ss -X GET -H "Authorization: Bearer ${NL_TOKEN}" \
                    "https://api.netlify.com/api/v1/deploys/${deploy_id}" \
                    | jq . > "${TMP_CHECK_STATUS_CURL_RES_LOG}" 2> "${STD_ERR_FILE}"
    return_code=$?

    # curlのエラーが発生している場合は異常終了
    if [ ${return_code} -ne 0 ] && [ -s ${STD_ERR_FILE} ]; then
        logmsg ${LL_ERR} "Netlify APIリクエスト実行エラー" -r
        logmsg ${LL_ERR} "curlコマンド戻り値：${return_code}" -r
        logmsg ${LL_ERR} "curlコマンド標準出力メッセージ...\n$(cat ${TMP_CHECK_STATUS_CURL_RES_LOG})" -r
        logmsg ${LL_ERR} "curlコマンドエラーメッセージ...\n$(cat ${STD_ERR_FILE})" -r
        removetmp
        logmsg ${LL_ERR} "異常終了"
        exit 1
    fi
    
    # デプロイステータスを取得
    deploy_state=$(jq -r '.state' "${TMP_CHECK_STATUS_CURL_RES_LOG}")
    logmsg ${LL_INFO} "デプロイステータス：${deploy_state}" -o
    case "${deploy_state}" in
        "null" | "")
            logmsg ${LL_ERR} "デプロイステータス取得エラー" -r
            logmsg ${LL_ERR} "デプロイステータス：${deploy_state}" -r
            removetmp
            logmsg ${LL_ERR} "異常終了"
            exit 1
            ;;
        "error")
            logmsg ${LL_ERR} "デプロイエラー" -r
            logmsg ${LL_ERR} "デプロイステータス：${deploy_state}" -r
            removetmp
            logmsg ${LL_ERR} "異常終了"
            exit 1
            ;;
        "ready")
            logmsg ${LL_INFO} "デプロイステータス問題なし"
            break
            ;;
    esac
    
    logmsg ${LL_INFO} "デプロイステータスが ready ではありません"
    
    # 最大リトライ関数に達している場合は、異常終了
    if [ ${try_times} -eq ${CHECK_STATUS_MAX_TRY_TIMES} ]; then
        logmsg ${LL_ERR} "ステータス確認の最大試行回数に達しました" -r
        removetmp
        logmsg ${LL_ERR} "異常終了"
        exit 1
    fi
    
    # リトライ前スリープの実行
    sleepsec="$(( 2 ** (${try_times} - 1) ))"
    logmsg ${LL_INFO} "Netlifyデプロイステータス確認 リトライ前スリープ開始  時間： ${sleepsec} 秒"
    sleep ${sleepsec}
    logmsg ${LL_INFO} "Netlifyデプロイステータス確認 リトライ前スリープ終了"
done


removetmp
logmsg ${LL_INFO} "正常終了"
exit 0
