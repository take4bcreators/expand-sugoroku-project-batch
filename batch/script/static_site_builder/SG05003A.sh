#!/bin/bash

###################################
# ミニゲームJSONコピー
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

# コピー元デファイルの存在確認
if [ ! -f "${MINIGAMES_JSON}" ]; then
    logmsg ${LL_ERR} "コピー元ファイルが存在しません" -r
    logmsg ${LL_ERR} "コピー元ファイル：${MINIGAMES_JSON}" -r
    removetmp
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi

# コピー先ディレクトリの存在確認
if [ ! -d "${FRONT_SAVE_JSON_DIR}" ]; then
    logmsg ${LL_ERR} "コピー先ディレクトリが存在しません" -r
    logmsg ${LL_ERR} "コピー先ディレクトリ：${FRONT_SAVE_JSON_DIR}" -r
    removetmp
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi

# JSONファイルコピー
logmsg ${LL_INFO} "コピー元ファイル：${MINIGAMES_JSON}" -r
logmsg ${LL_INFO} "コピー先ディレクトリ：${FRONT_SAVE_JSON_DIR}" -r
cp -f "${MINIGAMES_JSON}" "${FRONT_SAVE_JSON_DIR}/" > "${STD_OUT_FILE}" 2> "${STD_ERR_FILE}"
return_code=$?

# エラー判定
if [ ${return_code} -ne 0 ] || [ -s ${STD_ERR_FILE} ]; then
    logmsg ${LL_ERR} "JSONファイルコピーエラー" -r
    logmsg ${LL_ERR} "cpコマンド戻り値：${return_code}" -r
    logmsg ${LL_ERR} "cpコマンド標準出力メッセージ...\n$(cat ${STD_OUT_FILE})" -r
    logmsg ${LL_ERR} "cpコマンドエラーメッセージ...\n$(cat ${STD_ERR_FILE})" -r
    removetmp
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi

# メッセージ出力
logmsg ${LL_INFO} "cpコマンド標準出力メッセージ...\n$(cat ${STD_OUT_FILE})" -o


removetmp
logmsg ${LL_INFO} "正常終了"
exit 0
