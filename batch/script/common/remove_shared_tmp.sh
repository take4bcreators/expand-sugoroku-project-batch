#!/bin/bash

###########################################
# 【共有一時ファイル削除処理】
#   [引数1] 機能グループ名
#   [引数2] 呼び出し元ファイル名
#   [引数3] 削除対象ファイルのリスト（スペース区切り）
#   [実行例] remove_shared_tmp.sh "importconf" "SGTS0001.sh" "tmp_hoge1.txt tmp_hoge2.txt"
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
# 削除対象ファイルのリスト（スペース区切り）
remove_target_file_list=$3
# remove_target_var_name=$3

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


# フラグのチェックとスキップ
if [ -z "${REMOVE_SHARED_TMP}" ]; then
    logmsg ${LL_ERR} "フラグの指定がありません"
    logmsg ${LL_INFO} "フラグの状態：${REMOVE_SHARED_TMP}"
    removetmp
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi
if [ "${REMOVE_SHARED_TMP}" = "0" ];then
    logmsg ${LL_INFO} "削除処理をスキップします。フラグの状態：${REMOVE_SHARED_TMP}"
    echo "削除処理をスキップします。フラグの状態：${REMOVE_SHARED_TMP}"
    removetmp
    logmsg ${LL_INFO} "正常終了"
    exit 0
fi
if [ "${REMOVE_SHARED_TMP}" != "1" ];then
    logmsg ${LL_ERR} "フラグの指定が正しくありません"
    logmsg ${LL_INFO} "フラグの状態：${REMOVE_SHARED_TMP}"
    removetmp
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi
logmsg ${LL_INFO} "削除処理を行います。フラグの状態：${REMOVE_SHARED_TMP}"


# 情報出力・変数状況確認
if [ -z "${remove_target_file_list}" ]; then
    logmsg ${LL_ERR} "ファイル名の指定が正しくありません"
    logmsg ${LL_ERR} "対象変数名：remove_target_file_list"
    logmsg ${LL_ERR} "渡された値：${remove_target_file_list}"
    removetmp
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi

file_cnt=0
remove_cnt=0
for remove_target_file in ${remove_target_file_list}; do
    let file_cnt++
    # 存在確認をして削除
    if [ -f "${remove_target_file}" ]; then
        rm "${remove_target_file}"
        return_code=$?
        if [ ${return_code} -ne 0 ]; then
            logmsg ${LL_ERR} "ファイル削除でエラーが発生しました"
            logmsg ${LL_ERR} "対象ファイル：${remove_target_file}"
            removetmp
            logmsg ${LL_ERR} "異常終了"
            exit 1
        fi
        logmsg ${LL_INFO} "ファイルを削除しました：${remove_target_file}"
        echo "ファイルを削除しました：${remove_target_file}"
        let remove_cnt++
    else
        logmsg ${LL_INFO} "削除対象ファイルがありませんでした：${remove_target_file}"
        echo "削除対象ファイルがありませんでした：${remove_target_file}"
    fi
done


logmsg ${LL_INFO} "ファイル削除が完了しました。  指定ファイル数：${file_cnt}  削除数：${remove_cnt}"

removetmp
logmsg ${LL_INFO} "正常終了"
exit 0
