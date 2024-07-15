select
    coalesce(a.parent_table_name,pg_class.relname) parent_table_name
   ,sum(pg_class.reltuples) total_row_num
   ,sum((pg_class.relpages * 8192)) bytes
from
    pg_class left outer join
       (select
            pg_par.relname parent_table_name
           ,pg_chi.relname child_table_name
        from
            pg_inherits inh
                inner join pg_class pg_par on inh.inhparent = pg_par.oid
                inner join pg_class pg_chi on inh.inhrelid  = pg_chi.oid
        order by
            parent_table_name
           ,child_table_name
        ) a
    on pg_class.relname = a.child_table_name
where
    pg_class.relname like 'zenkoku%'
group by
    coalesce(a.parent_table_name,pg_class.relname)
;
