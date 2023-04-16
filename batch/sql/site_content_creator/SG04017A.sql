-- ------------------------------------------
-- コンテンツデータJSON出力
-- ------------------------------------------

-- 処理対象指定
\set from_table_name    'sg04016a'
\set column_list        'boards_data'
\set to_json_path       :tmp_content_data_json


-- トランザクション開始
BEGIN;

-- 出力コマンド組立・実行 (ファイル種別指定なし／列指定あり／ヘッダーなし)
\set exportcmd  '\\COPY (SELECT ':column_list' FROM ':schema'.':from_table_name') TO \'':to_json_path'\''
:exportcmd

-- トランザクション確定
COMMIT;
