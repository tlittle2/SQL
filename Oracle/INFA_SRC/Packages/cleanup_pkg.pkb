create or replace package body cleanup_pkg
as

    procedure exception_cleanup(p_rollback in boolean default true)
    is
    begin
        if p_rollback
        then
            rollback;
        end if;

        debug_pkg.debug_off;
    end exception_cleanup;


    procedure close_cursor(p_cursor in out sys_refcursor)
    is
    begin
        if p_cursor%isopen
        then
            close p_cursor;
        end if;

    end close_cursor;

end cleanup_pkg;
