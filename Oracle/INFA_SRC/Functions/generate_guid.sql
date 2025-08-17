create or replace function generate_guid(p_seqnum in number, p_app_id in varchar2)
return varchar2
as
begin
    return to_char(sysdate, 'yyyymmdd') || p_app_id || lpad(p_seqnum, 12, '0');
end generate_guid;

