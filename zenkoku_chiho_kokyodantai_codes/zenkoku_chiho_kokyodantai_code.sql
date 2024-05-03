create table zenkoku_chiho_kokyodantai_code (
     dantai_code     varchar(6)
    ,todofuken_kanji varchar(4)
    ,shichoson_kanji varchar(10)
    ,todofuken_kana  varchar(30)
    ,shichoson_kana  varchar(30)
) 
partition by list (todofuken_kanji)
;

create table zenkoku_chiho_kokyodantai_code_1  partition of zenkoku_chiho_kokyodantai_code for values in ('北海道');
create table zenkoku_chiho_kokyodantai_code_2  partition of zenkoku_chiho_kokyodantai_code for values in ('青森県');
create table zenkoku_chiho_kokyodantai_code_3  partition of zenkoku_chiho_kokyodantai_code for values in ('岩手県');
create table zenkoku_chiho_kokyodantai_code_4  partition of zenkoku_chiho_kokyodantai_code for values in ('宮城県');
create table zenkoku_chiho_kokyodantai_code_5  partition of zenkoku_chiho_kokyodantai_code for values in ('秋田県');
create table zenkoku_chiho_kokyodantai_code_6  partition of zenkoku_chiho_kokyodantai_code for values in ('山形県');
create table zenkoku_chiho_kokyodantai_code_7  partition of zenkoku_chiho_kokyodantai_code for values in ('福島県');
create table zenkoku_chiho_kokyodantai_code_8  partition of zenkoku_chiho_kokyodantai_code for values in ('茨城県');
create table zenkoku_chiho_kokyodantai_code_9  partition of zenkoku_chiho_kokyodantai_code for values in ('栃木県');
create table zenkoku_chiho_kokyodantai_code_10 partition of zenkoku_chiho_kokyodantai_code for values in ('群馬県');
create table zenkoku_chiho_kokyodantai_code_11 partition of zenkoku_chiho_kokyodantai_code for values in ('埼玉県');
create table zenkoku_chiho_kokyodantai_code_12 partition of zenkoku_chiho_kokyodantai_code for values in ('千葉県');
create table zenkoku_chiho_kokyodantai_code_13 partition of zenkoku_chiho_kokyodantai_code for values in ('東京都');
create table zenkoku_chiho_kokyodantai_code_14 partition of zenkoku_chiho_kokyodantai_code for values in ('神奈川県');
create table zenkoku_chiho_kokyodantai_code_15 partition of zenkoku_chiho_kokyodantai_code for values in ('新潟県');
create table zenkoku_chiho_kokyodantai_code_16 partition of zenkoku_chiho_kokyodantai_code for values in ('富山県');
create table zenkoku_chiho_kokyodantai_code_17 partition of zenkoku_chiho_kokyodantai_code for values in ('石川県');
create table zenkoku_chiho_kokyodantai_code_18 partition of zenkoku_chiho_kokyodantai_code for values in ('福井県');
create table zenkoku_chiho_kokyodantai_code_19 partition of zenkoku_chiho_kokyodantai_code for values in ('山梨県');
create table zenkoku_chiho_kokyodantai_code_20 partition of zenkoku_chiho_kokyodantai_code for values in ('長野県');
create table zenkoku_chiho_kokyodantai_code_21 partition of zenkoku_chiho_kokyodantai_code for values in ('岐阜県');
create table zenkoku_chiho_kokyodantai_code_22 partition of zenkoku_chiho_kokyodantai_code for values in ('静岡県');
create table zenkoku_chiho_kokyodantai_code_23 partition of zenkoku_chiho_kokyodantai_code for values in ('愛知県');
create table zenkoku_chiho_kokyodantai_code_24 partition of zenkoku_chiho_kokyodantai_code for values in ('三重県');
create table zenkoku_chiho_kokyodantai_code_25 partition of zenkoku_chiho_kokyodantai_code for values in ('滋賀県');
create table zenkoku_chiho_kokyodantai_code_26 partition of zenkoku_chiho_kokyodantai_code for values in ('京都府');
create table zenkoku_chiho_kokyodantai_code_27 partition of zenkoku_chiho_kokyodantai_code for values in ('大阪府');
create table zenkoku_chiho_kokyodantai_code_28 partition of zenkoku_chiho_kokyodantai_code for values in ('兵庫県');
create table zenkoku_chiho_kokyodantai_code_29 partition of zenkoku_chiho_kokyodantai_code for values in ('奈良県');
create table zenkoku_chiho_kokyodantai_code_30 partition of zenkoku_chiho_kokyodantai_code for values in ('和歌山県');
create table zenkoku_chiho_kokyodantai_code_31 partition of zenkoku_chiho_kokyodantai_code for values in ('鳥取県');
create table zenkoku_chiho_kokyodantai_code_32 partition of zenkoku_chiho_kokyodantai_code for values in ('島根県');
create table zenkoku_chiho_kokyodantai_code_33 partition of zenkoku_chiho_kokyodantai_code for values in ('岡山県');
create table zenkoku_chiho_kokyodantai_code_34 partition of zenkoku_chiho_kokyodantai_code for values in ('広島県');
create table zenkoku_chiho_kokyodantai_code_35 partition of zenkoku_chiho_kokyodantai_code for values in ('山口県');
create table zenkoku_chiho_kokyodantai_code_36 partition of zenkoku_chiho_kokyodantai_code for values in ('徳島県');
create table zenkoku_chiho_kokyodantai_code_37 partition of zenkoku_chiho_kokyodantai_code for values in ('香川県');
create table zenkoku_chiho_kokyodantai_code_38 partition of zenkoku_chiho_kokyodantai_code for values in ('愛媛県');
create table zenkoku_chiho_kokyodantai_code_39 partition of zenkoku_chiho_kokyodantai_code for values in ('高知県');
create table zenkoku_chiho_kokyodantai_code_40 partition of zenkoku_chiho_kokyodantai_code for values in ('福岡県');
create table zenkoku_chiho_kokyodantai_code_41 partition of zenkoku_chiho_kokyodantai_code for values in ('佐賀県');
create table zenkoku_chiho_kokyodantai_code_42 partition of zenkoku_chiho_kokyodantai_code for values in ('長崎県');
create table zenkoku_chiho_kokyodantai_code_43 partition of zenkoku_chiho_kokyodantai_code for values in ('熊本県');
create table zenkoku_chiho_kokyodantai_code_44 partition of zenkoku_chiho_kokyodantai_code for values in ('大分県');
create table zenkoku_chiho_kokyodantai_code_45 partition of zenkoku_chiho_kokyodantai_code for values in ('宮崎県');
create table zenkoku_chiho_kokyodantai_code_46 partition of zenkoku_chiho_kokyodantai_code for values in ('鹿児島県');
create table zenkoku_chiho_kokyodantai_code_47 partition of zenkoku_chiho_kokyodantai_code for values in ('沖縄県');
