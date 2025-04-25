CREATE TABLE ERROR_LOG(
    LOG_ID NUMBER GENERATED ALWAYS AS IDENTITY,
    CREATE_TS TIMESTAMP,
    CREATED_BY VARCHAR2(100),
    ERROR_CODE INTEGER,
    CALL_STACK VARCHAR2(32767),
    ERROR_STACK VARCHAR2(32767),
    BACKTRACE VARCHAR2(32767),
    ERROR_INFO VARCHAR2(32767)
);


CREATE OR REPLACE PACKAGE ERROR_MANAGER
IS
    BULK_ERRORS EXCEPTION;
    PRAGMA EXCEPTION_INIT(BULK_ERRORS, -24381); --Giving Name to Bulk Errors that I can use anywhere in pl/sql
    PROCEDURE LOG_ERROR(p_app_info IN VARCHAR2); --define procedure at package spec level so that it can be used in other places in PL/SQL
END;

CREATE OR REPLACE PACKAGE BODY ERROR_MANAGER
IS
    PROCEDURE LOG_ERROR(p_app_info IN VARCHAR2) --this can be, for example, the procedure that called this 
    IS
        PRAGMA AUTONOMOUS_TRANSACTION; --ensures that we don't commit changes in callback program
        c_code CONSTANT INTEGER := SQLCODE;
    BEGIN
        INSERT INTO ERROR_LOG(LOG_ID
        , CREATE_TS
        , CREATED_BY
        , ERROR_CODE
        , CALL_STACK
        , ERROR_STACK
        , BACKTRACE
        , ERROR_INFO
        )
        VALUES(
            systimestamp
            , USER
            , c_code
            , DBMS_UTILITY.FORMAT_CALL_STACK
            , DBMS_UTILITY.FORMAT_ERROR_STACK
            , DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            , p_app_info
        );
        COMMIT;
    END;
    
END;
