#!/bin/bash

###########################################
# 【共通モジュール】
#   [引数1] 呼び出し元のシェルスクリプトの名前
#   [引数2] 一時ファイル用ディレクトリ
#   [引数3] ログ用ディレクトリ
#   [引数4] 機能グループ名
#   [実行例] common_function.sh "SGTS0001.sh" "/log" "test"
###########################################


# ログレベル エラー
readonly LL_ERR="ERROR"
# ログレベル 警告
readonly LL_WARN="WARN"
# ログレベル 情報
readonly LL_INFO="INFO"
# ログレベル デバッグ
readonly LL_DEBUG="DEBUG"
# ログのセパレーター
readonly sep="\t"


# 引数読み込み
check_count=3
if [ $# != ${check_count} ]; then
    echo "ERROR 引数の数が正しくありません"
    echo "想定：${check_count}  実際：$#"
    exit 1
fi

# 呼び出し元のシェルスクリプトの名前
local_exec_shell_name=$1
# ログ用ディレクトリ
local_log_dir=$2
# 機能グループ名
local_module_group_name=$3
# 標準出力用の一時ファイル
STD_OUT_FILE="$(mktemp)"
# エラー出力用の一時ファイル
STD_ERR_FILE="$(mktemp)"
# ログファイルのパス（形式：機能名_日付.log）
LOG_FILE_NAME="${local_log_dir}/${local_module_group_name}_$(date +%Y%m%d).log"


# 【ログ出力用関数】
#   [引数1] 重要度を示す変数 … ${LL_ERR} ${LL_WARN} ${LL_INFO} ${LL_DEBUG}
#   [引数2] ログに出力するメッセージ
#   [オプション]
#           -o, --out       : 標準出力にも出力する
#           -r, --errout    : エラー出力にも出力する
#           -f, --full      : -o または -r 指定時、
#                             出力するメッセージにタイムスタンプなども含める
#   [使用例]
#           logmsg ${LL_INFO} "実行開始"
#           logmsg ${LL_ERR} "エラー" -r
#   [ログ出力例]
#           2022-01-01 10:01:36 INFO  pid:3001 SGTS0001.sh 実行開始
#           2022-01-01 10:01:36 ERROR pid:3001 SGTS0001.sh エラー
function logmsg() {
    # 標準出力・エラー出力判定用変数
    local _use_std_out=false
    local _use_err_out=false
    local _full_out=false
    
    # 使用可能なオプションを指定
    local _SHORTOPTS="orf"
    local _LONGOPTS="out,errout,full"
    
    # オプション解析
    # 引数解析時に awk を使用するため、引数内の改行は一旦 \n の文字列に変換してからオプション解析する
    local _optargs=$(getopt -o "${_SHORTOPTS}" -l "${_LONGOPTS}" -- "$@")
    _optargs=$(echo ${_optargs//$'\n'/'\n'})
    for _optarg in ${_optargs}; do
        case ${_optarg} in
            -o|--out)
                _use_std_out=true
                ;;
            -r|--errout)
                _use_err_out=true
                ;;
            -f|--full)
                _full_out=true
                ;;
            --)
                break
                ;;
        esac
    done
    
    # 引数を引数番号で解析
    argnums=(0)
    argnum=0
    for arg in "$@"; do
        let argnum++
        case "${arg}" in
            -*) : ;;
            *)  argnums+=(${argnum}) ;;
        esac
    done
    
    # ログ出力のための情報を設定
    local _logdate="$(date '+%Y-%m-%d %H:%M:%S')"
    local _pri="${!argnums[1]}"
    local _pid=$$
    local _shlname="${local_exec_shell_name}"
    local _logmessage="${!argnums[2]}"
    local _log="${_logdate}${sep}${_pri}${sep}pid:${_pid}${sep}${_shlname}${sep}${_logmessage}"
    
    # フラグの状態に応じて標準出力・エラー出力
    if "${_use_err_out}" && "${_full_out}"; then
        echo -e "${_log}" >&2
    elif "${_use_err_out}"; then
        echo -e "${_logmessage}" >&2
    elif "${_use_std_out}" && "${_full_out}"; then
        echo -e "${_log}"
    elif "${_use_std_out}"; then
        echo -e "${_logmessage}"
    fi
    
    # ログファイルに出力
    echo -e "${_log}" >> "${LOG_FILE_NAME}"
    return 0
}


# 【情報出力用関数】
#   関数定義に読み込まれたパスの情報などをログ出力用関数に渡して出力します
#   [引数] なし
#   [使用例] infodump
#   [依存] logmsg関数
function dumpinfo() {
    logmsg ${LL_INFO} "[設定情報] 標準出力用一時ファイル  ：${STD_OUT_FILE}"
    logmsg ${LL_INFO} "[設定情報] エラー出力用一時ファイル：${STD_ERR_FILE}"
    logmsg ${LL_INFO} "[設定情報] ログファイル            ：${LOG_FILE_NAME}"
}


# 【標準出力ファイルの削除関数】
#   [引数] 削除対象ファイルのフルパス（省略可能、複数指定可能）
#   [使用例] removetmp
#   [依存] logmsg関数
function removetmp() {
    if [ -f "${STD_OUT_FILE}" ]; then
        rm "${STD_OUT_FILE}"
        logmsg ${LL_INFO} "[一時ファイル削除] ${STD_OUT_FILE}"
    fi
    if [ -f "${STD_ERR_FILE}" ]; then
        rm "${STD_ERR_FILE}"
        logmsg ${LL_INFO} "[一時ファイル削除] ${STD_ERR_FILE}"
    fi
    # 引数が指定された場合はそのファイルを削除
    if [ $# != 0 ]; then
        for file_path; do
            rm "${file_path}"
            logmsg ${LL_INFO} "[一時ファイル削除] ${file_path}"
        done
    fi
}

