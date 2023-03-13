# 共通設定ファイル

#########################
# パス指定変数
# ディレクトリのパスの最後に / は入れない
#########################
# 第1階層ディレクトリ
export BATCH_DIR="${PROJECT_BATCH_ROOT}/batch"
export CONFIG_DIR="${PROJECT_BATCH_ROOT}/config"
export DATA_DIR="${PROJECT_BATCH_ROOT}/data"
export ENV_DIR="${PROJECT_BATCH_ROOT}/env"
export LOG_DIR="${PROJECT_BATCH_ROOT}/log"
export SSG_DIR="${PROJECT_BATCH_ROOT}/ssg"
export TMP_DIR="${PROJECT_BATCH_ROOT}/tmp"

# 第2階層ディレクトリ
# export CSV_DIR="${BATCH_DIR}/csv"
export SHELL_DIR="${BATCH_DIR}/script"
export SQL_DIR="${BATCH_DIR}/sql"

# 第3階層ディレクトリ
# export EKIDATAJP_DIR="${CSV_DIR}/ekidatajp"
export COM_SHELL_DIR="${SHELL_DIR}/common"

# ファイルパス
export COMMON_LIB_SH="${COM_SHELL_DIR}/common_function.sh"
# export DOT_ENV="${ENV_DIR}/.env"


#########################
# PostgreSQLの設定
#########################
export DB_NAME="sgpjdb01"
# export DB_USER="sugoroku"
export DB_SCHEMA="work"


#########################
# PostgreSQLのバインド変数
#########################
export DB_BIND=" \
    -v schema=${DB_SCHEMA} \
"
