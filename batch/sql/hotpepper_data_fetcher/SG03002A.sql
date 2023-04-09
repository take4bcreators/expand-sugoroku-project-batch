-- ------------------------------------------
-- ホットペッパーAPI設定用CSVファイル取り込み
-- ------------------------------------------

-- 処理対象指定
\set from_csv_path  :tmp_formated_hotpepper_setting_csv
\set to_table_name  'sg03002a'
\set column_list    'station_name, store_type, hp_range, hp_genre, hp_count, hp_order, hp_keyword'


-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.:to_table_name;

-- テーブル作成
CREATE TABLE :schema.:to_table_name (
    station_name TEXT,
    store_type TEXT,
    hp_range INTEGER,
    hp_genre TEXT,
    hp_count INTEGER,
    hp_order INTEGER,
    hp_keyword TEXT
);

-- 読込コマンド組立・実行 (カンマ区切り・列指定あり・ヘッダーあり) 
\set importcmd '\\COPY ':schema'.':to_table_name'(':column_list') FROM \'':from_csv_path'\' WITH CSV Header'
:importcmd

-- トランザクション確定
COMMIT;
