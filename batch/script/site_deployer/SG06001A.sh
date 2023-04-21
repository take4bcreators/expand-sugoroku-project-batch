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


# サイトデータZIPファイルの存在確認
if [ ! -f "${SITE_DATA_ZIP}" ]; then
    logmsg ${LL_ERR} "サイトデータZIPファイルが存在しません"
    logmsg ${LL_ERR} "ファイルパス：${SITE_DATA_ZIP}"
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi

# フラグに応じてデプロイ先のIDを設定する
nl_site_id=""
case ${DEPLOY_TO_PRD_SITE} in
    0)
        echo "デプロイ先：開発サイト"
        logmsg ${LL_INFO} "デプロイ先：開発サイト"
        nl_site_id="${NL_DEV_SITE_ID}"
    ;;
    1)
        echo "デプロイ先：本番サイト"
        logmsg ${LL_INFO} "デプロイ先：本番サイト"
        nl_site_id="${NL_PRD_SITE_ID}"
    ;;
esac
if [ -z "${nl_site_id}" ]; then
    logmsg ${LL_ERR} "サイトIDの設定で想定外のエラーが発生しました"
    logmsg ${LL_ERR} "サイトID：${nl_site_id}"
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi

# 必須変数の存在確認
## デプロイ時のレスポンス保存ファイル
if [ -z "${TMP_DEPLOY_CURL_RES_LOG}" ]; then
    logmsg ${LL_ERR} "必要な環境変数が設定されていません"
    logmsg ${LL_ERR} "対象：TMP_DEPLOY_CURL_RES_LOG"
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi


# サイトデータZIPファイルの格納先へ移動
cd "${SHARED_DIR}"
logmsg ${LL_INFO} "実行ディレクトリ：$(pwd)"

# リクエスト情報ログ出力
logmsg ${LL_INFO} "実行リクエスト...
curl -Ss -X POST -H \"Content-Type: application/zip\"
                 -H \"Authorization: Bearer XXXXXX\"
                 --data-binary \"@${SITE_DATA_ZIP_NAME}\"
                 \"https://api.netlify.com/api/v1/sites/${nl_site_id}/deploys\""

# デプロイ実行
curl -Ss -X POST -H "Content-Type: application/zip" \
                 -H "Authorization: Bearer ${NL_TOKEN}" \
                 --data-binary "@${SITE_DATA_ZIP_NAME}" \
                 "https://api.netlify.com/api/v1/sites/${nl_site_id}/deploys" \
                 | jq . > "${TMP_DEPLOY_CURL_RES_LOG}" 2> "${STD_ERR_FILE}"
return_code=$?

# curlのエラーが発生している場合は異常終了
if [ ${return_code} -ne 0 ] && [ -s ${STD_ERR_FILE} ]; then
    logmsg ${LL_ERR} "Netlify APIリクエスト実行エラー"
    logmsg ${LL_ERR} "curlコマンド戻り値：${return_code}"
    logmsg ${LL_ERR} "curlコマンド標準出力メッセージ...\n$(cat ${TMP_DEPLOY_CURL_RES_LOG})"
    logmsg ${LL_ERR} "curlコマンドエラーメッセージ...\n$(cat ${STD_ERR_FILE})"
    removetmp
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi


# レスポンス取得
dep_res_name=$(cat ${TMP_DEPLOY_CURL_RES_LOG} | jq -r '.name')
dep_res_url=$(cat ${TMP_DEPLOY_CURL_RES_LOG} | jq -r '.ssl_url')
dep_res_status=$(cat ${TMP_DEPLOY_CURL_RES_LOG} | jq -r '.state')
dep_res_deployid=$(cat ${TMP_DEPLOY_CURL_RES_LOG} | jq -r '.id')
dep_res_createdat=$(cat ${TMP_DEPLOY_CURL_RES_LOG} | jq -r '.created_at')
dep_res_updatedat=$(cat ${TMP_DEPLOY_CURL_RES_LOG} | jq -r '.updated_at')
dep_res_adminurl=$(cat ${TMP_DEPLOY_CURL_RES_LOG} | jq -r '.admin_url')
dep_res_errmsg=$(cat ${TMP_DEPLOY_CURL_RES_LOG} | jq -r '.error_message')

# レスポンスデータ内の時間情報変換
dep_res_createdat_jst=$(date +"%Y年%m月%d日 %H:%M:%S" -d "${dep_res_createdat}")
dep_res_updatedat_jst=$(date +"%Y年%m月%d日 %H:%M:%S" -d "${dep_res_updatedat}")

# サイトステータスレポート組み立て
site_status="
【サイトステータスレポート】
    ■ サイト名           ： ${dep_res_name}
    ■ サイトURL          ： ${dep_res_url}
    ■ ステータス         ： ${dep_res_status}
    ■ デプロイID         ： ${dep_res_deployid}
    ■ 作成日             ： ${dep_res_createdat_jst}
    ■ 更新日             ： ${dep_res_updatedat_jst}
    ■ 管理画面URL        ： ${dep_res_adminurl}
    ■ エラーメッセージ   ： ${dep_res_errmsg}
"

# ログ出力
echo "${site_status}"
logmsg ${LL_INFO} "デプロイ情報...${site_status}"

# レスポンスのステータスの文言で成功判定
if [ "${dep_res_status}" != "uploaded" ]; then
    logmsg ${LL_ERR} "デプロイステータスが uploaded ではありません"
    logmsg ${LL_ERR} "デプロイステータス：${dep_res_status}"
    removetmp
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi

# 出力確認用ファイルの削除
removetmp

logmsg ${LL_INFO} "正常終了"
exit 0
