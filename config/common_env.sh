# 共通設定ファイル

#########################
# 走行設定
#########################

# 共有一時ファイルをジョブで削除するかのフラグ（1:削除する／0:削除しない）
export REMOVE_SHARED_TMP="0"
# export REMOVE_SHARED_TMP="1"

# 本番サイトへのデプロイするかのフラグ（1:本番サイトへデプロイ／0:開発サイトへデプロイ）
export DEPLOY_TO_PRD_SITE="0"
# export DEPLOY_TO_PRD_SITE="1"

# データベースの使用スキーマ名
export DB_SCHEMA="work"
# export DB_SCHEMA="prd"



#########################
# ディレクトリのパス
#   最後に / は入れない
#########################

# このプロジェクトのトップディレクトリのパス（profile で定義済み）
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
# 共有ファイル用ディレクトリのパス
export SHARED_DIR="${PROJECT_BATCH_ROOT}/shared"
# バッチ用シェルスクリプトのあるディレクトリのパス
export SHELL_DIR="${BATCH_DIR}/script"
# SQLファイルのあるディレクトリのパス
export SQL_DIR="${BATCH_DIR}/sql"
# JSファイルのあるディレクトリのパス
export JS_DIR="${BATCH_DIR}/js"
# 共通シェルのディレクトリのパス
export COM_SHELL_DIR="${SHELL_DIR}/common"


#########################
# 他リポジトリの情報
#########################

# フロントリポジトリのトップディレクトリのパス（profile で定義済み）
PROJECT_FRONT_ROOT="${PROJECT_FRONT_ROOT}"
# フロントリポジトリ名（リポジトリのフルパスから取得）
export FRONT_REPOSITORY_NAME=$(cd "${PROJECT_FRONT_ROOT}"; basename $(pwd))


#########################
# 共通ファイルのパス
#########################

# 共通モジュールファイルのパス
export COMMON_LIB_SH="${COM_SHELL_DIR}/common_function.sh"
# 環境設定ファイルのパス
export APP_ENV="${ENV_DIR}/app.env"
# 共有ホームディレクトリのパス
export PUB_HOME="/home/pub"


#########################
# 指定文字列など
#########################

# 連番ファイルなどの置換前となる文字列（削除のために glob を使用する）
export SEQ_FILES_EXT="???"


#########################
# サイトの設定
#########################

# 本番サイトのサイトID （https:// XXXX.netlify.app の https// を除いた部分）
export NL_PRD_SITE_ID="extensionlab-temporally.netlify.app"

# 検証サイトのサイトID （https:// XXXX.netlify.app の https// を除いた部分）
export NL_DEV_SITE_ID="euphonious-belekoy-36e136.netlify.app"


#########################
# 処理別ファイルのパス
#########################

# 設定ファイル
export SETTING_CSV="${CONFIG_DIR}/app.csv"
# 設定ファイルデータ整形一時ファイル
export TMP_FORMATED_SETTING_CSV="${TMP_DIR}/tmp_sg01001a.csv"

# 駅すぱあと設定ファイル
export EKISPERT_SETTING_CSV="${CONFIG_DIR}/ekispert_conf.csv"
# 駅すぱあと設定ファイルデータ整形一時ファイル
export TMP_FORMATED_EKISPERT_SETTING_CSV="${TMP_DIR}/tmp_sg02001a.csv"
# 駅すぱあとAPIリクエスト一時CSV
export TMP_EKISPERT_REQUEST_CSV="${TMP_DIR}/tmp_sg02005a.csv"
# 駅すぱあとAPIレスポンス一時JSON
export TMP_EKISPERT_RESPONSE_JSONS="${TMP_DIR}/tmp_sg02006a.${SEQ_FILES_EXT}.json"
# 駅すぱあとAPIレスポンス集約一時CSV
export TMP_EKISPERT_RESPONSE_JOIN_CSV="${TMP_DIR}/tmp_sg02007a.csv"

# ホットペッパー設定ファイル
export HOTPEPPER_SETTING_CSV="${CONFIG_DIR}/hotpepper_conf.csv"
# ホットペッパー設定ファイルデータ整形一時ファイル
export TMP_FORMATED_HOTPEPPER_SETTING_CSV="${TMP_DIR}/tmp_sg03001a.csv"
# ホットペッパーAPIリクエスト一時CSV
export TMP_HOTPEPPER_REQUEST_CSV="${TMP_DIR}/tmp_sg03005a.csv"
# ホットペッパーAPIレスポンス一時JSON
export TMP_HOTPEPPER_RESPONSE_JSONS="${TMP_DIR}/tmp_sg03006a.${SEQ_FILES_EXT}.json"
# ホットペッパーAPIレスポンス集約一時TSV
export TMP_HOTPEPPER_RESPONSE_JOIN_TSV="${TMP_DIR}/tmp_sg03007a.tsv"

