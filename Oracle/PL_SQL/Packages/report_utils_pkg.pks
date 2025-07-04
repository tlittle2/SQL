create or replace package report_utils_pkg
as
	subtype report_tab_str_len is varchar2(32767);
	v_rpt_str report_tab_str_len;
	
	type report_tab_t is table of report_tab_str_len;
    
    type report_tab_to is table of general_report_o;

	function salary_data_report(p_report_title in varchar2)
	return report_tab_t pipelined;
    
    function astrology_report(p_report_title in varchar2)
	return report_tab_t pipelined;
    
    function create_trxn_file
    return report_tab_t pipelined;
    
    /*
    general process for adding a report (as of this writing)
    
    1. create new pipeline table function in package and package spec
    2. in your procedure
        a. define your explicit cursor with your delimiter
        (if required)
            b. for headers, hard-code the columns (originally or derived in the cursor) into collection in the procedure
            c. for fixed byte reports, get the first line of the cursor and to get the max length of the concatnenated line (for dashes (-) in header)
            d. create header
        (if required)
        
        e. loop through and print out results of the cursor 
    
    */

end report_utils_pkg;
