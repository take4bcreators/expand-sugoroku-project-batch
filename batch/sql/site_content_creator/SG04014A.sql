-- --------------------------------------------
-- コンテンツデータ整形
-- --------------------------------------------

-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg04014a;

-- テーブル作成
CREATE TABLE :schema.sg04014a (
    board_id TEXT,
    board_name TEXT NOT NULL,
    board_base TEXT NOT NULL,
    store_name TEXT NOT NULL,
    store_id TEXT NOT NULL,
    store_access TEXT NOT NULL,
    store_address TEXT NOT NULL,
    store_open TEXT NOT NULL,
    store_photo TEXT NOT NULL,
    event_name TEXT NOT NULL,
    event_detail TEXT NOT NULL,
    point INTEGER NOT NULL,
    skip INTEGER NOT NULL,
    move INTEGER NOT NULL,
    minigame_id TEXT NOT NULL,
    minigame_name TEXT NOT NULL,
    minigame_detail TEXT NOT NULL,
    square_number INTEGER,
    PRIMARY KEY(board_id, square_number)
);

-- sg04013a のデータを整える
INSERT INTO :schema.sg04014a (
    board_id,
    board_name,
    board_base,
    store_name,
    store_id,
    store_access,
    store_address,
    store_open,
    store_photo,
    event_name,
    event_detail,
    point,
    skip,
    move,
    minigame_id,
    minigame_name,
    minigame_detail,
    square_number
)
SELECT
    board_id,
    station_name || store_type AS board_name,
    board_base,
    COALESCE(store_name, ''),
    COALESCE(store_id, ''),
    COALESCE(store_access, ''),
    COALESCE(store_address, ''),
    COALESCE(store_open, ''),
    COALESCE(store_photo, ''),
    COALESCE(event_name, ''),
    COALESCE(event_detail, ''),
    COALESCE(point, 0),
    COALESCE(skip, 0),
    COALESCE(move, 0),
    COALESCE(minigame_id, ''),
    COALESCE(minigame_name, ''),
    COALESCE(minigame_detail, ''),
    square_number
FROM
    :schema.sg04013a
;

-- トランザクション確定
COMMIT;
