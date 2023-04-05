-- ------------------------------------------
-- 駅すぱあとAPI設定用CSVファイル取り込み
-- ------------------------------------------

-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg02004a;

-- テーブル作成
CREATE TABLE :schema.sg02004a (
    station_name TEXT,
    station_code text,
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
;

-- トランザクション確定
COMMIT;
