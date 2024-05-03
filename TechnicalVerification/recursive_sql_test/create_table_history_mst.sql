create table history_mst(
    history_ym varchar(6) not null
   ,fruit_code varchar(4) not null
   ,fruit_name varchar(10)
   ,next_code  varchar(4)
);

insert into history_mst values('202004','0001','リンゴ','0100');
insert into history_mst values('202004','0002','ミカン',null);
insert into history_mst values('202004','0003','ブドウ',null);
insert into history_mst values('202005','0001','リンゴ','0100');
insert into history_mst values('202005','0002','ミカン',null);
insert into history_mst values('202005','0003','ブドウ',null);
insert into history_mst values('202006','0001','リンゴ','0100');
insert into history_mst values('202006','0002','ミカン',null);
insert into history_mst values('202006','0003','ブドウ',null);
insert into history_mst values('202007','0001','リンゴ','0100');
insert into history_mst values('202007','0002','ミカン',null);
insert into history_mst values('202007','0003','ブドウ',null);
insert into history_mst values('202008','0100','リンゴ','0101');
insert into history_mst values('202008','0002','ミカン',null);
insert into history_mst values('202008','0003','ブドウ',null);
insert into history_mst values('202009','0101','リンゴ',null);
insert into history_mst values('202009','0002','ミカン',null);
insert into history_mst values('202009','0003','ブドウ',null);
insert into history_mst values('202010','0101','リンゴ',null);
insert into history_mst values('202010','0002','ミカン',null);
insert into history_mst values('202010','0003','ブドウ',null);

