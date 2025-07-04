create or replace package cleanup_pkg
authid definer
as

	procedure exception_cleanup(p_rollback in boolean default true);
	procedure close_cursor (p_cursor in out sys_refcursor);
    
end cleanup_pkg;
