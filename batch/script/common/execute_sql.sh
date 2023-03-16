#!/bin/bash

###########################################
# 【共通SQL実行処理】
#   [引数1] 機能グループ名
#   [引数2] 呼び出し元ファイル名
#   [引数3] 実行SQLファイル名
#   [実行例] execute_sql.sh "importconf" "SGTS0001.sh" "sgts0001.sql"
###########################################


### 実行条件チェック ######################
# 引数チェック
check_count=3
if [ $# -ne ${check_count} ]; then
    echo "ERROR 引数の数が正しくありません"
    echo "想定：${check_count}  実際：$#"
    exit 1
fi

# 機能グループ名
module_group_name=$1
# 呼び出し元シェルスクリプトの名前
exec_shell_name=$2
# 実行SQLの名前
exec_sql_name=$3

# このプロジェクトのトップディレクトリのパス（.bash_profile で定義済み）
PROJECT_BATCH_ROOT="${PROJECT_BATCH_ROOT}"
if [ -z "${PROJECT_BATCH_ROOT}" ]; then
    echo "ERROR 必要な変数が設定されていません"
    echo "対象：PROJECT_BATCH_ROOT"
    exit 1
fi


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
# shellcheck source=./common_function.sh
source "${COMMON_LIB_SH}" "${exec_shell_name}" "${LOG_DIR}" "${module_group_name}"

# 認証情報読み込みファイルの存在チェックと読み込み
# if [ ! -f "${DOT_ENV}" ]; then
#     echo "ERROR 必要なファイルが存在しません"
#     echo '対象：${DOT_ENV}'
#     echo "実際：${DOT_ENV}"
#     exit 1
# fi
# source "${DOT_ENV}"


### メイン処理 ##########################
logmsg ${LL_INFO} "実行開始"
dumpinfo

# SQLファイルのフルパス
exec_sql_file_path="${SQL_DIR}/${module_group_name}/${exec_sql_name}"
# SQLファイル存在チェック
if [ ! -f ${exec_sql_file_path} ]; then
    logmsg ${LL_ERR} "ERROR 実行SQLファイルが存在しません"
    logmsg ${LL_ERR} "指定されたファイル名：${exec_sql_file_path}"
    exit 1
fi

# SQL実行
psql -d "${DB_NAME}" -U "${DB_USER}" -f "${exec_sql_file_path}" --set ON_ERROR_STOP=on ${DB_BIND} > "${STD_OUT_FILE}" 2> "${STD_ERR_FILE}"
# PSQLからの戻り値
psql_return_code=$?

# 標準出力をログへ出力
if [ -s ${STD_OUT_FILE} ]; then
    logmsg ${LL_INFO} "PSQL標準出力メッセージ...\n""$(cat ${STD_OUT_FILE})"
else
    logmsg ${LL_INFO} "PSQL標準出力メッセージ なし"
fi
# エラー出力をログとコンソールへ出力
if [ -s ${STD_ERR_FILE} ]; then
    logmsg ${LL_INFO} "PSQLエラー出力メッセージ...\n""$(cat ${STD_ERR_FILE})"
    cat ${STD_ERR_FILE}
fi

# 出力確認用ファイルの削除
removetmp

# SQLエラーチェック
if [ ${psql_return_code} -ne 0 ]; then
    logmsg ${LL_ERR} "PSQLエラー 戻り値：${psql_return_code}"
    logmsg ${LL_ERR} "異常終了"
    exit ${psql_return_code}
fi

logmsg ${LL_INFO} "正常終了"
exit 0
