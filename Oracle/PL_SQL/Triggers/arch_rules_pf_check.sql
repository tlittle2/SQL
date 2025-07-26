create or replace trigger arch_rules_pf_check
before insert or update on archive_rules
for each row
declare
begin
    if not archive_rules_tbl_pkg.is_correct_arch_prefix(:new.table_name)
    then
        assert_pkg.is_true(1 = 2, 'ABORTING! TRYING TO INSERT ARCHIVE TABLE WITHOUT PROPER PREFIX');
    end if;

end arch_rules_pf_check;
