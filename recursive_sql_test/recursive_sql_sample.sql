WITH RECURSIVE fruit_hierarchy AS (
  SELECT 
        hm.fruit_code as fruit_code 
          FROM 
                history_mst hm 
                  WHERE 
                        hm.fruit_code = '0101'
                          UNION ALL
                                 SELECT 
                                            hm2.fruit_code 
                                                   from
                                                             history_mst hm2, fruit_hierarchy 
                                                                    where
                                                                               hm2.next_code = fruit_hierarchy.fruit_code
                                                                               )
SELECT * FROM history_mst hm
WHERE hm.fruit_code IN (
    SELECT fruit_code FROM fruit_hierarchy ORDER BY fruit_code
    );
