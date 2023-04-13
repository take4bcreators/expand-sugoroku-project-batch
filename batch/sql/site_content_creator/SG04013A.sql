-- --------------------------------------------
-- ボードベースデータ付与
-- --------------------------------------------

-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg04013a;

-- テーブル作成
-- 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
CREATE TABLE :schema.sg04013a (
    board_id TEXT,
    square_number INTEGER,
    station_name TEXT,
    store_type TEXT,
    store_name TEXT,
    store_id TEXT,
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

-- sg04010a に sg04012a のボードベース情報を付与する
-- 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
INSERT INTO :schema.sg04013a (
    board_id,
    square_number,
    station_name,
    store_type,
    store_name,
    store_id,
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
    t1.board_id,
    t1.square_number,
    t1.station_name,
    t1.store_type,
    t1.store_name,
    t1.store_id,
    t1.store_access,
    t1.store_address,
    t1.store_open,
    t1.store_photo,
    t1.event_name,
    t1.event_detail,
    t1.event_point,
    t1.event_skip,
    t1.event_move,
    t1.minigame_id,
    t1.minigame_name,
    t1.minigame_detail,
    COALESCE(t2.board_base, 'normal') AS board_base
FROM
    :schema.sg04010a t1
LEFT OUTER JOIN
    :schema.sg04012a t2
ON
    t1.store_type = t2.store_type
;

-- トランザクション確定
COMMIT;
