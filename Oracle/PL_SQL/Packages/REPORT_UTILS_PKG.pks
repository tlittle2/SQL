create or replace PACKAGE REPORT_UTILS_PKG
AS
	SUBTYPE report_tab_str_len is VARCHAR2(32767);
	type report_tab_t is TABLE OF report_tab_str_len;
    v_rpt_str report_tab_str_len;
    
    --TYPE report_tab_to IS TABLE OF GENERAL_REPORT_O;

	FUNCTION SALARY_DATA_REPORT(p_report_title IN VARCHAR2)
	RETURN report_tab_t PIPELINED;
    
    FUNCTION ASTROLOGY_REPORT(p_report_title IN VARCHAR2)
	RETURN report_tab_t PIPELINED;
    
    FUNCTION CREATE_TRXN_FILE
    RETURN report_tab_t PIPELINED;
    
    /*
    General Process for adding a report (as of this writing)
    
    1. Create new pipeline table function in Package and Package Spec
    2. In your procedure
        a. define your explicit cursor with your delimiter
        (if required)
            b. For headers, hard-code the columns (originally or derived in the cursor) into collection in the procedure
            c. For fixed byte reports, Get the first line of the cursor and to get the max length of the concatnenated line (for dashes (-) in header)
            d. Create header
        (if required)
        
        e. Loop through and print out results of the cursor 
    
    */

END REPORT_UTILS_PKG;
