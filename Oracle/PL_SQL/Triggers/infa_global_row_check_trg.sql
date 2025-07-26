create or replace trigger infa_global_row_check_trg
before delete or insert on infa_global
begin
    assert_pkg.is_true(2=1, 'CANCELLING OPERATION. ONLY 1 RECORD IS ALLOWED IN INFA_GLOBAL AT ALL TIMES');
end infa_global_row_check_trg;
