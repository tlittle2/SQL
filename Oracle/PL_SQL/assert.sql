--given some boolean that we want to check and the condition "satisfies", then raise the application error to stop the process
procedure assert(p_return_value IN VARCHAR2, p_condition IN BOOLEAN, p_flag BOOLEAN DEFAULT TRUE)
IS
BEGIN
    case p_flag
        when false then --if we want to check that the condition is not satisfied
            IF NOT nvl(P_CONDITION, false)
            THEN
                RAISE_APPLICATION_ERROR(-20000, p_return_value);
            END IF;
        else
            IF nvl(P_CONDITION, false)  --if we want to check that the condition is satisfied
            THEN
                RAISE_APPLICATION_ERROR(-20001, p_return_value);
            END IF;
    end case;
END;
