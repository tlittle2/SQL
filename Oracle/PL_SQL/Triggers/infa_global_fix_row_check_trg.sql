create or replace trigger infa_global_fix_row_check_trg
before delete or insert on infa_global_fix
begin
    assert_pkg.is_true(2=1, 'CANCELLING OPERATION. ONLY 1 RECORD IS ALLOWED IN INFA_GLOBAL_FIX AT ALL TIMES');
end infa_global_fix_row_check_trg;
