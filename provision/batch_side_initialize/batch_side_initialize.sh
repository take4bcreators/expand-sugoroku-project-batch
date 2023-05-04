#!/bin/bash

# フォルダ名・実行シェルのパスを指定
project_batch_root="/mnt/project/expand-sugoroku-project-batch"
parent_dir="${project_batch_root}/provision/batch_side_initialize"
unit_dir="${parent_dir}/unit"


exec_shell_desc="共有フォルダ作成処理"
exec_shell="${unit_dir}/create_pub_dir.sh"
if [ -f "${exec_shell}" ]; then
    echo "${exec_shell_desc}開始"
    ${exec_shell}
    return_code=$?
    echo "${exec_shell_desc}終了"
    echo "戻り値：${return_code}"
else
    echo "${exec_shell} が存在しません。スキップします"
fi

exit 0
