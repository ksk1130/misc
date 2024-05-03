create external table spectrum_schema.varchar_test_rs (
  id int4 ,
  varchar_col varchar(40) 
)
row format              delimited
fields terminated by    ','
stored as               textfile
location                's3://<bucket>/<path>'
;
