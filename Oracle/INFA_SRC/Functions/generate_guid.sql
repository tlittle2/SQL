create or replace FUNCTION GENERATE_GUID(p_seqnum IN NUMBER, p_app_id IN VARCHAR2)
RETURN VARCHAR2
AS
BEGIN
    return to_char(sysdate, 'YYYYMMDD') || p_app_id || lpad(p_seqnum, 12, '0');
END;
