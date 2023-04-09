-- --------------------------------------------
-- 駅すぱあとデータ統合
-- --------------------------------------------

-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg03003a;

-- テーブル作成
CREATE TABLE :schema.sg03003a (
    station_name TEXT,
    store_type TEXT,
    fetch_api_data BOOLEAN,
    create_board BOOLEAN,
    station_lat TEXT,
    station_lon TEXT,
    PRIMARY KEY(station_name, store_type)
);

-- sg01002a,sg02008aのデータを結合して、sg03003aテーブルに入れる
INSERT INTO work.sg03003a (
    station_name,
    store_type,
    fetch_api_data,
    create_board,
    station_lat,
    station_lon
)
SELECT
    t1.station_name,
    t1.store_type,
    t1.fetch_api_data,
    t1.create_board,
    t2.station_lat,
    t2.station_lon
FROM
    work.sg01002a t1
LEFT OUTER JOIN
    work.sg02008a t2
ON
    t1.station_name = t2.station_name
;

-- トランザクション確定
COMMIT;
