
# 通常の指定
psql -d sgpjdb01 -f test001.sql;echo $?
psql -d sgpjdb01 -f test002.sql;echo $?
psql -d sgpjdb01 -f test003.sql;echo $?
psql -d sgpjdb01 -f test004.sql;echo $?
psql -d sgpjdb01 -f test005.sql;echo $?
psql -d sgpjdb01 -f test006.sql;echo $?
psql -d sgpjdb01 -f test007.sql;echo $?

# 「ON_ERROR_STOP」を有効にした際の指定
psql -d sgpjdb01 --set ON_ERROR_STOP=on -f test001.sql;echo $?
psql -d sgpjdb01 --set ON_ERROR_STOP=on -f test002.sql;echo $?
psql -d sgpjdb01 --set ON_ERROR_STOP=on -f test003.sql;echo $?
psql -d sgpjdb01 --set ON_ERROR_STOP=on -f test004.sql;echo $?
psql -d sgpjdb01 --set ON_ERROR_STOP=on -f test005.sql;echo $?
psql -d sgpjdb01 --set ON_ERROR_STOP=on -f test006.sql;echo $?
psql -d sgpjdb01 --set ON_ERROR_STOP=on -f test007.sql;echo $?

