create or replace trigger part_parm_pf_check_trg
before insert or update on partition_table_parm
for each row
begin
    if not archive_rules_tbl_pkg.is_correct_arch_prefix(:new.table_name)
    then
        assert_pkg.is_true(1 = 2, 'ABORTING! TRYING TO INSERT ARCHIVE TABLE WITHOUT PROPER PREFIX');--do not insert on purpose we are trying to insert an archive table with the wrong prefix
    end if;

end part_parm_pf_check_trg;
