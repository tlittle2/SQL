SELECT 'echo "SELECT COUNT(*) FROM '|| OWNER || '.' || TABLE_NAME || '; " >> ' || 'COUNT_' || lower(owner) || '_' || table_name AS select_query
FROM ALL_TAB_COLUMNS
WHERE OWNER = 'SCOTT'
GROUP BY OWNER, TABLE_NAME;
