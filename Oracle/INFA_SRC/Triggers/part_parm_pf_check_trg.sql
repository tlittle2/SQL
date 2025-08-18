create or replace trigger part_parm_pf_check_trg
before insert or update on partition_table_parm
for each row
begin
    archive_rules_tbl_pkg.is_valid_for_archival(:new.table_name); --we archive partitioned and non-partitioned tables. For maximum speed, this must be true
end part_parm_pf_check_trg;