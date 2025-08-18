create or replace trigger arch_rules_pf_check_trg
before insert or update on archive_rules
for each row
begin
    archive_rules_tbl_pkg.is_valid_for_archival(:new.table_name);
end arch_rules_pf_check_trg;