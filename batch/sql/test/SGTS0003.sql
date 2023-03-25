-- ------------------------------------------
-- アプリ設定用CSVファイル取り込み
-- ------------------------------------------

-- 処理対象指定
\set from_csv_path  :CONFIG_DIR'/app.csv'
\set to_table_name  'sgts0003'
\set column_list    'station,store_type,get_hotpepper,create_board'


-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.:to_table_name;

-- テーブル作成
CREATE TABLE :schema.:to_table_name (
    id SERIAL,
    station TEXT,
    store_type TEXT,
    get_hotpepper BOOLEAN,
    create_board BOOLEAN,
    PRIMARY KEY(id)
);

-- 読込コマンド組立・実行 (カンマ区切り・列指定あり・ヘッダーあり)
\set importcmd '\\COPY ':schema'.':to_table_name'(':column_list') FROM \'':from_csv_path'\' WITH CSV Header'
:importcmd

-- 空白行を削除
DELETE FROM
    :schema.:to_table_name
WHERE
    station IS NULL
    OR store_type IS NULL
;

-- 指定されなかった項目を FALSE で補完（get_hotpepper）
UPDATE
    :schema.:to_table_name
SET
    get_hotpepper = FALSE
WHERE
    get_hotpepper IS NULL
;

-- 指定されなかった項目を FALSE で補完（create_board）
UPDATE
    :schema.:to_table_name
SET
    create_board = FALSE
WHERE
    create_board IS NULL
;

-- トランザクション確定
COMMIT;
