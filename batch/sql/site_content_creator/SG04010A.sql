-- --------------------------------------------
-- ボードコンテンツ統合
-- --------------------------------------------

-- トランザクション開始
BEGIN;

-- 既存テーブル削除
DROP TABLE IF EXISTS :schema.sg04010a;

-- テーブル作成
-- 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
CREATE TABLE :schema.sg04010a (
    board_id TEXT,
    square_number INTEGER,
    station_name TEXT,
    store_type TEXT,
    store_name TEXT,
    store_id TEXT,
    store_access TEXT,
    store_address TEXT,
    store_open TEXT,
    store_photo TEXT,
    event_name TEXT,
    event_detail TEXT,
    event_point INTEGER,
    event_skip INTEGER,
    event_move INTEGER,
    minigame_id TEXT,
    minigame_name TEXT,
    minigame_detail TEXT,
    PRIMARY KEY(board_id, square_number)
);


-- テーブルデータ挿入プロシージャ作成
CREATE OR REPLACE PROCEDURE insert_04010_table(p_schema VARCHAR) AS $$
DECLARE
    C_GET_BOARD_ID_TABLE_NAME CONSTANT VARCHAR := 'sg04007a';
    C_FROM_TABLE_BASE_NAME CONSTANT VARCHAR := 'sg04009a';
    C_INSERT_TABLE_NAME CONSTANT VARCHAR := 'sg04010a';
    v_get_board_id_query VARCHAR;
    v_board_id_record RECORD;
BEGIN
    RAISE INFO 'テーブルデータ挿入開始';
    RAISE INFO 'テーブルデータ挿入先：%.%', p_schema, C_INSERT_TABLE_NAME;
    v_get_board_id_query := '
        SELECT DISTINCT
            board_id
        FROM
        ' || p_schema || '.' || C_GET_BOARD_ID_TABLE_NAME || '
        WHERE
            create_board = ' || QUOTE_LITERAL('t') || '
        ORDER BY
            board_id
    ';
    
    FOR v_board_id_record IN EXECUTE v_get_board_id_query LOOP
        -- 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
        EXECUTE '
            INSERT INTO ' || p_schema || '.' || C_INSERT_TABLE_NAME ||' (
                board_id,
                square_number,
                station_name,
                store_type,
                store_name,
                store_id,
                store_access,
                store_address,
                store_open,
                store_photo,
                event_name,
                event_detail,
                event_point,
                event_skip,
                event_move,
                minigame_id,
                minigame_name,
                minigame_detail
            )
            SELECT
                board_id,
                square_number,
                station_name,
                store_type,
                store_name,
                store_id,
                store_access,
                store_address,
                store_open,
                store_photo,
                event_name,
                event_detail,
                event_point,
                event_skip,
                event_move,
                minigame_id,
                minigame_name,
                minigame_detail
            FROM
                ' || p_schema || '.' || C_FROM_TABLE_BASE_NAME || '_' || v_board_id_record.board_id || '
        ';
        RAISE INFO 'テーブルデータ挿入元：%.%_%', p_schema, C_FROM_TABLE_BASE_NAME, v_board_id_record.board_id;
    END LOOP;
    RAISE INFO 'テーブルデータ挿入完了';
END;
$$ LANGUAGE plpgsql;

-- テーブルデータ挿入プロシージャ実行
CALL insert_04010_table(:'schema');


-- トランザクション確定
COMMIT;
