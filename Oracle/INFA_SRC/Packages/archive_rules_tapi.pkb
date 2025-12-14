create or replace package body archive_rules_tapi
is
    -- insert
    procedure ins (
     p_TABLE_OWNER in ARCHIVE_RULES.TABLE_OWNER%type
    ,p_TABLE_NAME in ARCHIVE_RULES.TABLE_NAME%type
    ,p_ARCHIVE_COLUMN_KEY in ARCHIVE_RULES.ARCHIVE_COLUMN_KEY%type default null 
    ,p_JOB_NBR in ARCHIVE_RULES.JOB_NBR%type default null 
    ,p_UPD_FLAG in ARCHIVE_RULES.UPD_FLAG%type default null 
    ,p_ARCHIVE_GROUP_KEY in ARCHIVE_RULES.ARCHIVE_GROUP_KEY%type default null 
    ,p_YEARS_TO_KEEP in ARCHIVE_RULES.YEARS_TO_KEEP%type default null)
    is
    begin
        insert into ARCHIVE_RULES(
        TABLE_NAME
        ,ARCHIVE_COLUMN_KEY
        ,JOB_NBR
        ,TABLE_OWNER
        ,UPD_FLAG
        ,ARCHIVE_GROUP_KEY
        ,YEARS_TO_KEEP
        ) values (
        p_TABLE_NAME
        ,p_ARCHIVE_COLUMN_KEY
        ,p_JOB_NBR
        ,p_TABLE_OWNER
        ,p_UPD_FLAG
        ,p_ARCHIVE_GROUP_KEY
        ,p_YEARS_TO_KEEP
        );
    end ins;

    -- update
    procedure upd (
     p_TABLE_OWNER in ARCHIVE_RULES.TABLE_OWNER%type
    ,p_TABLE_NAME in ARCHIVE_RULES.TABLE_NAME%type
    ,p_ARCHIVE_COLUMN_KEY in ARCHIVE_RULES.ARCHIVE_COLUMN_KEY%type default null 
    ,p_JOB_NBR in ARCHIVE_RULES.JOB_NBR%type default null 
    ,p_UPD_FLAG in ARCHIVE_RULES.UPD_FLAG%type default null 
    ,p_ARCHIVE_GROUP_KEY in ARCHIVE_RULES.ARCHIVE_GROUP_KEY%type default null 
    ,p_YEARS_TO_KEEP in ARCHIVE_RULES.YEARS_TO_KEEP%type default null 
    ) is
    begin
        update ARCHIVE_RULES set
        ARCHIVE_COLUMN_KEY = nvl(p_ARCHIVE_COLUMN_KEY, ARCHIVE_COLUMN_KEY)
        ,JOB_NBR = nvl(p_JOB_NBR, job_nbr)
        ,UPD_FLAG = nvl(p_UPD_FLAG, upd_flag)
        ,ARCHIVE_GROUP_KEY = nvl(p_ARCHIVE_GROUP_KEY, ARCHIVE_GROUP_KEY)
        ,YEARS_TO_KEEP = nvl(p_YEARS_TO_KEEP, YEARS_TO_KEEP)
        where TABLE_OWNER = p_TABLE_OWNER
        and TABLE_NAME = p_TABLE_NAME;
    end upd;

    procedure reset_archive_rules
    is
    begin
        update archive_rules
        set job_nbr = null;
    end reset_archive_rules;


    -- del
    procedure del (
    p_TABLE_OWNER in ARCHIVE_RULES.TABLE_OWNER%type
    ,p_TABLE_NAME in ARCHIVE_RULES.TABLE_NAME%type
    ) is
    begin
        delete from ARCHIVE_RULES
        where TABLE_OWNER = p_TABLE_OWNER
        and TABLE_NAME = p_TABLE_NAME;
    end del;
    
    function get_row(p_TABLE_OWNER in ARCHIVE_RULES.TABLE_OWNER%type,p_TABLE_NAME in ARCHIVE_RULES.TABLE_NAME%type)
    return ARCHIVE_RULES%rowtype
    is
        l_returnvalue ARCHIVE_RULES%rowtype;
    begin
        select *
        into l_returnvalue
        from ARCHIVE_RULES
        where TABLE_OWNER = p_TABLE_OWNER
        and TABLE_NAME = p_TABLE_NAME;
        
        return l_returnvalue;

    end get_row;


end archive_rules_tapi;
