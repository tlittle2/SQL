create table qa_unit_test (
  TEST_SK	number default qa_unit_test_seq_key.nextval primary key
, TEST_SESSION_ID varchar2(64)
, TEST_PKG	VARCHAR2(128 BYTE)
, TEST_NAME	VARCHAR2(128 BYTE)
, TEST_NUMBER	NUMBER(38,0)
, TEST_PASS_IND	CHAR(1 BYTE)
, TEST_START_TS	TIMESTAMP(6)
, TEST_END_TS	TIMESTAMP(6)
, STATEMENT_EXECUTED	clob
);
