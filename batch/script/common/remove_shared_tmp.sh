#!/bin/bash

###########################################
# 【共有一時ファイル削除処理】
#   [引数1] 機能グループ名
#   [引数2] 呼び出し元ファイル名
#   [引数3] 削除対象ファイルのパスが格納されている変数名
#   [実行例] remove_shared_tmp.sh "importconf" "SGTS0001.sh" "TMP_REMOVE_FILE_CSV"
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
# 削除対象ファイルのパスが格納されている変数名
remove_target_var_name=$3

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

# 削除対象ファイルを共通変数から取得
remove_target_file="${!remove_target_var_name}"

# 情報出力・変数状況確認
logmsg ${LL_INFO} "削除対象ファイル：${remove_target_file}"
if [ -z "${remove_target_file}" ]; then
    logmsg ${LL_ERR} "ファイル名の指定が正しくありません"
    removetmp
    logmsg ${LL_ERR} "異常終了"
    exit 1
fi

# 存在確認をして削除
if [ -f "${remove_target_file}" ]; then
    rm "${remove_target_file}"
    return_code=$?
    if [ ${return_code} -ne 0 ]; then
        logmsg ${LL_ERR} "ファイル削除でエラーが発生しました"
        removetmp
        logmsg ${LL_ERR} "異常終了"
        exit 1
    fi
else
    logmsg ${LL_WARN} "削除対象ファイルはありませんでした"
fi

logmsg ${LL_INFO} "ファイルを削除しました"
echo "ファイルを削除しました：${remove_target_file}"

removetmp
logmsg ${LL_INFO} "正常終了"
exit 0
