SELECT 'echo "SELECT ' || LISTAGG(COLUMN_NAME, '||''|''|| ') WITHIN GROUP (ORDER BY COLUMN_ID) || ' FROM ' || OWNER || '.' || TABLE_NAME || '; " >> ' || lower(owner) || '_' || table_name AS select_query
FROM ALL_TAB_COLUMNS
WHERE OWNER = 'SCOTT' --Change where clause to meet your criteria
GROUP BY OWNER, TABLE_NAME;
