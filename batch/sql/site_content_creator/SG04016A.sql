-- ------------------------------------------
-- コンテンツデータJSON作成
-- ------------------------------------------

-- トランザクション開始
BEGIN;


-- 既存の独自型（JSON組立時に使用する）の削除
DROP TYPE IF EXISTS ty_board_json;
DROP TYPE IF EXISTS ty_square_json;
DROP TYPE IF EXISTS ty_square_store_json;
DROP TYPE IF EXISTS ty_square_event_json;
DROP TYPE IF EXISTS ty_square_minigame_json;


-- 独自型（JSON組立時に使用する）の作成
-- @note 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
-- (boards.json)[].board
CREATE TYPE ty_board_json AS (
    id TEXT,
    name TEXT,
    base TEXT
);

-- (boards.json)[].square[]
CREATE TYPE ty_square_json AS (
    id INTEGER,
    goalflag BOOLEAN,
    store JSONB,
    event JSONB,
    minigame JSONB
);

-- (boards.json)[].square[].store
CREATE TYPE ty_square_store_json AS (
    name TEXT,
    name_kana TEXT,
    id TEXT,
    catch TEXT,
    genre_catch TEXT,
    access TEXT,
    address TEXT,
    open TEXT,
    photo TEXT
);

-- (boards.json)[].square[].event
CREATE TYPE ty_square_event_json AS (
    flag BOOLEAN,
    name TEXT,
    detail TEXT,
    point INTEGER,
    skip INTEGER,
    move INTEGER,
    minigame BOOLEAN
);

-- (boards.json)[].square[].minigame
CREATE TYPE ty_square_minigame_json AS (
    id TEXT,
    name TEXT,
    detail TEXT
);


-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg04016a;


-- テーブル作成
CREATE TABLE :schema.sg04016a (
    boards_data jsonb
);


-- データ挿入
-- @note 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
INSERT INTO :schema.sg04016a (
    boards_data
)
WITH json_build_01 AS (
-- 1. square 配下の JSON化
    SELECT
    -- (boards.json)[].board 配下
        board_id,
        board_name,
        board_base,
    -- (boards.json)[].square[] 配下
        square_id,
        square_goalflag,
    -- (boards.json)[].square[].store 配下
        ROW_TO_JSON(ROW(
            store_name,
            store_name_kana,
            store_id,
            store_catch,
            store_genre_catch,
            store_access,
            store_address,
            store_open,
            store_photo
        )::ty_square_store_json)::JSONB AS square_store_json,
    -- (boards.json)[].square[].event 配下
        ROW_TO_JSON(ROW(
            event_flag,
            event_name,
            event_detail,
            event_point,
            event_skip,
            event_move,
            event_minigame
        )::ty_square_event_json)::JSONB AS square_event_json,
    -- (boards.json)[].square[].minigame 配下
        ROW_TO_JSON(ROW(
            minigame_id,
            minigame_name,
            minigame_detail
        )::ty_square_minigame_json)::JSONB AS square_minigame_json
    FROM
        :schema.sg04015a
)
, json_build_02 AS (
-- 2. square の JSON化
    SELECT
    -- (boards.json)[].board 配下
        board_id,
        board_name,
        board_base,
    -- (boards.json)[].square[] 配下
        ROW_TO_JSON(ROW(
            square_id,
            square_goalflag,
            square_store_json,
            square_event_json,
            square_minigame_json
        )::ty_square_json)::JSONB AS square_json
    FROM
        json_build_01
)
, json_build_03 AS (
-- 3. square の JSON配列化
    SELECT
    -- (boards.json)[].board 配下
        board_id,
        board_name,
        board_base,
    -- (boards.json)[].square[] 配下
        JSONB_AGG(square_json ORDER BY (square_json->>'id')::INTEGER) AS square_jsons
    FROM
        json_build_02
    GROUP BY
        board_id,
        board_name,
        board_base
    ORDER BY
        board_id
)
, json_build_04 AS (
-- 4. board の JSON化
    SELECT
    -- (boards.json)[].board 配下
        ROW_TO_JSON(ROW(
            board_id,
            board_name,
            board_base
        )::ty_board_json)::JSONB AS board_json,
    -- (boards.json)[].square[] 配下
        square_jsons
    FROM
        json_build_03
)
-- 4. 全体 の JSON配列化
SELECT
    JSONB_AGG(json_build_04 ORDER BY (board_json->>'board_id')) AS boards_data
FROM
    json_build_04
;

-- トランザクション確定
COMMIT;
