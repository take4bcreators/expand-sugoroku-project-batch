-- --------------------------------------------
-- ボードID付与
-- --------------------------------------------

-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg04007a;

-- テーブル作成
-- @note 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
CREATE TABLE :schema.sg04007a (
    board_id TEXT,
    station_name TEXT,
    store_type TEXT,
    fetch_api_data BOOLEAN,
    create_board BOOLEAN,
    store_name TEXT,
    store_name_kana TEXT,
    store_id TEXT,
    store_catch TEXT,
    store_genre_catch TEXT,
    store_access TEXT,
    store_address TEXT,
    store_open TEXT,
    store_photo TEXT,
    PRIMARY KEY(board_id, store_id)
);

-- sg04006a に 駅名・店タイプ 毎に ボードID を付与する
-- @note 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
INSERT INTO :schema.sg04007a (
    board_id,
    station_name,
    store_type,
    fetch_api_data,
    create_board,
    store_name,
    store_name_kana,
    store_id,
    store_catch,
    store_genre_catch,
    store_access,
    store_address,
    store_open,
    store_photo
)
SELECT DISTINCT
    TO_CHAR(
        DENSE_RANK() OVER(ORDER BY station_name, store_type),
        'FM000'
    ) AS board_id,
    station_name,
    store_type,
    fetch_api_data,
    create_board,
    store_name,
    store_name_kana,
    store_id,
    store_catch,
    store_genre_catch,
    store_access,
    store_address,
    store_open,
    store_photo
FROM
    :schema.sg04006a
;

-- トランザクション確定
COMMIT;
