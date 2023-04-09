-- ------------------------------------------
-- ホットペッパーレスポンスデータ読込
-- ------------------------------------------

-- 処理対象指定
\set from_tsv_path  :tmp_hotpepper_response_join_tsv
\set to_table_name  'sg03008a'
\set column_list    'station_name, store_type, store_name, store_id, store_access, store_address, store_open, store_photo'


-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.:to_table_name;

-- テーブル作成
CREATE TABLE :schema.:to_table_name (
    station_name TEXT,
    store_type TEXT,
    store_name TEXT,
    store_id TEXT,
    store_access TEXT,
    store_address TEXT,
    store_open TEXT,
    store_photo TEXT,
    PRIMARY KEY(station_name, store_type, store_id)
);

-- 読込コマンド組立・実行 (TSV・列指定あり・ヘッダーなし)
-- \set importcmd '\\COPY ':schema'.':to_table_name'(':column_list') FROM \'':from_tsv_path'\''
-- \set importcmd '\\COPY ':schema'.':to_table_name'(':column_list') FROM \'':from_tsv_path'\' WITH NULL AS '' '
\set importcmd '\\COPY ':schema'.':to_table_name'(':column_list') FROM \'':from_tsv_path'\''
:importcmd

-- トランザクション確定
COMMIT;
