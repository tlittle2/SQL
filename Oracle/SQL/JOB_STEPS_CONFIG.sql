CREATE TABLE JOB_STEPS_CONFIG(
  --JOB_STEPS_CONFIG_SK NUMBER GENERATED ALWAYS AS IDENTITY,
  SYSTEM_SK VARCHAR2(3 BYTE)
, SUBSYSTEM_SK VARCHAR2(3 BYTE)
, JOB_ID NUMBER(10,0)
, STEP_NUMBER NUMBER(10,0)
, OPERATION_TYPE CHAR(1)
, OPERATION_NAME VARCHAR2(128)
, OPERATION_TAG VARCHAR2(128)
, OPERATION_VALUE VARCHAR2(4000)
, OPERATION_ORDER NUMBER(10,0)
, OPERATION_SUB_ORDER NUMBER(10,0)
, ACTIVE_FLAG CHAR(1) DEFAULT 'Y'
, PROCESS_COMPLETED CHAR(1) DEFAULT 'N'
, CREATE_TIME TIMESTAMP
, CREATE_BY VARCHAR2(128)
);




INSERT INTO JOB_STEPS_CONFIG VALUES('000', '000', 1,2, 'P', 'BATCH_CDC', 'p_job_nbr', '1', 1, 1, 'Y', 'N', SYSTIMESTAMP, USER);


INSERT INTO JOB_STEPS_CONFIG VALUES('000', '000', 1,1, 'L', 'SQLLDR', 'p_control_file_path', '/prod/sqlldrs/', 1, 1, 'Y', 'N', SYSTIMESTAMP, USER);
INSERT INTO JOB_STEPS_CONFIG VALUES('000', '000', 1,1, 'L', 'SQLLDR', 'p_control_file_name', 'SALARY_DATA_STG.ctl', 1, 2, 'Y', 'N', SYSTIMESTAMP, USER);


select * from job_steps_config where job_id = :p_job_id
and active_flag = 'Y' and process_completed = 'N'
order by step_number, operation_order, operation_sub_order;


with op as (
select distinct op.operation_name as op_name
from job_steps_config op
where op.active_flag = 'Y' and op.process_completed = 'N'
and job_id = 1
and op.step_number = 2
and op.operation_order = 1

)
, parms as (
select listagg(operation_value || ',') within group (order by operation_order, operation_sub_order) as parm
from job_steps_config op
where op.active_flag = 'Y' and op.process_completed = 'N'
and job_id = 1
and op.step_number = 2
and op.operation_order = 1
order by operation_sub_order
)

select op.op_name || '(' || substr(parms.parm, 1,length(parms.parm) -1) || ')' as cmd from op, parms;
