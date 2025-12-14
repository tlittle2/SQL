create or replace package archive_rules_tapi
is
    -- insert
    procedure ins (
     p_TABLE_OWNER in ARCHIVE_RULES.TABLE_OWNER%type
    ,p_TABLE_NAME in ARCHIVE_RULES.TABLE_NAME%type
    ,p_ARCHIVE_COLUMN_KEY in ARCHIVE_RULES.ARCHIVE_COLUMN_KEY%type default null 
    ,p_JOB_NBR in ARCHIVE_RULES.JOB_NBR%type default null 
    ,p_UPD_FLAG in ARCHIVE_RULES.UPD_FLAG%type default null 
    ,p_ARCHIVE_GROUP_KEY in ARCHIVE_RULES.ARCHIVE_GROUP_KEY%type default null 
    ,p_YEARS_TO_KEEP in ARCHIVE_RULES.YEARS_TO_KEEP%type default null);
    
    -- update
    procedure upd (
     p_TABLE_OWNER in ARCHIVE_RULES.TABLE_OWNER%type
    ,p_TABLE_NAME in ARCHIVE_RULES.TABLE_NAME%type
    ,p_ARCHIVE_COLUMN_KEY in ARCHIVE_RULES.ARCHIVE_COLUMN_KEY%type default null 
    ,p_JOB_NBR in ARCHIVE_RULES.JOB_NBR%type default null 
    ,p_UPD_FLAG in ARCHIVE_RULES.UPD_FLAG%type default null 
    ,p_ARCHIVE_GROUP_KEY in ARCHIVE_RULES.ARCHIVE_GROUP_KEY%type default null 
    ,p_YEARS_TO_KEEP in ARCHIVE_RULES.YEARS_TO_KEEP%type default null);

    procedure reset_archive_rules;

    -- delete
    procedure del (p_TABLE_OWNER in ARCHIVE_RULES.TABLE_OWNER%type,p_TABLE_NAME in ARCHIVE_RULES.TABLE_NAME%type);
    
    function get_row(p_TABLE_OWNER in ARCHIVE_RULES.TABLE_OWNER%type,p_TABLE_NAME in ARCHIVE_RULES.TABLE_NAME%type)
    return ARCHIVE_RULES%rowtype;

end archive_rules_tapi;
