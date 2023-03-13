#!/bin/bash

###########################################
# 共通SQL実行処理
# 
# 引数
#   1. 機能別設定ファイル名
#   2. 呼び出し元ファイル名
#   3. 実行SQLファイル名
# 例
#   execute_sql.sh grp_env_test.sh SGPJTS01.sh sgpj01.sql
###########################################


### 実行条件チェック ######################

# 環境変数 PROJECT_BATCH_ROOT は .bash_profile で定義済み
if [ -z "${PROJECT_BATCH_ROOT}" ]; then
    echo "ERROR 環境変数 PROJECT_BATCH_ROOT が設定されていません"
    exit 1
fi

# COMMON_LIB_SH は呼び出し元のシェル側で定義済み
if [ -z "${COMMON_LIB_SH}" ]; then
    echo "ERROR 環境変数 COMMON_LIB_SH が設定されていません"
    exit 1
fi

# 引数チェック
if [ $# -ne 3 ]; then
    echo "ERROR 引数の数が正しくありません"
    exit 1
fi


### 共通設定読み込み ######################

# 機能別設定ファイルのフルパス
grp_env_file_path="${CONFIG_DIR}/$1"
# 機能別設定読み込みファイルの存在チェックと読み込み
if [ ! -f "${grp_env_file_path}" ]; then
    echo "ERROR 機能別設定読み込みファイルが存在しません"
    exit 1
fi
# shellcheck source=../../../config/grp_env_test.sh
source "${grp_env_file_path}"


# 実行シェルスクリプトの名前
exec_shell_name=$2
# 共通モジュール読み込みファイルの存在チェックと読み込み
if [ ! -f ${COMMON_LIB_SH} ]; then
    echo "ERROR 共通モジュール読み込みファイルが存在しません"
    exit 1
fi
# shellcheck source=./common_function.sh
source "${COMMON_LIB_SH}" "${exec_shell_name}"


# 認証情報読み込みファイルの存在チェックと読み込み
# if [ ! -f ${DOT_ENV} ]; then
#     echo "ERROR 認証情報読み込みファイルが存在しません"
#     exit 1
# fi
# source ${DOT_ENV}


### メイン処理 ##########################
log_msg ${INFO} "実行開始"

# SQLファイルのフルパス
exec_sql_file_path="${SQL_DIR}/$3"
# SQLファイル存在チェック
if [ ! -f ${exec_sql_file_path} ]; then
    log_msg ${ERR} "ERROR 実行SQLファイルが存在しません"
    log_msg ${ERR} "指定されたファイル名：${exec_sql_file_path}"
    exit 1
fi

# SQL実行
psql -d "${DB_NAME}" -f "${exec_sql_file_path}" --set ON_ERROR_STOP=on ${DB_BIND} > "${STD_OUT_FILE}" 2> "${STD_ERR_FILE}"
# PSQLからの戻り値
psql_return_code=$?

# 標準出力をログへ出力
if [ -s ${STD_OUT_FILE} ]; then
    log_msg ${INFO} "PSQL標準出力メッセージ...\n""$(cat ${STD_OUT_FILE})"
else
    log_msg ${INFO} "PSQL標準出力メッセージ なし"
fi
# エラー出力をログへ出力
if [ -s ${STD_ERR_FILE} ]; then
    log_msg ${INFO} "PSQLエラー出力メッセージ...\n""$(cat ${STD_ERR_FILE})"
fi

# 出力確認用ファイルの削除
delete_std_out_file

# SQLエラーチェック
if [ ${psql_return_code} -ne 0 ]; then
    log_msg ${ERR} "PSQLエラー 戻り値：${psql_return_code}"
    log_msg ${ERR} "異常終了"
    exit ${psql_return_code}
fi

log_msg ${INFO} "正常終了"
exit 0
