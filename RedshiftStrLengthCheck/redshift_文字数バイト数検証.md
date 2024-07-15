1. Redshift, RedshiftSpectrum, EMR, Athenaはそれぞれ「文字数指定」か、「バイト数」指定か
   1. 準備
      1. ~~4バイト、3バイト混在データの準備~~
      2. ~~S3フォルダの準備~~
      3. ~~S3へのデータ投入~~
      4. ~~DDLの準備~~
         1. ~~Athena(Athena,RedshiftSpectrum,EMR)~~
            1. varchar指定
            2. text指定
         2. ~~Redshift~~
            1. ~~文字列長Ver~~
            2. ~~バイト長Ver~~
      5. ~~DB作成(Redshift)~~
      6. ~~テーブル作成~~
         1. ~~Athena~~
         2. ~~Redshift~~
      7. ~~Spectrum準備~~
         
         1. ~~スキーマ作成~~
         
            1. ```sql
               create external schema spectrum_schema from data catalog 
               database 'testdb' 
               iam_role 'arn:aws:iam::999999999999:role/RedshiftSpectrumRole'
               region 'ap-northeast-1';
               ```
      8. ~~Redshift準備~~
         1. ~~copy文準備~~
         
            1. ```sql
               copy varchar_test_rs from 's3://targetbucket/varchar_test/data/' 
               iam_role 'arn:aws:iam::999999999999:role/RedshiftSpectrumRole' delimiter ',';
               ```
         
         2. RedshiftSpectrum向けのテーブル定義作成(varchar指定)
         
            1. ```sql
               create external table spectrum_schema.varchar_test_rs (
                 id int4 ,
                 varchar_col varchar(40) 
               )
               row format              delimited
               fields terminated by    ','
               stored as               textfile
               location                's3://targetbucket/varchar_test/data/'
               ;
               ```
      
   2. 検証
   
      1. ~~Athena(Varchar)~~
         
         1. ~~Select 混在ファイル~~
         
            1. 		select * from varchar_test;
               	id	varchar_col
               	1	1234567890
               	2	一二三
               	3	一𪘂𪗱
               	4	一二三四
               	5	一二三四五六七八九十
               	6	𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄
               	7	1234567890
               	8	一二三四五六七八九十
               	9	𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄
         
         2. ~~文字列長~~
         
            1. 		select id,varchar_col,length(varchar_col) from varchar_test;
               	1	1234567890	10
               	2	一二三	3
               	3	一𪘂𪗱	3
               	4	一二三四	4
            	5	一二三四五六七八九十	10
               	6	𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄	10
               	7	1234567890	10
               	8	一二三四五六七八九十	10
               	9	𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄	10
      
         3. ~~バイト長~~
      
            1. ~~octet_lengthに相当する関数がないため実施なし~~
            
         4. ~~substring~~
         
            1. 		select id,varchar_col,substring(varchar_col,1,2) from varchar_test;
               	1	1234567890	12
               	2	一二三	一二
               	3	一𪘂𪗱	一𪘂
               	4	一二三四	一二
            	5	一二三四五六七八九十	一二
               	6	𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄	𠀋𡈽
            	7	1234567890	12
               	8	一二三四五六七八九十	一二
               	9	𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄	𠀋𡈽
         
      2. Athena(text)
         
         1. Select 混在ファイル
         2. 文字列長
         3. バイト長
         4. substring
         
   3. ~~Redshift~~
   
      1. ~~Copy~~
   
            1. ```sql
               copy varchar_test_rs from 's3://targetbucket/varchar_test/data/' 
               iam_role 'arn:aws:iam::999999999999:role/RedshiftSpectrumRole' delimiter ',';
               ```
   
         2. ~~Select混在ファイル~~
   
            1. ```sql
               select * from varchar_test_rs;
                id |      varchar_col
               ----+------------------------
                 1 | 1234567890
                 2 | 一二三
                 3 | 一𪘂𪗱
                 4 | 一二三四
                 5 | 一二三四五六七八九十
                 6 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄
                 7 | 12345678901
                 8 | 一二三四五六七八九十一
                 9 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄𣜿
               ```
   
         3. ~~文字列長~~
   
            1. 	select id,varchar_col,length(varchar_col) from varchar_test_rs;
               	 id |      varchar_col       | length
               	----+------------------------+--------
               	  1 | 1234567890             |     10
               	  2 | 一二三                 |      3
               	  3 | 一𪘂𪗱                 |      3
               	  4 | 一二三四               |      4
               	  5 | 一二三四五六七八九十   |     10
               	  6 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄   |     10
               	  7 | 12345678901            |     11
               	  8 | 一二三四五六七八九十一 |     11
               	  9 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄𣜿 |     11
   
         4. ~~バイト長~~
   
            1. ```sql
               select id,varchar_col,octet_length(varchar_col) from  spectrum_schema.varchar_test_rs;
                id |      varchar_col       | octet_length
               ----+------------------------+--------------
                 1 | 1234567890             |           10
                 2 | 一二三                 |            9
                 3 | 一𪘂𪗱                 |           11
                 4 | 一二三四               |           12
                 5 | 一二三四五六七八九十   |           30
                 6 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄   |           40
                 7 | 12345678901            |           11
                 8 | 一二三四五六七八九十一 |           33
                 9 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄   |           40
               ```
   
         5. ~~substring~~
   
            1. ```sql
               select id,varchar_col,substring(varchar_col,1,2) from varchar_test_rs;
                id |      varchar_col       | substring
               ----+------------------------+-----------
                 1 | 1234567890             | 12
                 2 | 一二三                 | 一二
                 3 | 一𪘂𪗱                 | 一𪘂
                 4 | 一二三四               | 一二
                 5 | 一二三四五六七八九十   | 一二
                 6 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄   | 𠀋𡈽
                 7 | 12345678901            | 12
                 8 | 一二三四五六七八九十一 | 一二
                 9 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄𣜿 | 𠀋𡈽
               ```
   
      4. ~~RedshiftSpectrum(Glueのテーブル定義をそのまま利用,Varchar)~~
   
         1. ~~Select混在ファイル~~
   
            1. ```sql
               select * from spectrum_schema.varchar_test;
               id | varchar_col
               ---+-------------
                1 | 1234567890
                2 | 一二三
                3 | 一𪘂
                4 | 一二三
                5 | 一二三
                6 | 𠀋𡈽
                7 | 1234567890
                8 | 一二三
                9 | 𠀋𡈽
               ```
   
         2. ~~文字列長~~
   
            1. ```sql
               select id,varchar_col,length(varchar_col) from spectrum_schema.varchar_test;
                id | varchar_col | length
               ----+-------------+--------
                 1 | 1234567890  |     10
                 2 | 一二三      |      3
                 3 | 一𪘂        |      2
                 4 | 一二三      |      3
                 5 | 一二三      |      3
                 6 | 𠀋𡈽        |      2
                 7 | 1234567890  |     10
                 8 | 一二三      |      3
                 9 | 𠀋𡈽        |      2
               ```
   
         3. ~~バイト長~~
   
            1. ```sql
               select id,varchar_col,octet_length(varchar_col) from varchar_test_rs;
                id |      varchar_col       | octet_length
               ----+------------------------+--------------
                 1 | 1234567890             |           10
                 2 | 一二三                 |            9
                 3 | 一𪘂𪗱                 |           11
                 4 | 一二三四               |           12
                 5 | 一二三四五六七八九十   |           30
                 6 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄   |           40
                 7 | 12345678901            |           11
                 8 | 一二三四五六七八九十一 |           33
                 9 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄𣜿 |           44
               ```
   
         4. ~~substring~~
   
            1. 	select id,varchar_col,substring(varchar_col,1,2) from spectrum_schema.varchar_test;
               	 id | varchar_col | substring
               	----+-------------+-----------
               	  1 | 1234567890  | 12
               	  2 | 一二三      | 一二
               	  3 | 一𪘂        | 一𪘂
               	  4 | 一二三      | 一二
               	  5 | 一二三      | 一二
               	  6 | 𠀋𡈽        | 𠀋𡈽
               	  7 | 1234567890  | 12
               	  8 | 一二三      | 一二
               	  9 | 𠀋𡈽        | 𠀋𡈽
   
      5. RedshiftSpectrum(Glueのテーブル定義をそのまま利用,Text)
   
         1. Select混在ファイル
         2. 文字列長
         3. バイト長
         4. substring
   
      6. ~~RedshiftSpectrum(Spectrum用の定義を利用,Varchar)~~
   
         1. ~~Select混在ファイル~~
   
            1. ```sql
               select * from spectrum_schema.varchar_test_rs;
                id |      varchar_col
               ----+------------------------
                 1 | 1234567890
                 2 | 一二三
                 3 | 一𪘂𪗱
                 4 | 一二三四
                 5 | 一二三四五六七八九十
                 6 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄
                 7 | 12345678901
                 8 | 一二三四五六七八九十一
                 9 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄
               ```
   
         2. ~~文字列長~~
   
            1. ```sql
               select id,varchar_col,length(varchar_col) from spectrum_schema.varchar_test_rs;
                id |      varchar_col       | length
               ----+------------------------+--------
                 1 | 1234567890             |     10
                 2 | 一二三                 |      3
                 3 | 一𪘂𪗱                 |      3
                 4 | 一二三四               |      4
                 5 | 一二三四五六七八九十   |     10
                 6 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄   |     10
                 7 | 12345678901            |     11
                 8 | 一二三四五六七八九十一 |     11
                 9 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄   |     10
               ```
   
         3. ~~バイト長~~
   
            1. ```sql
               select id,varchar_col,octet_length(varchar_col) from  spectrum_schema.varchar_test_rs;
                id |      varchar_col       | octet_length
               ----+------------------------+--------------
                 1 | 1234567890             |           10
                 2 | 一二三                 |            9
                 3 | 一𪘂𪗱                 |           11
                 4 | 一二三四               |           12
                 5 | 一二三四五六七八九十   |           30
                 6 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄   |           40
                 7 | 12345678901            |           11
                 8 | 一二三四五六七八九十一 |           33
                 9 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄   |           40
               ```
   
         4. ~~substring~~
   
            1. ```sql
               select id,varchar_col,substring(varchar_col,1,2) from spectrum_schema.varchar_test_rs;
                id |      varchar_col       | substring
               ----+------------------------+-----------
                 1 | 1234567890             | 12
                 2 | 一二三                 | 一二
                 3 | 一𪘂𪗱                 | 一𪘂
                 4 | 一二三四               | 一二
                 5 | 一二三四五六七八九十   | 一二
                 6 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄   | 𠀋𡈽
                 7 | 12345678901            | 12
                 8 | 一二三四五六七八九十一 | 一二
                 9 | 𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄   | 𠀋𡈽
               ```
   
      7. ~~EMR~~
   
         1. ~~desc~~
   
            1. 	```sql
               	＞ desc varchar_test;
               	id      int     NULL
               	varchar_col     string  NULL
               ```
   
         2. ~~Select混在ファイル~~
   
            1. 	```sql
               select * from varchar_test;
               1       1234567890
               2       一二三
               3       一𪘂𪗱
               4       一二三四
               5       一二三四五六七八九十
               6       𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄
               7       1234567890
               8       一二三四五六七八九十
               9       𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄
               ```
   
         3. ~~文字列長~~
   
            1. 	```sql
               select id,varchar_col,length(varchar_col) from varchar_test;
               1       1234567890      10
               2       一二三  3
               3       一𪘂𪗱  3
               4       一二三四        4
               5       一二三四五六七八九十    10
               6       𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄    10
               7       1234567890      10
               8       一二三四五六七八九十    10
               9       𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄    10
               ```
   
         4. ~~バイト長(SQL側)~~
   
            1. ```sql
               select id,varchar_col,octet_length(varchar_col) from varchar_test;
               1       1234567890      10
               2       一二三  9
               3       一𪘂𪗱  11
               4       一二三四        12
               5       一二三四五六七八九十    30
               6       𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄    40
               7       1234567890      10
               8       一二三四五六七八九十    30
               9       𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄    40
               ```
            
         5. ~~substring(SQL側)~~
   
            1. 	```sql
               select id,varchar_col,substring(varchar_col,1,2) from varchar_test;
               1       1234567890      12
               2       一二三  一二
               3       一𪘂𪗱  一𪘂
               4       一二三四        一二
               5       一二三四五六七八九十    一二
               6       𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄    𠀋𡈽
               7       1234567890      12
               8       一二三四五六七八九十    一二
               9       𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄    𠀋𡈽
               ```