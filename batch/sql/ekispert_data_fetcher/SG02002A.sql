-- ------------------------------------------
-- 駅すぱあとAPI設定用CSVファイル取り込み
-- ------------------------------------------

-- 処理対象指定
\set from_csv_path  :tmp_formated_ekispert_setting_csv
\set to_table_name  'sg02002a'
\set column_list    'station_name, station_code'


-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.:to_table_name;

-- テーブル作成
CREATE TABLE :schema.:to_table_name (
    station_name TEXT,
    station_code TEXT,
    PRIMARY KEY(station_name)
);

-- 読込コマンド組立・実行 (カンマ区切り・列指定あり・ヘッダーあり)
\set importcmd '\\COPY ':schema'.':to_table_name'(':column_list') FROM \'':from_csv_path'\' WITH CSV Header'
:importcmd

-- トランザクション確定
COMMIT;
