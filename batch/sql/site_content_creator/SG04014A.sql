-- --------------------------------------------
-- スタートゴール情報付与
-- --------------------------------------------

-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg04014a;

-- テーブル作成
-- @note 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
CREATE TABLE :schema.sg04014a (
    board_id TEXT,
    square_number INTEGER,
    station_name TEXT,
    store_type TEXT,
    store_name TEXT,
    store_name_kana TEXT,
    store_id TEXT,
    store_catch TEXT,
    store_genre_catch TEXT,
    store_access TEXT,
    store_address TEXT,
    store_open TEXT,
    store_photo TEXT,
    event_name TEXT,
    event_detail TEXT,
    event_point INTEGER,
    event_skip INTEGER,
    event_move INTEGER,
    minigame_id TEXT,
    minigame_name TEXT,
    minigame_detail TEXT,
    board_base TEXT,
    PRIMARY KEY(board_id, square_number)
);

-- sg04013a のデータをそのまま sg04014a に挿入する
-- @note 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
INSERT INTO :schema.sg04014a (
    board_id,
    square_number,
    station_name,
    store_type,
    store_name,
    store_name_kana,
    store_id,
    store_catch,
    store_genre_catch,
    store_access,
    store_address,
    store_open,
    store_photo,
    event_name,
    event_detail,
    event_point,
    event_skip,
    event_move,
    minigame_id,
    minigame_name,
    minigame_detail,
    board_base
)
SELECT
    board_id,
    square_number,
    station_name,
    store_type,
    store_name,
    store_name_kana,
    store_id,
    store_catch,
    store_genre_catch,
    store_access,
    store_address,
    store_open,
    store_photo,
    event_name,
    event_detail,
    event_point,
    event_skip,
    event_move,
    minigame_id,
    minigame_name,
    minigame_detail,
    board_base
FROM
    :schema.sg04013a
;

-- スタートの情報を挿入する
INSERT INTO :schema.sg04014a (
    board_id,
    square_number,
    station_name,
    store_type,
    store_name,
    board_base
)
SELECT DISTINCT
    board_id,
    0 AS square_number,
    station_name,
    store_type,
    'スタート' AS store_name,
    board_base
FROM
    :schema.sg04013a
;

-- ゴールの情報を挿入する
INSERT INTO :schema.sg04014a (
    board_id,
    square_number,
    station_name,
    store_type,
    store_name,
    board_base
)
SELECT DISTINCT
    board_id,
    (MAX(square_number) OVER(PARTITION BY board_id)) + 1 AS square_number,
    station_name,
    store_type,
    'ゴール' AS store_name,
    board_base
FROM
    :schema.sg04013a
;

-- トランザクション確定
COMMIT;