# ボードイベント定義ファイル
export BOARD_EVENT_CSV="${DATA_DIR}/board_event.csv"
# ボードイベント定義ファイルデータ整形一時ファイル
export TMP_FORMATED_BOARD_EVENT_CSV="${TMP_DIR}/tmp_sg04001a.csv"
# ミニゲーム情報ファイル
export MINIGAME_DATA_CSV="${DATA_DIR}/minigame_data.csv"
# ミニゲーム情報ファイルデータ整形一時ファイル
export TMP_FORMATED_MINIGAME_DATA_CSV="${TMP_DIR}/tmp_sg04003a.csv"
# ボードベース定義ファイル
export BOARD_BASE_CSV="${DATA_DIR}/board_base.csv"
# ボードベース定義ファイルデータ整形一時ファイル
export TMP_FORMATED_BOARD_BASE_CSV="${TMP_DIR}/tmp_sg04011a.csv"
# コンテンツデータ一時JSON
export TMP_CONTENT_DATA_JSON="${TMP_DIR}/tmp_sg04017a.json"
# ボードデータJSON
export BOARD_DATA_JSON="${SHARED_DIR}/boards.json"
# ミニゲームデータ一時JSON
export TMP_MINIGAME_DATA_JSON="${TMP_DIR}/tmp_sg04019a.json"
# ミニゲームJSON
export MINIGAMES_JSON="${SHARED_DIR}/minigames.json"

# フロント資材コピー除外情報ファイル
export FRONT_RSYNC_EXCLUDE_LIST="${CONFIG_DIR}/front_rsync_exclude_list.txt"
# フロント資材コピー先ディレクトリ
export FRONT_RSYNC_TO_DIR="${PUB_HOME}"
# フロントリポジトリのJSON格納先ディレクトリ
export FRONT_SAVE_JSON_DIR="${FRONT_RSYNC_TO_DIR}/${FRONT_REPOSITORY_NAME}/src/data"
# gatsbyコマンドを使用してフロント資材をビルドするためのディレクトリ
export EXEC_GATSBY_DIR="${FRONT_RSYNC_TO_DIR}/${FRONT_REPOSITORY_NAME}"
# gatsbyの静的サイトデータ出力先のフォルダ名（zipコマンド実行時に必要）
export GATSBY_PUBLIC_DIR_NAME="public"
# gatsbyの静的サイトデータ出力先のフォルダパス
export GATSBY_PUBLIC_DIR="${EXEC_GATSBY_DIR}/${GATSBY_PUBLIC_DIR_NAME}"
# 静的サイトデータのZIPファイル名（名前単体をデプロイ時に使用）
export SITE_DATA_ZIP_NAME="sitedata.zip"
# 静的サイトデータのZIPファイル
export SITE_DATA_ZIP="${SHARED_DIR}/${SITE_DATA_ZIP_NAME}"

# デプロイ時のレスポンス保存ファイル
export TMP_DEPLOY_CURL_RES_LOG="${TMP_DIR}/deploy_response.json"
# ステータス確認時のレスポンス保存ファイル
export TMP_CHECK_STATUS_CURL_RES_LOG="${TMP_DIR}/check_status_response.json"
# ステータス確認の最大試行回数
export CHECK_STATUS_MAX_TRY_TIMES=11


#########################
# PostgreSQLの設定
#########################

# 使用するデータベースの名前
export DB_NAME="sgpjdb01"
# データベースのユーザ名
export DB_USER="sugoroku"


#########################
# PostgreSQLのバインド変数
#########################

# 設定するバインド変数を格納
export DB_BIND=" \
    -v schema=${DB_SCHEMA} \
    -v tmp_formated_setting_csv=${TMP_FORMATED_SETTING_CSV} \
    -v tmp_formated_ekispert_setting_csv=${TMP_FORMATED_EKISPERT_SETTING_CSV} \
    -v tmp_ekispert_request_csv=${TMP_EKISPERT_REQUEST_CSV} \
    -v tmp_ekispert_response_join_csv=${TMP_EKISPERT_RESPONSE_JOIN_CSV} \
    -v tmp_formated_hotpepper_setting_csv=${TMP_FORMATED_HOTPEPPER_SETTING_CSV} \
    -v tmp_hotpepper_request_csv=${TMP_HOTPEPPER_REQUEST_CSV} \
    -v tmp_hotpepper_response_join_tsv=${TMP_HOTPEPPER_RESPONSE_JOIN_TSV} \
    -v tmp_formated_board_event_csv=${TMP_FORMATED_BOARD_EVENT_CSV} \
    -v tmp_formated_minigame_data_csv=${TMP_FORMATED_MINIGAME_DATA_CSV} \
    -v tmp_formated_board_base_csv=${TMP_FORMATED_BOARD_BASE_CSV} \
    -v tmp_content_data_json=${TMP_CONTENT_DATA_JSON} \
    -v tmp_minigame_data_json=${TMP_MINIGAME_DATA_JSON} \
"
