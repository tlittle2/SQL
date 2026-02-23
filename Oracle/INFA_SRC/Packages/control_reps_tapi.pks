create or replace PACKAGE control_reps_tapi IS
    TYPE control_reps_tapi_rec IS RECORD (
        rep_id      control_reps.rep_id%TYPE
        ,seq_number  control_reps.seq_number%TYPE
        ,create_date control_reps.create_date%TYPE
        ,txt_line    control_reps.txt_line%TYPE
    );
    
    TYPE control_reps_tapi_tab IS TABLE OF control_reps_tapi_rec;

-- insert
    PROCEDURE ins (
        p_rep_id      IN control_reps.rep_id%TYPE
      , p_seq_number  IN control_reps.seq_number%TYPE
      , p_create_date IN control_reps.create_date%TYPE DEFAULT NULL
      , p_txt_line    IN control_reps.txt_line%TYPE DEFAULT NULL
    );
    
-- insert_bulk
    PROCEDURE ins_bulk (p_table in control_reps_tapi_tab);

-- update
    PROCEDURE upd (
        p_rep_id      IN control_reps.rep_id%TYPE
      , p_seq_number  IN control_reps.seq_number%TYPE
      , p_create_date IN control_reps.create_date%TYPE DEFAULT NULL
      , p_txt_line    IN control_reps.txt_line%TYPE DEFAULT NULL
    );
-- delete
    PROCEDURE del (p_rep_id     IN control_reps.rep_id%TYPE);

END control_reps_tapi;
