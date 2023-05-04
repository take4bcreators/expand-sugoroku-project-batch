
###########################################
# Rundeck ジョブ 登録処理
# unit ジョブ登録版
# サーバーのプロビジョニング処理で実行される
###########################################

# ファイル名指定
source_csv_unit="./job_definition_csv/job_definition_unit.csv"
template_yaml_unit="./yaml_template/job_def_template_unit.yaml"
add_uuid_csv_unit="./tmp/job_definition_unit_uuid.csv"
create_yaml_unit="./tmp/job_def_unit.yaml"


# 開始メッセージ
echo "Rundeck登録処理開始（unitジョブ）"

# ディレクトリ移動
cd $(dirname $0)

# タイトル行をカットして、1列目にUUIDを付加したファイルを作成
: > "${add_uuid_csv_unit}"
for record in $(tail -n +2 "${source_csv_unit}"); do
    oneuuid=$(uuidgen)
    echo "${record}" | awk -v oneuuid="${oneuuid}" 'BEGIN{OFS=","}{print oneuuid, $0}' >> "${add_uuid_csv_unit}"
done

# テンプレートファイルから情報を付加したファイルを作成
: > "${create_yaml_unit}"
for record in $(cat "${add_uuid_csv_unit}"); do
    # 変数登録
    job_uuid=$(echo "${record}" | cut -d , -f 1)
    job_name=$(echo "${record}" | cut -d , -f 2)
    job_dir=$(echo "${record}" | cut -d , -f 3)
    job_desc=$(echo "${record}" | cut -d , -f 4)
    job_shell=$(echo "${record}" | cut -d , -f 5)

    # 抜き出した文字列をyamlファイルに入力
    sed \
        -e "s|<UUID>|${job_uuid}|" \
        -e "s|<JOB_NAME>|${job_name}|" \
        -e "s|<JOB_DIR>|${job_dir}|" \
        -e "s|<JOB_DESC>|${job_desc}|" \
        -e "s|<SHELL_PATH>|${job_shell}|" \
        "${template_yaml_unit}" >> "${create_yaml_unit}"
done

# ユニットジョブを登録
rd jobs load -p "expand-sugoroku-project" -f "${create_yaml_unit}" -F yaml
return_code=$?

# 終了メッセージ
echo "Rundeck登録処理完了（unitジョブ）"

exit ${return_code}
