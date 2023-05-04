
###########################################
# Rundeck ジョブ 登録処理
# group ジョブ登録版
# サーバーのプロビジョニング処理で実行される
###########################################

# ファイル名指定
source_csv_group="./job_definition_csv/job_definition_group.csv"
template_yaml_ref_jobref="./yaml_template/job_def_template_ref_jobref.yaml"
template_yaml_ref_base="./yaml_template/job_def_template_ref_base.yaml"
add_uuid_csv_group="./tmp/job_definition_group_uuid.csv"
add_uuid_csv_unit="./tmp/job_definition_unit_uuid.csv"
tmp_ref_job_yaml="./tmp/tmp_ref_job.yaml"
create_yaml_group="./tmp/job_def_group.yaml"


# 開始メッセージ
echo "Rundeck登録処理開始（groupジョブ）"

# ディレクトリ移動
cd $(dirname $0)

: > "${add_uuid_csv_group}"
for record in $(tail -n +2 "${source_csv_group}"); do
    oneuuid=$(uuidgen)
    echo "${record}" | awk -v oneuuid="${oneuuid}" 'BEGIN{OFS=","}{print oneuuid, $0}' >> "${add_uuid_csv_group}"
done

: > "${create_yaml_group}"
for record in $(cat "${add_uuid_csv_group}"); do
    # 変数登録
    job_uuid=$(echo "${record}" | cut -d , -f 1)
    job_name=$(echo "${record}" | cut -d , -f 2)
    job_dir=$(echo "${record}" | cut -d , -f 3)
    job_desc=$(echo "${record}" | cut -d , -f 4)
    ref_job_dir=$(echo "${record}" | cut -d , -f 5)
    
    : > "${tmp_ref_job_yaml}"
    for ref_record in $(cat "${add_uuid_csv_unit}"); do
        record_ref_job_dir=$(echo "${ref_record}" | cut -d , -f 3)
        
        if [ "${ref_job_dir}" != "${record_ref_job_dir}" ]; then
            continue
        fi
        
        ref_job_uuid=$(echo "${ref_record}" | cut -d , -f 1)
        ref_job_name=$(echo "${ref_record}" | cut -d , -f 2)
        sed \
            -e "s|<UUID>|${ref_job_uuid}|" \
            -e "s|<JOB_NAME>|${ref_job_name}|" \
            -e "s|<JOB_DIR>|${record_ref_job_dir}|" \
            "${template_yaml_ref_jobref}" >> "${tmp_ref_job_yaml}"
    done
    
    # 対象がなかった場合は追加せずにスキップ
    if [ ! -s "${tmp_ref_job_yaml}" ]; then
        continue
    fi
    
    # 抜き出した文字列をyamlファイルに入力
    sed \
        -e "s|<UUID>|${job_uuid}|" \
        -e "s|<JOB_NAME>|${job_name}|" \
        -e "s|<JOB_DIR>|${job_dir}|" \
        -e "s|<JOB_DESC>|${job_desc}|" \
        -e "/<JOB_REF>/r ${tmp_ref_job_yaml}" \
        -e "/<JOB_REF>/d" \
        "${template_yaml_ref_base}" >> "${create_yaml_group}"
done


# グループジョブを登録
rd jobs load -p "expand-sugoroku-project" -f "${create_yaml_group}" -F yaml
return_code=$?

# 終了メッセージ
echo "Rundeck登録処理完了（groupジョブ）"

exit ${return_code}
