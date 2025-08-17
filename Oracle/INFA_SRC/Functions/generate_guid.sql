create or replace function generate_guid(p_seqnum in number, p_app_id in varchar2)

return varchar2
as
begin
    RETURN TO_CHAR(SYSDATE, 'yyyymmdd') || P_APP_ID || LPAD(P_SEQNUM, 12, '0');
end;

