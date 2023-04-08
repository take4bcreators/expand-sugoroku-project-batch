-- ------------------------------------------
-- ホットペッパーAPI実行用CSV出力
-- ------------------------------------------

-- 処理対象指定
\set from_table_name    'sg03004a'
\set column_list        'station_name, store_type, station_lat, station_lon, hp_range, hp_genre, hp_count, hp_order, hp_keyword'
\set to_csv_path        :tmp_hotpepper_request_csv


-- トランザクション開始
BEGIN;

-- 出力コマンド組立・実行 (CSV／列指定あり／ヘッダーなし)
\set exportcmd  '\\COPY (SELECT ':column_list' FROM ':schema'.':from_table_name') TO \'':to_csv_path'\' WITH CSV'
:exportcmd

-- トランザクション確定
COMMIT;
