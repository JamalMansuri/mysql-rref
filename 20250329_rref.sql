-- Okay you gotta run this in a particular sequence for it to work, first drop everything

DROP FUNCTION IF EXISTS matrix_rref;
DROP FUNCTION IF EXISTS matrix_rref;
DROP TABLE IF EXISTS matrix_element;
DROP TABLE IF EXISTS temp_matrix;


-- This creates the tables where our matrix will exist

CREATE TABLE matrix_element (
    row_num INT,
    col_num INT,
    value DOUBLE,
    PRIMARY KEY (row_num, col_num)
);


-- The solution

DELIMITER $$

CREATE FUNCTION matrix_rref(matrix_data JSON, tolerance DOUBLE)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE nr INT;
    DECLARE nc INT;
    DECLARE lead_col INT DEFAULT 1;
    DECLARE i INT DEFAULT 1;
    DECLARE j INT;
    DECLARE k INT;
    DECLARE pivot_value DOUBLE;
    DECLARE cell_val DOUBLE;
    DECLARE factor DOUBLE;
    DECLARE final_json JSON;

    -- Create a temporary table to hold matrix elements
    CREATE TEMPORARY TABLE temp_matrix (
        row_num INT,
        col_num INT,
        value DOUBLE,
        PRIMARY KEY (row_num, col_num)
    );

    -- Populate temporary table from JSON input
    INSERT INTO temp_matrix (row_num, col_num, value)
    SELECT row_num, col_num, value
    FROM JSON_TABLE(
         matrix_data,
         '$[*]' COLUMNS(
            row_num INT PATH '$.row_num',
            col_num INT PATH '$.col_num',
            value DOUBLE PATH '$.value'
         )
    ) AS jt;

    -- Determine the matrix dimensions
    SELECT MAX(row_num), MAX(col_num) INTO nr, nc FROM temp_matrix;

    main_loop: WHILE i <= nr DO
        IF lead_col > nc THEN
            LEAVE main_loop;
        END IF;

        SET j = i;
        row_search: WHILE j <= nr DO
            SELECT value INTO cell_val FROM temp_matrix
              WHERE row_num = j AND col_num = lead_col;
            IF ABS(cell_val) >= tolerance THEN
                LEAVE row_search;
            END IF;
            SET j = j + 1;
        END WHILE row_search;

        IF j > nr THEN
            SET lead_col = lead_col + 1;
            IF lead_col > nc THEN
                LEAVE main_loop;
            END IF;
            ITERATE main_loop;
        END IF;

        -- Swap rows if needed (using a temporary negative marker)
        IF j <> i THEN
            UPDATE temp_matrix
              SET row_num = -row_num
              WHERE row_num IN (i, j);
            UPDATE temp_matrix
              SET row_num = CASE 
                                WHEN row_num = -i THEN j
                                WHEN row_num = -j THEN i
                             END
              WHERE row_num IN (-i, -j);
        END IF;

        -- Get the pivot value at (i, lead_col)
        SELECT value INTO pivot_value FROM temp_matrix
          WHERE row_num = i AND col_num = lead_col;

        -- Normalize row i by dividing every element by the pivot value
        UPDATE temp_matrix
          SET value = value / pivot_value
          WHERE row_num = i;

        -- For every row other than i, eliminate the lead column entry
        -- Create a temporary pivot table for row i
        CREATE TEMPORARY TABLE temp_pivot AS
        SELECT col_num, value
        FROM temp_matrix
        WHERE row_num = i;
        
        SET k = 1;
        row_update: WHILE k <= nr DO
            IF k <> i THEN
                SELECT value INTO factor FROM temp_matrix
                  WHERE row_num = k AND col_num = lead_col;
                IF ABS(factor) > tolerance THEN
                    UPDATE temp_matrix tm
                    JOIN temp_pivot tp ON tm.col_num = tp.col_num
                    SET tm.value = tm.value - factor * tp.value
                    WHERE tm.row_num = k;
                END IF;
            END IF;
            SET k = k + 1;
        END WHILE row_update;
        
        DROP TEMPORARY TABLE temp_pivot;

        SET lead_col = lead_col + 1;
        SET i = i + 1;
    END WHILE main_loop;

    -- Reconstruct the JSON result from the temporary table
    SELECT JSON_ARRAYAGG(JSON_OBJECT('row_num', row_num, 'col_num', col_num, 'value', value))
      INTO final_json
      FROM temp_matrix
      ORDER BY row_num, col_num;

    DROP TEMPORARY TABLE temp_matrix;

    RETURN final_json;
END $$
DELIMITER ;


WITH RECURSIVE sample_matrix AS (
    SELECT JSON_ARRAY(
        JSON_OBJECT('row_num', 1, 'col_num', 1, 'value', 1.0),
        JSON_OBJECT('row_num', 1, 'col_num', 2, 'value', 2.0),
        JSON_OBJECT('row_num', 1, 'col_num', 3, 'value', 3.0),
        JSON_OBJECT('row_num', 2, 'col_num', 1, 'value', 4.0),
        JSON_OBJECT('row_num', 2, 'col_num', 2, 'value', 5.0),
        JSON_OBJECT('row_num', 2, 'col_num', 3, 'value', 6.0),
        JSON_OBJECT('row_num', 3, 'col_num', 1, 'value', 7.0),
        JSON_OBJECT('row_num', 3, 'col_num', 2, 'value', 8.0),
        JSON_OBJECT('row_num', 3, 'col_num', 3, 'value', 9.0)
    ) AS matrix
)
SELECT JSON_PRETTY(matrix_rref(matrix, 1e-10)) FROM sample_matrix;

WITH RECURSIVE sample_matrix AS (
    SELECT JSON_ARRAY(
        JSON_OBJECT('row_num', 1, 'col_num', 1, 'value', 1.0),
        JSON_OBJECT('row_num', 1, 'col_num', 2, 'value', 2.0),
        JSON_OBJECT('row_num', 1, 'col_num', 3, 'value', 3.0),
        JSON_OBJECT('row_num', 2, 'col_num', 1, 'value', 4.0),
        JSON_OBJECT('row_num', 2, 'col_num', 2, 'value', 5.0),
        JSON_OBJECT('row_num', 2, 'col_num', 3, 'value', 6.0)
    ) AS matrix
)
SELECT JSON_PRETTY(matrix_rref(matrix, 1e-10)) AS rref_output FROM sample_matrix;


