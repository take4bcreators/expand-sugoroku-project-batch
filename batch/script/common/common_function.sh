#!/bin/bash

###########################################
# 【共通モジュール】
#   [引数1] 呼び出し元のシェルスクリプトの名前
#   [引数2] 一時ファイル用ディレクトリ
#   [引数3] ログ用ディレクトリ
#   [引数4] 機能グループ名
#   [実行例] common_function.sh "SGTS0001.sh" "/tmp" "/log" "test"
###########################################


# ログレベル エラー
readonly ERR="ERROR"
# ログレベル 警告
readonly WARN="WARN"
# ログレベル 情報
readonly INFO="INFO"
# ログレベル デバッグ
readonly DEBUG="DEBUG"
# ログのセパレーター
readonly sep="\t"


# 引数読み込み
check_count=4
if [ $# != ${check_count} ]; then
    echo "ERROR 引数の数が正しくありません"
    echo "想定：${check_count}  実際：$#"
    exit 1
fi

# 呼び出し元のシェルスクリプトの名前
local_exec_shell_name=$1
# 一時ファイル用ディレクトリ
local_tmp_dir=$2
# ログ用ディレクトリ
local_log_dir=$3
# 機能グループ名
local_module_group_name=$4
# 標準出力用の一時ファイル
STD_OUT_FILE="${local_tmp_dir}/std_out_$$.tmp"
# エラー出力用の一時ファイル
STD_ERR_FILE="${local_tmp_dir}/std_err_$$.tmp"
# ログファイルのパス（形式：機能名_日付.log）
LOG_FILE_NAME="${local_log_dir}/${local_module_group_name}_$(date +%Y%m%d).log"


# 【ログ出力用関数】
#   [引数1] 重要度を示す変数 … ${ERR} ${WARN} ${INFO} ${DEBUG}
#   [引数2] ログに出力するメッセージ
#   [使用例] logmsg ${INFO} "実行開始"
#   [ログ出力例] 2022-01-01 10:01:36 INFO pid:3001 SGTS0001.sh 実行開始
function logmsg() {
    local _logdate="$(date '+%Y-%m-%d %H:%M:%S')"
    local _pri=$1
    local _pid=$$
    local _shlname="${local_exec_shell_name}"
    local _logmessage=$2
    echo -e "${_logdate}${sep}${_pri}${sep}pid:${_pid}${sep}${_shlname}${sep}${_logmessage}"
} >> ${LOG_FILE_NAME}


# 【標準出力ファイルの削除関数】
#   [引数] なし
#   [使用例] removetmp
function removetmp() {
    if [ -f "${STD_OUT_FILE}" ]; then
        rm "${STD_OUT_FILE}"
    fi
    if [ -f "${STD_ERR_FILE}" ]; then
        rm "${STD_ERR_FILE}"
    fi
}

