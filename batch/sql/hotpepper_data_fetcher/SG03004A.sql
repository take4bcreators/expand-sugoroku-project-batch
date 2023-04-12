-- --------------------------------------------
-- ホットペッパー リクエストデータ抽出
-- --------------------------------------------

-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg03004a;

-- テーブル作成
CREATE TABLE :schema.sg03004a (
    station_name TEXT,
    store_type TEXT,
    station_lat TEXT,
    station_lon TEXT,
    hp_range INTEGER,
    hp_genre TEXT,
    hp_count INTEGER,
    hp_order INTEGER,
    hp_keyword TEXT,
    PRIMARY KEY(station_name, store_type)
);


-- sg03003a の情報を付与する
INSERT INTO :schema.sg03004a (
    station_name,
    store_type,
    station_lat,
    station_lon
)
SELECT DISTINCT
    station_name,
    store_type,
    station_lat,
    station_lon
FROM
    :schema.sg03003a
WHERE
    fetch_api_data = 't'
;


-- 1. all で 店タイプの指定がないものを付与
UPDATE
    :schema.sg03004a t1
SET
    hp_range    = t2.hp_range,
    hp_genre    = t2.hp_genre,
    hp_count    = t2.hp_count,
    hp_order    = t2.hp_order,
    hp_keyword  = t2.hp_keyword
FROM (
    SELECT *
    FROM :schema.sg03002a
    WHERE
        station_name = 'all'
        AND store_type IS NULL
) t2
;


-- 2. all で 店タイプの指定があるものを付与
UPDATE
    :schema.sg03004a t1
SET
    hp_range    = t2.hp_range,
    hp_genre    = t2.hp_genre,
    hp_count    = t2.hp_count,
    hp_order    = t2.hp_order,
    hp_keyword  = t2.hp_keyword
FROM (
    SELECT *
    FROM :schema.sg03002a
    WHERE
        station_name = 'all'
        AND store_type IS NOT NULL
) t2
WHERE
    t1.store_type = t2.store_type
;


-- 3. 駅の指定があり 店タイプの指定がないものを付与
UPDATE
    :schema.sg03004a t1
SET
    hp_range    = t2.hp_range,
    hp_genre    = t2.hp_genre,
    hp_count    = t2.hp_count,
    hp_order    = t2.hp_order,
    hp_keyword  = t2.hp_keyword
FROM (
    SELECT *
    FROM :schema.sg03002a
    WHERE
        station_name != 'all'
        AND store_type IS NULL
) t2
WHERE
    t1.station_name = t2.station_name
;


-- 4. 駅の指定があり 店タイプの指定があるものを付与
UPDATE
    :schema.sg03004a t1
SET
    hp_range    = t2.hp_range,
    hp_genre    = t2.hp_genre,
    hp_count    = t2.hp_count,
    hp_order    = t2.hp_order,
    hp_keyword  = t2.hp_keyword
FROM (
    SELECT *
    FROM :schema.sg03002a
    WHERE
        station_name != 'all'
        AND store_type IS NOT NULL
) t2
WHERE
    t1.station_name     = t2.station_name
    AND t1.store_type   = t2.store_type
;

-- トランザクション確定
COMMIT;
