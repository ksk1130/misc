/* CREATE DATABASE rs_testdb LCCOLLATE 'ja_JP.UTF-8' LC_CTYPE 'ja_JP.UTF-8' ENCODING 'UTF8' TEMPLATE template0; */
CREATE DATABASE rs_testdb ENCODING 'UTF8';

SELECT * FROM pg_database where datname = 'rs_testdb';
