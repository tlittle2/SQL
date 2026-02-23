create or replace PACKAGE BODY control_reps_tapi IS
-- insert
    PROCEDURE ins (
        p_rep_id      IN control_reps.rep_id%TYPE
      , p_seq_number  IN control_reps.seq_number%TYPE
      , p_create_date IN control_reps.create_date%TYPE DEFAULT NULL
      , p_txt_line    IN control_reps.txt_line%TYPE DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO control_reps (
              rep_id
            , create_date
            , seq_number
            , txt_line
        ) VALUES ( p_rep_id
                 , p_create_date
                 , p_seq_number
                 , p_txt_line );
    exception
        when others then
        error_pkg.print_error('control_reps_tapi.ins');
        raise;
    END ins;


-- insert_bulk
    PROCEDURE ins_bulk(p_table in control_reps_tapi_tab)
    IS
    BEGIN
        forall rec in indices of p_table
        insert into control_reps (rep_id, seq_number, create_date, txt_line)
        values(p_table(rec).rep_id, p_table(rec).seq_number, p_table(rec).create_date, p_table(rec).txt_line);
    exception
        when others then
        error_pkg.print_error('control_reps_tapi.ins_bulk');
        raise;
    END ins_bulk;

-- update
    PROCEDURE upd (
        p_rep_id      IN control_reps.rep_id%TYPE
      , p_seq_number  IN control_reps.seq_number%TYPE
      , p_create_date IN control_reps.create_date%TYPE DEFAULT NULL
      , p_txt_line    IN control_reps.txt_line%TYPE DEFAULT NULL)
    IS
    BEGIN
        UPDATE control_reps
        SET
            create_date = p_create_date
        , txt_line = p_txt_line
        WHERE
                rep_id = p_rep_id
            AND seq_number = p_seq_number;
    exception
        when others then
        error_pkg.print_error('control_reps_tapi.upd');
        raise;
    END upd;

-- del
    PROCEDURE del (p_rep_id IN control_reps.rep_id%TYPE)
    IS
    BEGIN
        DELETE FROM control_reps
        WHERE rep_id = p_rep_id;
    
    exception
        when others then
        error_pkg.print_error('control_reps_tapi.del');
        raise;
    END del;

END control_reps_tapi;
