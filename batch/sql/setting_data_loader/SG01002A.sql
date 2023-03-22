-- ------------------------------------------
-- アプリ設定用CSVファイル取り込み
-- ------------------------------------------

-- 処理対象指定
\set from_csv_path  :tmp_formated_setting_csv
\set to_table_name  'sg01002a'
\set column_list    'station_name, store_type, ekispert_code, fetch_api_data, create_board'


-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.:to_table_name;

-- テーブル作成
CREATE TABLE :schema.:to_table_name (
    station_name TEXT,
    store_type TEXT,
    ekispert_code TEXT,
    fetch_api_data BOOLEAN,
    create_board BOOLEAN,
    PRIMARY KEY(station_name, store_type)
);

-- 読込コマンド組立・実行 (カンマ区切り・列指定あり・ヘッダーあり)
\set importcmd '\\COPY ':schema'.':to_table_name'(':column_list') FROM \'':from_csv_path'\' WITH CSV Header'
:importcmd

-- 空白行を削除
DELETE FROM
    :schema.:to_table_name
WHERE
    station_name IS NULL
    OR store_type IS NULL
;

-- 指定されなかった項目を FALSE で補完（fetch_api_data）
-- COPY による CSVインポートの場合 DEFAULT は無効になるため実装
UPDATE
    :schema.:to_table_name
SET
    fetch_api_data = FALSE
WHERE
    fetch_api_data IS NULL
;

-- 指定されなかった項目を FALSE で補完（create_board）
-- COPY による CSVインポートの場合 DEFAULT は無効になるため実装
UPDATE
    :schema.:to_table_name
SET
    create_board = FALSE
WHERE
    create_board IS NULL
;

-- トランザクション確定
COMMIT;
