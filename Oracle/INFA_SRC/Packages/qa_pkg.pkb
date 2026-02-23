create or replace package body qa_pkg
as

    procedure assert(p_condition in boolean, p_error_message in varchar2)
    is
    begin
        if not nvl(p_condition, false) then
            debug_pkg.debug_off;
            raise_application_error (-20003, 'QA_PKG: ' || p_error_message);
        end if;
    end assert;


    procedure truncate_table(p_table_name in varchar2)
    is
    begin
        execute immediate 'TRUNCATE TABLE ' || p_table_name || ' drop storage';
    exception
        when others then
        raise;
    end truncate_table;

    procedure take_full_table_backup(p_table_name in user_tables.table_name%type)
    is
       l_table user_tables.table_name%type;
       l_bkp_table_name all_tables.table_name%type;
    begin
        select table_name
        into l_table
        from user_tables
        where upper(table_name) = upper(p_table_name);

        dbms_output.put_line(l_table);

        l_bkp_table_name := 'BKP_QA_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '_' || l_table;

        execute immediate 'create table BKP_QA_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '_' || l_table || ' as select * from ' || l_table;

        dbms_output.put_line('Backup Table Created: ' || l_bkp_table_name);

    exception
        when no_data_found then
        dbms_output.put_line(l_table || ' IS NOT FOUND OR IS NOT ACCESSIBLE BY CURRENT USER. ABORTING');
        raise;

        when others then
        rollback;
        raise;
    end take_full_table_backup;

    procedure ins(
         --p_test_sk in qa_unit_test.test_sk%type,
         p_test_session_id in qa_unit_test.test_session_id%type
       , p_test_pkg in qa_unit_test.test_pkg%type
       , p_test_name in qa_unit_test.test_name%type
       , p_test_number in qa_unit_test.test_number%type
       , p_test_pass_ind in qa_unit_test.test_pass_ind%type
       , p_statement_executed in qa_unit_test.statement_executed%type
       , p_TEST_START_TS in qa_unit_test.TEST_START_TS%type
       )

    is
    begin
        insert into qa_unit_test
        (  --test_sk,
          test_session_id
        , test_pkg
        , test_name
        , test_number
        , test_pass_ind
        , statement_executed
        , TEST_START_TS
        , test_end_ts
        )values(
         --p_test_sk,
         p_test_session_id
        ,p_test_pkg
        ,p_test_name
        ,p_test_number
        ,p_test_pass_ind
        ,p_statement_executed
        ,p_TEST_START_TS
        ,systimestamp
        );
    exception
       when others then
       raise;
    end ins;

    procedure run_unit_tests(p_pkg_name user_source.name%type)
    is
        cursor unitTests is
        with ds as(
        select
        substr(upper(trim(text)), 1, instr(upper(trim(text)), ' ')-1) as pl_type
        , trim(
            substr(
                upper(trim(text)),
                instr(upper(trim(text)), ' '),
                decode(
                    instr(upper(trim(text)), ';'), 0, length(upper(trim(text))), instr(upper(trim(text)), ';')
                ) - instr(upper(trim(text)), ' ')
            )
        )
        as module
        , a.* from user_source a
        where (upper(name) = upper(p_pkg_name) and type = 'PACKAGE')
        and regexp_like(upper(trim(text)), '(^FUNCTION TEST_)') --procedures or function names must be prefixed with test_, and don't consider tests which are commented out (we can have reporting on this later)
        --and regexp_like(upper(trim(text)), '(^PROCEDURE TEST_|^FUNCTION TEST_)') --procedures or function names must be prefixed with test_, and don't consider tests which are commented out (we can have reporting on this later)
        --and regexp_like(upper(trim(text)), '[PROCEDURE|FUNCTION]')
        --and not regexp_like(upper(trim(text)), '^PACKAGE|RUN;$|END;$|^RETURN|^--') --> don't consider tests which are commented out (we can have reporting on this later)
        )

        select rownum as rn, d.pl_type, d.name, upper(d.module) as module,
        'begin :b := case when ' || d.name || '.' || d.module || ' then qa_pkg.g_yes else qa_pkg.g_no end; end;' as stmnt
        from ds d;

        l_str_array t_str_array := t_str_array();
        l_count integer;

        l_timestamp timestamp;
        l_boolean st_flag_len;

        l_session_id qa_unit_test.test_session_id%type;

        procedure setup
        is
        begin
           qa_pkg.assert(substr(upper(p_pkg_name), 1, 10) = 'UNIT_TEST_', 'INVALID PACKAGE TYPE PASSED. ABORTING');

           for t in unitTests
           loop
               l_str_array.extend;
               l_str_array(l_str_array.count) := t.stmnt;
           end loop;

           select count(1)
           into l_count
           from table(l_str_array);
        end setup;

    begin
       --setup;
       qa_pkg.assert(substr(upper(p_pkg_name), 1, length('UNIT_TEST_')) = 'UNIT_TEST_', 'INVALID PACKAGE TYPE PASSED. ABORTING');

       dbms_output.put_line('TEST_SESSION_ID for ' || p_pkg_name || ': ' || l_session_id);

       l_session_id := dbms_random.string('X', 64);

       for t in unitTests
       loop
           l_boolean := qa_pkg.g_no;
           l_timestamp := systimestamp;
           execute immediate t.stmnt using out l_boolean;
           ins(
             --p_test_sk => t.rn,
             p_test_session_id => l_session_id
           , p_test_pkg => t.name
           , p_test_name => t.module
           , p_test_number => t.rn
           , p_test_pass_ind => l_boolean
           , p_statement_executed => t.stmnt
           , p_TEST_START_TS => l_timestamp
           );
       end loop;
       commit;
    exception
       when others then
       rollback;
       raise;
    end run_unit_tests;

    function generate_pin_numbers(p_low in integer, p_high in integer)
    return t_str_array pipelined
    is
    begin
       for i in 0..dbms_random.value(p_low, p_high) / 2
       loop
           pipe row(trunc(dbms_random.value(1000000, 9999999)));
           pipe row(trunc(dbms_random.value(100010000000, 100019999999)));
       end loop;

       return;
    exception
        when others then
        raise;
    end generate_pin_numbers;

    procedure generate_pin_numbers(p_low in integer, p_high in integer)
	is
        l_low number;
        l_high number;
	begin
        truncate_table('temp_pins');

        insert into temp_pins(pin)(select * from table(qa_pkg.generate_pin_numbers(p_low,p_high)));

        commit;

    exception
        when others then
        raise;
	end generate_pin_numbers;


    function generate_contract_numbers(p_low in integer, p_high in integer)
    return t_str_array pipelined
    is
    begin
       for i in 0..dbms_random.value(p_low, p_high)
       loop
           pipe row(lpad(dbms_random.string('U', 2) || trunc(dbms_random.value(0000000, 9999999)), 9, 0));
       end loop;

       return;
    exception
        when others then
        raise;
    end generate_contract_numbers;


    procedure generate_contract_numbers(p_low in integer, p_high in integer)
    is
    begin
        truncate_table('temp_contracts');

        insert into temp_contracts(contract)(select * from table(qa_pkg.generate_contract_numbers(p_low,p_high)));

        commit;

    exception
        when others then
        raise;
    end generate_contract_numbers;

end qa_pkg;
