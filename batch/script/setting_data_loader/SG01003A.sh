#!/bin/bash

###################################
# 共有一時ファイル削除
###################################

# ※対象ファイルは下部で指定


# このシェルスクリプトが所属する機能グループ名
# （このシェルの親ディレクトリ名を格納）
module_group_name=$(cd $(dirname $0); basename $(pwd))

# 処理名
# （このシェルスクリプトの名前を拡張子なしで格納）
this_process_name=$(basename $0 .sh)

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



# 削除対象のファイルを指定
# 複数指定する場合は スペース区切り にする
REMOVE_TARGET_FILE_LIST="${TMP_FORMATED_SETTING_CSV}"



# シェルスクリプト実行
#  remove_shared_tmp.sh  機能グループ名 このシェルのファイル名 削除対象ファイルのパスが格納されている変数名
"${COM_SHELL_DIR}"/remove_shared_tmp.sh "${module_group_name}" "${this_process_name}.sh" "${REMOVE_TARGET_FILE_LIST}"

exit $?
