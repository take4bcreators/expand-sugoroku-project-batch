-- --------------------------------------------
-- ホットペッパーデータ統合
-- --------------------------------------------

-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg04006a;

-- テーブル作成
-- 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
CREATE TABLE :schema.sg04006a (
    station_name TEXT,
    store_type TEXT,
    fetch_api_data BOOLEAN,
    create_board BOOLEAN,
    store_name TEXT,
    store_id TEXT,
    store_access TEXT,
    store_address TEXT,
    store_open TEXT,
    store_photo TEXT,
    PRIMARY KEY(station_name, store_type, store_id)
);

-- sg01002a, sg03008a のデータを結合して、sg04006a テーブルに入れる
-- 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
INSERT INTO :schema.sg04006a (
    station_name,
    store_type,
    fetch_api_data,
    create_board,
    store_name,
    store_id,
    store_access,
    store_address,
    store_open,
    store_photo
)
SELECT
    t1.station_name,
    t1.store_type,
    t1.fetch_api_data,
    t1.create_board,
    t2.store_name,
    COALESCE(t2.store_id, '') AS store_id,  -- PKになるので万が一取得データにIDがなかった時の為に空文字を挿入
    t2.store_access,
    t2.store_address,
    t2.store_open,
    t2.store_photo
FROM
    :schema.sg01002a t1
LEFT OUTER JOIN
    :schema.sg03008a t2
ON
    t1.station_name     = t2.station_name
    AND t1.store_type   = t2.store_type
;

-- トランザクション確定
COMMIT;
