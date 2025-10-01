CREATE TABLE "INFA_SRC"."REPORT_CREATION_PARMS" (
    "REPORT_NAME" VARCHAR2(8 BYTE) primary key,
    "PADDING" NUMBER,
    "ROLLING_HEADER" NUMBER DEFAULT 0,
    "REPORT_QUERY" CLOB
);

Insert into REPORT_CREATION_PARMS (REPORT_NAME,PADDING,ROLLING_HEADER,REPORT_QUERY) values ('RPT1',20,40,'select CASE_NUM, ID, GENDER, DEGREE, YEAR_DEGREE, FIELD, START_YEAR, YEAR, to_char(eff_date, ''mm/dd/yyyy'') as eff_date from salary_data');
Insert into REPORT_CREATION_PARMS (REPORT_NAME,PADDING,ROLLING_HEADER,REPORT_QUERY) values ('RPT2',20,0,'select nvl(tablespace_name, ''(blank)'') as tablespace_name , sum(nvl(num_rows,0)) as volume from my_tables group by tablespace_name order by volume desc');
Insert into REPORT_CREATION_PARMS (REPORT_NAME,PADDING,ROLLING_HEADER,REPORT_QUERY) values ('RPT3',20,0,'select * from astrology');

commit;

