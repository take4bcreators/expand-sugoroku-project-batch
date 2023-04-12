-- --------------------------------------------
-- ボードイベントミニゲーム情報統合
-- --------------------------------------------

-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg04005a;

-- テーブル作成
CREATE TABLE :schema.sg04005a (
    data_seq SERIAL,
    event_name TEXT,
    event_detail TEXT,
    point INTEGER,
    skip INTEGER,
    move INTEGER,
    minigame_id TEXT,
    level TEXT,
    minigame_name TEXT,
    minigame_detail TEXT,
    PRIMARY KEY(data_seq)
);


-- sg04002a, sg04004a のデータを結合して、sg04005aテーブルに入れる
INSERT INTO :schema.sg04005a (
    data_seq,
    event_name,
    event_detail,
    point,
    skip,
    move,
    minigame_id,
    level,
    minigame_name,
    minigame_detail
)
SELECT
    t1.data_seq,
    t1.event_name,
    t1.event_detail,
    t1.point,
    t1.skip,
    t1.move,
    t1.minigame_id,
    t1.level,
    t2.minigame_name,
    t2.minigame_detail
FROM
    :schema.sg04002a t1
LEFT OUTER JOIN
    :schema.sg04004a t2
ON
    t1.minigame_id = t2.minigame_id
;

-- トランザクション確定
COMMIT;
