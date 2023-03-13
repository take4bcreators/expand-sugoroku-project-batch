#!/bin/bash

###################################
# SGTS0001
# 指定したSQLを実行する
###################################

# 実行するシェルスクリプトの名前
exec_shell_name="execute_sql.sh"

# 機能別設定ファイル名（実行するシェル側で読み込む）
grp_env_file_name="grp_env_test.sh"

# 実行SQLファイル名
exec_sql_file_name="SGTS0002.sql"


# このシェルスクリプトの名前
this_shell_name=$(basename $0)

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

# 実行するシェルスクリプトのフルパス
exec_shell="${COM_SHELL_DIR}/${exec_shell_name}"


# シェルスクリプト実行
#  execute_sql.sh 機能別設定ファイル名 このシェルのファイル名 実行SQLファイル名
"${exec_shell}" "${grp_env_file_name}" "${this_shell_name}" "${exec_sql_file_name}"

exit $?
