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
# ファイルのパス
#########################

# 共通モジュールファイルのパス
export COMMON_LIB_SH="${COM_SHELL_DIR}/common_function.sh"
# export DOT_ENV="${ENV_DIR}/.env"


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
    -v CONFIG_DIR=${CONFIG_DIR} \
"
