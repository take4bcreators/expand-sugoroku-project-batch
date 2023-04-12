-- ------------------------------------------
-- ボードベース定義読み込み
-- ------------------------------------------

-- 処理対象指定
\set from_csv_path  :tmp_formated_board_base_csv
\set to_table_name  'sg04012a'
\set column_list    'store_type, board_base'


-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.:to_table_name;

-- テーブル作成
CREATE TABLE :schema.:to_table_name (
    store_type TEXT,
    board_base TEXT,
    PRIMARY KEY(store_type)
);

-- 読込コマンド組立・実行 (カンマ区切り・列指定あり・ヘッダーあり) 
\set importcmd '\\COPY ':schema'.':to_table_name'(':column_list') FROM \'':from_csv_path'\' WITH CSV Header'
:importcmd

-- トランザクション確定
COMMIT;
