-- --------------------------------------------
-- ボード別コンテンツ作成
-- --------------------------------------------

-- トランザクション開始
BEGIN;


-- 既存テーブル削除プロシージャ作成
CREATE OR REPLACE PROCEDURE drop_04008_tables(p_schema VARCHAR) AS $$
DECLARE
    C_GET_TARGET_REGEXP CONSTANT VARCHAR := 'sg04008a_[0-9]{3}';
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
CALL drop_04008_tables(:'schema');



-- テーブル作成プロシージャ作成
CREATE OR REPLACE PROCEDURE create_04008_tables(p_schema VARCHAR) AS $$
DECLARE
    C_FROM_TABLE_NAME CONSTANT VARCHAR := 'sg04007a';
    C_CREATE_TABLE_BASE_NAME CONSTANT VARCHAR := 'sg04008a';
    v_get_board_id_query VARCHAR;
    v_board_id_record RECORD;
BEGIN
    RAISE INFO 'テーブル作成開始';
    v_get_board_id_query := '
        SELECT DISTINCT
            board_id
        FROM
        ' || p_schema || '.' || C_FROM_TABLE_NAME || '
        WHERE
            create_board = ' || QUOTE_LITERAL('t') ||'
        ORDER BY
            board_id
    ';
    
    FOR v_board_id_record IN EXECUTE v_get_board_id_query LOOP
        -- @note 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
        EXECUTE '
            CREATE TABLE ' || p_schema || '.' || C_CREATE_TABLE_BASE_NAME || '_' || v_board_id_record.board_id ||' (
                board_id TEXT,
                square_number SERIAL,
                station_name TEXT,
                store_type TEXT,
                store_name TEXT,
                store_name_kana TEXT,
                store_id TEXT,
                store_catch TEXT,
                store_genre_catch TEXT,
                store_access TEXT,
                store_address TEXT,
                store_open TEXT,
                store_photo TEXT,
                PRIMARY KEY(board_id, square_number)
            )'
        ;
        RAISE INFO 'テーブル作成：%.%_%', p_schema, C_CREATE_TABLE_BASE_NAME, v_board_id_record.board_id;
    END LOOP;
    RAISE INFO 'テーブル作成完了';
END;
$$ LANGUAGE plpgsql;

-- テーブル作成プロシージャ実行
CALL create_04008_tables(:'schema');



-- テーブルデータ挿入プロシージャ作成
CREATE OR REPLACE PROCEDURE insert_04008_tables(p_schema VARCHAR) AS $$
DECLARE
    C_FROM_TABLE_NAME CONSTANT VARCHAR := 'sg04007a';
    C_INSERT_TABLE_BASE_NAME CONSTANT VARCHAR := 'sg04008a';
    C_RECORD_LIMIT CONSTANT INTEGER := 30;
    v_get_board_id_query VARCHAR;
    v_board_id_record RECORD;
BEGIN
    RAISE INFO 'テーブルデータ挿入開始';
    v_get_board_id_query := '
        SELECT DISTINCT
            board_id
        FROM
        ' || p_schema || '.' || C_FROM_TABLE_NAME || '
        WHERE
            create_board = ' || QUOTE_LITERAL('t') ||'
        ORDER BY
            board_id
    ';
    
    FOR v_board_id_record IN EXECUTE v_get_board_id_query LOOP
        -- @note 【JSON取得項目定義箇所】 取得項目に変更がある場合は、ここの指定を変更する
        EXECUTE '
            INSERT INTO ' || p_schema || '.' || C_INSERT_TABLE_BASE_NAME || '_' || v_board_id_record.board_id ||' (
                board_id,
                station_name,
                store_type,
                store_name,
                store_name_kana,
                store_id,
                store_catch,
                store_genre_catch,
                store_access,
                store_address,
                store_open,
                store_photo
            )
            SELECT
                board_id,
                station_name,
                store_type,
                store_name,
                store_name_kana,
                store_id,
                store_catch,
                store_genre_catch,
                store_access,
                store_address,
                store_open,
                store_photo
            FROM
                ' || p_schema || '.' || C_FROM_TABLE_NAME || '
            WHERE
                board_id = ' || QUOTE_LITERAL(v_board_id_record.board_id) || '
            ORDER BY
                RANDOM()
            LIMIT
                ' || C_RECORD_LIMIT || '
        ';
        RAISE INFO 'テーブルデータ挿入：%.%_%', p_schema, C_INSERT_TABLE_BASE_NAME, v_board_id_record.board_id;
    END LOOP;
    RAISE INFO 'テーブルデータ挿入完了';
END;
$$ LANGUAGE plpgsql;

-- テーブルデータ挿入プロシージャ実行
CALL insert_04008_tables(:'schema');


-- トランザクション確定
COMMIT;
