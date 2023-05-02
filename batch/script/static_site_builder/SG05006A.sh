#!/bin/bash

###################################
# 静的サイトデータZIP作成
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


# ZIP化対象のディレクトリの存在確認
if [ ! -d "${GATSBY_PUBLIC_DIR}" ]; then
    logmsg ${LL_ERR} "コピー元ディレクトリが存在しません" -r
    logmsg ${LL_ERR} "コピー元ディレクトリ：${GATSBY_PUBLIC_DIR}" -r
    removetmp
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi

# 既存のZIPの存在確認と削除
if [ -f "${SITE_DATA_ZIP}" ]; then
    logmsg ${LL_INFO} "既存のZIPファイルを削除します" -o
    logmsg ${LL_INFO} "既存対象：${SITE_DATA_ZIP}" -o
    rm "${SITE_DATA_ZIP}" > "${STD_OUT_FILE}" 2> "${STD_ERR_FILE}"
    return_code=$?
    if [ ${return_code} -ne 0 ]; then
        logmsg ${LL_ERR} "既存ZIP削除エラー" -r
        logmsg ${LL_ERR} "rmコマンド戻り値：${status}" -r
        logmsg ${LL_ERR} "rmコマンド標準出力メッセージ...\n$(cat ${STD_OUT_FILE})" -r
        logmsg ${LL_ERR} "rmコマンドエラーメッセージ...\n$(cat ${STD_ERR_FILE})" -r
        removetmp
        logmsg ${LL_ERR} "異常終了"
        exit 1
    fi
    logmsg ${LL_INFO} "既存のZIPファイル削除完了" -o
fi

# ディレクトリを移動
cd "${EXEC_GATSBY_DIR}"
logmsg ${LL_INFO} "実行ディレクトリ：$(pwd)" -o

# ZIP化実行
# （書式）zip ZIP化後ファイル名 -r 対象ディレクトリ
# zip内の階層を浅くするため、対象ディレクトリは 相対パス で指定
logmsg ${LL_INFO} "zipコマンド実行" -o
zip "${SITE_DATA_ZIP}" -r "${GATSBY_PUBLIC_DIR_NAME}" > "${STD_OUT_FILE}" 2> "${STD_ERR_FILE}"
return_code=$?

# エラー判定
if [ ${return_code} -ne 0 ]; then
    logmsg ${LL_ERR} "zipコマンド実行エラー"
    logmsg ${LL_ERR} "zipコマンド戻り値：${return_code}" -r
    logmsg ${LL_ERR} "zipコマンド標準出力メッセージ...\n$(cat ${STD_OUT_FILE})" -r
    logmsg ${LL_ERR} "zipコマンドエラーメッセージ...\n$(cat ${STD_ERR_FILE})" -r
    removetmp
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi

# メッセージ出力
logmsg ${LL_INFO} "zipコマンド終了" -o
logmsg ${LL_INFO} "zipコマンド標準出力メッセージ...\n$(cat ${STD_OUT_FILE})" -o
logmsg ${LL_INFO} "zipコマンドエラーメッセージ...\n$(cat ${STD_ERR_FILE})" -o
logmsg ${LL_INFO} "コピー元ディレクトリ：${GATSBY_PUBLIC_DIR}" -o
logmsg ${LL_INFO} "作成ZIPファイルのパス：${SITE_DATA_ZIP}" -o


removetmp
logmsg ${LL_INFO} "正常終了"
exit 0
