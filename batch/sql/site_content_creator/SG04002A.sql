-- ------------------------------------------
-- ボードイベント定義読み込み
-- ------------------------------------------

-- 処理対象指定
\set from_csv_path  :tmp_formated_board_event_csv
\set to_table_name  'sg04002a'
\set column_list    'event_name, event_detail, point, skip, move, minigame_id, level'


-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.:to_table_name;

-- テーブル作成
CREATE TABLE :schema.:to_table_name (
    data_seq SERIAL,
    event_name TEXT,
    event_detail TEXT,
    point INTEGER,
    skip INTEGER,
    move INTEGER,
    minigame_id TEXT,
    level TEXT,
    PRIMARY KEY(data_seq)
);

-- 読込コマンド組立・実行 (カンマ区切り・列指定あり・ヘッダーあり) 
\set importcmd '\\COPY ':schema'.':to_table_name'(':column_list') FROM \'':from_csv_path'\' WITH CSV Header'
:importcmd

-- トランザクション確定
COMMIT;
