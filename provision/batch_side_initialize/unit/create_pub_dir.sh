#!/bin/bash

# 作成フォルダ指定
create_pub_dir="/home/pub"

# フォルダ作成
if [ -e "${create_pub_dir}" ]; then
    echo "作成対象の共有フォルダのパスが既に存在します"
    echo "パス：${create_pub_dir}"
    echo "スキップします"
    exit 0
fi

# フォルダ作成
mkdir ${create_pub_dir}

# パーミッション変更
chmod 775 ${create_pub_dir}
chown sugoroku:maingrp ${create_pub_dir}

# 作成後の状態確認
echo "共有フォルダ作成後の状態"
ls -ld ${create_pub_dir}

exit 0
