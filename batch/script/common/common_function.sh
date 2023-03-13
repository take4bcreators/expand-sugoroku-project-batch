#!/bin/bash

# 共通モジュール

# ログ関連の出力指定
readonly ERR="ERROR"
readonly WARN="WARN"
readonly INFO="INFO"
readonly DEBUG="DEBUG"
readonly sep="\t"

# 引数読み込み
if [ $# != 1 ]; then
    echo "ERROR 引数の数が正しくありません"
    exit 1
fi
exec_shell_name=$1

# 必須変数存在確認
if [ -z "${TMP_DIR}" ]; then
    echo "ERROR 必須の変数が設定されていません"
    echo "設定されていない変数：TMP_DIR"
    exit 1
fi

if [ -z "${LOG_DIR}" ]; then
    echo "ERROR 必須の変数が設定されていません"
    echo "設定されていない変数：LOG_DIR"
    exit 1
fi

if [ -z "${MOD_GRP_NAME}" ]; then
    echo "ERROR 必須の変数が設定されていません"
    echo "設定されていない変数：MOD_GRP_NAME"
    exit 1
fi

# 出力ファイル設定
STD_OUT_FILE="${TMP_DIR}/std_out_$$.tmp"
STD_ERR_FILE="${TMP_DIR}/std_err_$$.tmp"
# LOG_FILE_NAME="${LOG_DIR}/${MOD_GRP_NAME}/${MOD_GRP_NAME}_$(date +%Y%m%d).log"
LOG_FILE_NAME="${LOG_DIR}/${MOD_GRP_NAME}_$(date +%Y%m%d).log"


# 【ログ出力用関数】
#   [引数1] 重要度を示す変数
#   [引数2] ログに出力するメッセージ
#   [使用例] log_msg $INFO "実行開始"
#   [ログ出力例] 2022-01-01 10:01:36 INFO pid:3001 import_mst_prefectures_csv.sh 実行開始
function log_msg() {
    local logdata="$(date '+%Y-%m-%d %H:%M:%S')"
    local pri=$1
    local pid=$$
    local shlname=${exec_shell_name}
    local logmsg=$2
    
    echo -e "${logdata}${sep}${pri}${sep}pid:${pid}${sep}${shlname}${sep}${logmsg}"
    
} >> ${LOG_FILE_NAME}


# 【標準出力ファイルの削除関数】
#   [引数] なし
#   [使用例] delete_std_out_file
function delete_std_out_file() {
    if [ -f ${STD_OUT_FILE} ]; then
        rm ${STD_OUT_FILE}
    fi
    if [ -f ${STD_ERR_FILE} ]; then
        rm ${STD_ERR_FILE}
    fi
}

