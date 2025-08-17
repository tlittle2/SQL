create or replace package assert_pkg
as
   
   procedure is_valid_run_mode(p_run_mode in char, p_error_message in varchar2);
   
   procedure is_not_null_nor_blank(p_val in varchar2, p_error_message in varchar2);
   
   procedure is_null(p_val in varchar2, p_error_message in varchar2);
   
   procedure is_not_null(p_val in varchar2, p_error_message in varchar2);
   
   procedure is_true(p_condition in boolean, p_error_message in varchar2);
   
   procedure is_false(p_condition in boolean, p_error_message in varchar2);
   
   procedure is_valid_month(p_month in number, p_error_message in varchar2);
   
   procedure is_date_in_range(p_date_in IN DATE, p_low_date in date, p_high_date in date, p_error_message in varchar2);
   
   procedure is_equal_to(p_val_1 in number, p_val_2 in number, p_error_message in varchar2);
   
   procedure is_equal_to_zero(p_val_1 in number,p_error_message in varchar2);
   
   procedure is_greater_than(p_val_1 in number, p_val_2 in number, p_error_message in varchar2);
   
   procedure is_less_than(p_val_1 in number, p_val_2 in number, p_error_message in varchar2);
  

end assert_pkg;
