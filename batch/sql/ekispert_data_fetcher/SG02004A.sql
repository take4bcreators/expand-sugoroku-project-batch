-- ------------------------------------------
-- 駅すぱあと取得対象 データ抽出
-- ------------------------------------------

-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg02004a;

-- テーブル作成
CREATE TABLE :schema.sg02004a (
    station_name TEXT,
    station_code TEXT,
    PRIMARY KEY(station_name)
);

-- sg02004aテーブルにsg02003aのデータを入れる ※データが重複した場合は削除
INSERT INTO :schema.sg02004a(
    station_name,
    station_code
)
SELECT DISTINCT
    station_name,
    station_code
FROM
    :schema.sg02003a
WHERE
    fetch_api_data = 't'
;

-- トランザクション確定
COMMIT;
