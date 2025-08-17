select replace(ip, '<', '') from (
  select 'foss<<rritun' as ip from dual
);
