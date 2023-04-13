-- --------------------------------------------
-- コンテンツデータ整形
-- --------------------------------------------

-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg04015a;

-- テーブル作成
-- 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
CREATE TABLE :schema.sg04015a (
    board_id TEXT,
    board_name TEXT NOT NULL,
    board_base TEXT NOT NULL,
    square_id INTEGER,
    square_goalflag BOOLEAN,
    store_name TEXT NOT NULL,
    store_id TEXT NOT NULL,
    store_access TEXT NOT NULL,
    store_address TEXT NOT NULL,
    store_open TEXT NOT NULL,
    store_photo TEXT NOT NULL,
    event_flag BOOLEAN NOT NULL,
    event_name TEXT NOT NULL,
    event_detail TEXT NOT NULL,
    event_point INTEGER NOT NULL,
    event_skip INTEGER NOT NULL,
    event_move INTEGER NOT NULL,
    event_minigame BOOLEAN NOT NULL,
    minigame_id TEXT NOT NULL,
    minigame_name TEXT NOT NULL,
    minigame_detail TEXT NOT NULL,
    PRIMARY KEY(board_id, square_id)
);

-- sg04013a のデータを整える
-- 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
INSERT INTO :schema.sg04015a (
    board_id,
    board_name,
    board_base,
    square_id,
    square_goalflag,
    store_name,
    store_id,
    store_access,
    store_address,
    store_open,
    store_photo,
    event_flag,
    event_name,
    event_detail,
    event_point,
    event_skip,
    event_move,
    event_minigame,
    minigame_id,
    minigame_name,
    minigame_detail
)
SELECT
    board_id,
    station_name || store_type      AS board_name,
    board_base,
    square_number                   AS square_id,
    CASE
        WHEN square_number = MAX(square_number) OVER(PARTITION BY board_id)
            THEN TRUE
        ELSE FALSE END              AS square_goalflag,
    COALESCE(store_name, '')        AS store_name,
    COALESCE(store_id, '')          AS store_id,
    COALESCE(store_access, '')      AS store_access,
    COALESCE(store_address, '')     AS store_address,
    COALESCE(store_open, '')        AS store_open,
    COALESCE(store_photo, '')       AS store_photo,
    CASE
        WHEN event_name IS NOT NULL AND event_name <> ''
            THEN TRUE
        ELSE FALSE END              AS event_flag,
    COALESCE(event_name, '')        AS event_name,
    COALESCE(event_detail, '')      AS event_detail,
    COALESCE(event_point, 0)        AS event_point,
    COALESCE(event_skip, 0)         AS event_skip,
    COALESCE(event_move, 0)         AS event_move,
    CASE
        WHEN minigame_id IS NOT NULL AND minigame_id <> ''
            THEN TRUE
        ELSE FALSE END              AS event_minigame,
    COALESCE(minigame_id, '')       AS minigame_id,
    COALESCE(minigame_name, '')     AS minigame_name,
    COALESCE(minigame_detail, '')   AS minigame_detail
FROM
    :schema.sg04014a
ORDER BY
    board_id, square_id
;

-- トランザクション確定
COMMIT;
