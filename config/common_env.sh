# 共通設定ファイル

#########################
# ディレクトリのパス
#   最後に / は入れない
#########################

# このプロジェクトのトップディレクトリのパス（.bash_profile で定義済み）
PROJECT_BATCH_ROOT="${PROJECT_BATCH_ROOT}"
# バッチディレクトリのパス
export BATCH_DIR="${PROJECT_BATCH_ROOT}/batch"
# 設定ファイル用ディレクトリのパス
export CONFIG_DIR="${PROJECT_BATCH_ROOT}/config"
# データファイル用ディレクトリのパス
export DATA_DIR="${PROJECT_BATCH_ROOT}/data"
# 環境設定ファイル用ディレクトリのパス
export ENV_DIR="${PROJECT_BATCH_ROOT}/env"
# ログ用ディレクトリのパス
export LOG_DIR="${PROJECT_BATCH_ROOT}/log"
# 一時ファイル用ディレクトリのパス
export TMP_DIR="${PROJECT_BATCH_ROOT}/tmp"
# バッチ用シェルスクリプトのあるディレクトリのパス
export SHELL_DIR="${BATCH_DIR}/script"
# SQLファイルのあるディレクトリのパス
export SQL_DIR="${BATCH_DIR}/sql"
# 共通シェルのディレクトリのパス
export COM_SHELL_DIR="${SHELL_DIR}/common"


#########################
# 共通ファイルのパス
#########################

# 共通モジュールファイルのパス
export COMMON_LIB_SH="${COM_SHELL_DIR}/common_function.sh"
# 環境設定ファイルのパス
export APP_ENV="${ENV_DIR}/app.env"


#########################
# 処理別ファイルのパス
#########################

# 設定ファイル
export SETTING_CSV="${CONFIG_DIR}/app.csv"
# 設定ファイルデータ整形一時ファイル
export TMP_FORMATED_SETTING_CSV="${TMP_DIR}/tmp_sg01001a.csv"
# 駅すぱあとAPIリクエスト一時CSV
export TMP_EKISPERT_REQUEST_CSV="${TMP_DIR}/tmp_sg02002a.csv"



#########################
# PostgreSQLの設定
#########################

# 使用するデータベースの名前
export DB_NAME="sgpjdb01"
# データベースのユーザ名
export DB_USER="sugoroku"
# データベースの使用スキーマ名
export DB_SCHEMA="work"


#########################
# PostgreSQLのバインド変数
#########################

# 設定するバインド変数を格納
export DB_BIND=" \
    -v schema=${DB_SCHEMA} \
    -v tmp_formated_setting_csv=${TMP_FORMATED_SETTING_CSV} \
    -v tmp_ekispert_request_csv=${TMP_EKISPERT_REQUEST_CSV} \
"
