-- ------------------------------------------
-- アプリ設定用CSVファイル取り込み
-- ------------------------------------------

-- 処理対象指定
\set from_table_name    'sg02001a'
\set column_list        'station_name, ekispert_code'
\set to_csv_path        :tmp_ekispert_request_csv


-- トランザクション開始
BEGIN;

-- 出力コマンド組立・実行 (CSV／列指定あり／ヘッダーなし)
\set exportcmd  '\\COPY (SELECT ':column_list' FROM ':schema'.':from_table_name') TO \'':to_csv_path'\' WITH CSV'
:exportcmd

-- トランザクション確定
COMMIT;
