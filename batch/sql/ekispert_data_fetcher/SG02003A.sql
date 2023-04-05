-- ------------------------------------------
-- 駅すぱあとAPI設定用データの結合・データ追加
-- ------------------------------------------

-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg02003a;

-- テーブル作成
CREATE TABLE :schema.sg02003a (
    station_name TEXT,
    store_type TEXT,
    fetch_api_data boolean,
    create_board boolean,
    station_code text,
    PRIMARY KEY(station_name, store_type)
);

-- sg02001a,sg02002aのデータを結合して、sg02003aテーブルに入れる
INSERT INTO :schema.sg02003a (
    station_name,
    store_type,
    fetch_api_data,
    create_board,
    station_code
)
SELECT
    t1.station_name,
    t1.store_type,
    t1.fetch_api_data,
    t1.create_board,
    t2.station_code
FROM
    :schema.sg01002a t1
LEFT OUTER JOIN
    :schema.sg02002a t2
ON
    t1.station_name = t2.station_name
;

-- トランザクション確定
COMMIT;
