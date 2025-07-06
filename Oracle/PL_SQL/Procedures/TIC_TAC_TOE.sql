CREATE OR REPLACE PROCEDURE TIC_TAC_TOE
AS 
    subtype cellLength is char(1);
    
    type t_cell_rec is record (
        cell1 cellLength,
        cell2 cellLength,
        cell3 cellLength
        );

    type t_board is table of t_cell_rec index by pls_integer;
    board t_board;
    
    player1 cellLength := 'X';
    player2 cellLength := 'O';

    function checkHorizontals(p_board IN t_board, p_letter IN cellLength)
    return BOOLEAN
    is
    begin
        for i in p_board.FIRST..p_board.LAST
        loop
            if p_board(i).cell1 = p_letter and p_board(i).cell2 = p_letter and p_board(i).cell3 = p_letter
            then
                return TRUE;
            end if;
        
        end loop;
        
        return FALSE;
    end checkHorizontals;

    function checkVerticals(p_board IN t_board, p_letter IN cellLength)
    return BOOLEAN
    is
    begin
        if (p_board(1).cell1 = p_letter and p_board(2).cell1 = p_letter and p_board(3).cell1 = p_letter)
        or (p_board(1).cell2 = p_letter and p_board(2).cell2 = p_letter and p_board(3).cell2 = p_letter)
        or (p_board(1).cell3 = p_letter and p_board(2).cell3 = p_letter and p_board(3).cell3 = p_letter)
        then
            return TRUE;
        end if;
        
        return FALSE;
    
    end checkVerticals;

    function checkDiagonals(p_board IN t_board, p_letter IN cellLength)
    return boolean
    is
    begin
        if (p_board(1).cell1 = p_letter and p_board(2).cell2 = p_letter and p_board(3).cell3 = p_letter)
        or (p_board(1).cell3 = p_letter and p_board(2).cell2 = p_letter and p_board(3).cell1 = p_letter)
        then
            return True;
        end if;
        
        return False;
    end checkDiagonals;

    function randomLetter
    return CHAR
    is
    begin
        if ROUND(DBMS_RANDOM.VALUE(0,1)) = 0
        then
            return player1;
        else    
            return player2;
        end if;
    end randomLetter;

    procedure printOutput(p_letter IN cellLength, p_direction IN VARCHAR2)
    is
    begin
        dbms_output.put_line(p_letter || ' won ' || p_direction);
    end printOutput;

    procedure processPlayer(p_board t_board, p_player cellLength)
    is 
    begin
        if checkHorizontals(p_board, p_player)
        then
            printOutput(p_player, 'horizontally');
        elsif checkVerticals(board, p_player)
        then
            printOutput(p_player, 'vertically');
        elsif checkDiagonals(board, p_player)
        then
            printOutput(p_player, 'diagonally');
        end if;
    end processPlayer;
    
    procedure viewBoard(p_board IN t_board)
    is
    begin
        for i in p_board.FIRST..p_board.LAST
        loop
            dbms_output.put_line(p_board(i).cell1 || p_board(i).cell2 || p_board(i).cell3);
        end loop;
    end viewBoard;

    procedure populateBoard(p_board IN OUT t_board)
    is 
    begin
        for i in 1..3
        loop
                p_board(i).cell1 := randomLetter;
                p_board(i).cell2 := randomLetter;
                p_board(i).cell3 := randomLetter;
        end loop;
    end populateBoard;

BEGIN
    populateBoard(board);
    viewBoard(board);
    processPlayer(board, player1);
    processPlayer(board, player2);

END TIC_TAC_TOE;
