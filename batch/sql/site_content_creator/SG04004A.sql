-- ------------------------------------------
-- ボードイベント定義読み込み
-- ------------------------------------------

-- 処理対象指定
\set from_csv_path  :tmp_formated_minigame_data_csv
\set to_table_name  'sg04004a'
\set column_list    'minigame_id, minigame_name, minigame_detail'


-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.:to_table_name;

-- テーブル作成
CREATE TABLE :schema.:to_table_name (
    minigame_id text,
    minigame_name text,
    minigame_detail text,
    PRIMARY KEY(minigame_id)
);

-- 読込コマンド組立・実行 (カンマ区切り・列指定あり・ヘッダーあり) 
\set importcmd '\\COPY ':schema'.':to_table_name'(':column_list') FROM \'':from_csv_path'\' WITH CSV Header'
:importcmd

-- トランザクション確定
COMMIT;
