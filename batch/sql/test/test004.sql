
-- トランザクション開始
BEGIN;

-- テーブル作成
CREATE TABLE work.animal_dummy3 (
    animal_No TEXT,
    animal_name TEXT,
    seibetu TEXT,
    anniversary TEXT,
    company TEXT,
    create_date DATE,
    comment INTEGER,
    PRIMARY KEY(animal_No)
);

-- セレクト
SELECT COUNT(*)
FROM work.animal_dummy3
;

-- トランザクション確定
COMMIT;
