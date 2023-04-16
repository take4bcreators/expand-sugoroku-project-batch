-- ------------------------------------------
-- ミニゲームデータJSON作成
-- ------------------------------------------

-- トランザクション開始
BEGIN;


-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg04019a;


-- テーブル作成
CREATE TABLE :schema.sg04019a (
    minigame_data jsonb
);


-- データ挿入
-- @note 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
INSERT INTO :schema.sg04019a (
    minigame_data
)
WITH json_build_01 AS (
-- 1. NULL を 空文字 に置換して、JSONのキー名を設定するためにカラム名を変更
    SELECT
        minigame_id                     AS id,
        COALESCE(minigame_name, '')     AS name,
        COALESCE(minigame_detail, '')   AS detail
    FROM
        :schema.sg04004a
)
-- 2. 全体 の JSON配列化
SELECT
    JSONB_AGG(json_build_01) AS minigame_data
FROM
    json_build_01
;

-- トランザクション確定
COMMIT;
