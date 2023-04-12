-- --------------------------------------------
-- ボード別コンテンツボードイベント付与
-- --------------------------------------------

-- トランザクション開始
BEGIN;


-- 既存テーブル削除プロシージャ作成
CREATE OR REPLACE PROCEDURE drop_04009_tables(p_schema VARCHAR) AS $$
DECLARE
    C_GET_TARGET_REGEXP CONSTANT VARCHAR := 'sg04009a_[0-9]{3}';
    v_get_drop_tables_query VARCHAR;
    v_drop_tables RECORD;
BEGIN
    RAISE INFO '既存テーブル削除開始';
    v_get_drop_tables_query := '
        SELECT DISTINCT
            tablename
        FROM
            pg_tables
        WHERE
            schemaname = ' || QUOTE_LITERAL(p_schema)
        || ' AND tablename ~ ' || QUOTE_LITERAL(C_GET_TARGET_REGEXP)
    ;
    
    FOR v_drop_tables IN EXECUTE v_get_drop_tables_query LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || p_schema || '.' || v_drop_tables.tablename;
        RAISE INFO '既存テーブル削除：%.%', p_schema, v_drop_tables.tablename;
    END LOOP;
    RAISE INFO '既存テーブル削除完了';
END;
$$ LANGUAGE plpgsql;

-- 既存テーブル削除プロシージャ実行
CALL drop_04009_tables(:'schema');



-- テーブル作成プロシージャ作成
CREATE OR REPLACE PROCEDURE create_04009_tables(p_schema VARCHAR) AS $$
DECLARE
    C_GET_BOARD_ID_TABLE_NAME CONSTANT VARCHAR := 'sg04007a';
    C_CREATE_TABLE_BASE_NAME CONSTANT VARCHAR := 'sg04009a';
    v_get_board_id_query VARCHAR;
    v_board_id_record RECORD;
BEGIN
    RAISE INFO 'テーブル作成開始';
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
        EXECUTE '
            CREATE TABLE ' || p_schema || '.' || C_CREATE_TABLE_BASE_NAME || '_' || v_board_id_record.board_id || ' (
                board_id TEXT,
                square_number INTEGER,
                level TEXT,
                level_square_number INTEGER,
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
                point INTEGER,
                skip INTEGER,
                move INTEGER,
                minigame_id TEXT,
                minigame_name TEXT,
                minigame_detail TEXT,
                level_event_number INTEGER,
                level_event_count INTEGER,
                PRIMARY KEY(board_id, square_number)
            )'
        ;
        RAISE INFO 'テーブル作成：%.%_%', p_schema, C_CREATE_TABLE_BASE_NAME, v_board_id_record.board_id;
    END LOOP;
    RAISE INFO 'テーブル作成完了';
END;
$$ LANGUAGE plpgsql;

-- テーブル作成プロシージャ実行
CALL create_04009_tables(:'schema');



-- テーブルデータ挿入プロシージャ作成
CREATE OR REPLACE PROCEDURE insert_04009_tables(p_schema VARCHAR) AS $$
DECLARE
    C_GET_BOARD_ID_TABLE_NAME CONSTANT VARCHAR := 'sg04007a';
    C_FROM_LEFT_TABLE_BASE_NAME CONSTANT VARCHAR := 'sg04008a';
    C_FROM_RIGHT_TABLE_NAME CONSTANT VARCHAR := 'sg04005a';
    C_INSERT_TABLE_BASE_NAME CONSTANT VARCHAR := 'sg04009a';
    v_get_board_id_query VARCHAR;
    v_board_id_record RECORD;
BEGIN
    RAISE INFO 'テーブルデータ挿入開始';
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
        EXECUTE '
            INSERT INTO ' || p_schema || '.' || C_INSERT_TABLE_BASE_NAME || '_' || v_board_id_record.board_id ||' (
                board_id,
                square_number,
                level,
                level_square_number,
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
                point,
                skip,
                move,
                minigame_id,
                minigame_name,
                minigame_detail,
                level_event_number,
                level_event_count
            )
            WITH sg04008a_tmp01 AS (
                -- sg04008a 側にレベルを付与
                SELECT
                    board_id,
                    square_number,
                    TO_CHAR(NTILE(3) OVER(ORDER BY square_number) - 1, ' || QUOTE_LITERAL('FM999') || ') AS level,
                    station_name,
                    store_type,
                    store_name,
                    store_id,
                    store_access,
                    store_address,
                    store_open,
                    store_photo
                FROM
                    ' || p_schema || '.' || C_FROM_LEFT_TABLE_BASE_NAME || '_' || v_board_id_record.board_id || '
            )
            , sg04008a_tmp02 AS (
                -- sg04008a 側にレベル別のマス番号を付与
                SELECT
                    board_id,
                    square_number,
                    level,
                    ROW_NUMBER() OVER(
                        PARTITION BY level
                        ORDER BY square_number
                    ) AS level_square_number,
                    station_name,
                    store_type,
                    store_name,
                    store_id,
                    store_access,
                    store_address,
                    store_open,
                    store_photo
                FROM
                    sg04008a_tmp01
            )
            , sg04005a_tmp01 AS (
                -- sg04005a 側にレベル別のイベント番号とレベル別のイベント件数を付与
                SELECT
                    event_name,
                    event_detail,
                    point,
                    skip,
                    move,
                    minigame_id,
                    level,
                    minigame_name,
                    minigame_detail,
                    ROW_NUMBER() OVER(
                        PARTITION BY level
                        ORDER BY RANDOM()
                    ) AS level_event_number,
                    COUNT(*) OVER(
                        PARTITION BY level
                    ) AS level_event_count
                FROM
                    ' || p_schema || '.' || C_FROM_RIGHT_TABLE_NAME || '
            )
            SELECT
                t1.board_id,
                t1.square_number,
                t1.level,
                t1.level_square_number,
                t1.station_name,
                t1.store_type,
                t1.store_name,
                t1.store_id,
                t1.store_access,
                t1.store_address,
                t1.store_open,
                t1.store_photo,
                t2.event_name,
                t2.event_detail,
                t2.point,
                t2.skip,
                t2.move,
                t2.minigame_id,
                t2.minigame_name,
                t2.minigame_detail,
                t2.level_event_number,
                t2.level_event_count
            FROM
                sg04008a_tmp02 t1
            LEFT OUTER JOIN
                sg04005a_tmp01 t2
            ON
                t1.level = t2.level
                AND (MOD(t1.level_square_number, t2.level_event_count) + 1) = t2.level_event_number
            ORDER BY
                square_number
        ';
        RAISE INFO 'テーブルデータ挿入：%.%_%', p_schema, C_INSERT_TABLE_BASE_NAME, v_board_id_record.board_id;
    END LOOP;
    RAISE INFO 'テーブルデータ挿入完了';
END;
$$ LANGUAGE plpgsql;

-- テーブルデータ挿入プロシージャ実行
CALL insert_04009_tables(:'schema');


-- トランザクション確定
COMMIT;
