
-- トランザクション開始
BEGIN;

-- テーブル削除
DROP TABLE IF EXISTS :schema.animal_dummy2;

-- テーブル作成
CREATE TABLE :schema.animal_dummy2 (
    animal_No TEXT,
    animal_name TEXT,
    seibetu TEXT,
    anniversary TEXT,
    company TEXT,
    create_date DATE,
    comment INTEGER,
    PRIMARY KEY(animal_No)
);

-- トランザクション確定
COMMIT;
