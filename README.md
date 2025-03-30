# MySQL RREF Function

I was studying some linear algebra and decided I needed to bend MySQL to my will since I was also applying SQL at work. This function lets you convert a matrix into reduced row-echelon form (i.e., Gaussian elimination)

With a help of vibe coding (cursor, whisper flow and ChatGPT o3-mini-high), I did it. 


## What is Reduced Row Echelon Form / Gaussian elimination (RREF)?

Gaussian elimination only uses 3 elementary row operations:
1. Swapping rows
2. Multiplying a row by a non-zero scalar
3. Scalar multiple (non-zero) of one row added to another row. 

### Example

#### Initial Matrix

$$
\begin{pmatrix}
1 & 2 & 3 \\
4 & 5 & 6 \\
7 & 8 & 9
\end{pmatrix}
$$

#### Reduced row-echelon form

$$
\begin{pmatrix}
1 & 0 & -1 \\
0 & 1 & 2 \\
0 & 0 & 0
\end{pmatrix}
$$

  
## Overview of the Code

### Swapping Rows

When a pivot isn’t in the expected row, the code swaps the current row with a lower row that contains a suitable pivot.  
```sql
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
```

###  Multiplying a row by a non-zero scalar

```sql
-- Normalize row i by dividing every element by the pivot value
SELECT value INTO pivot_value FROM temp_matrix
  WHERE row_num = i AND col_num = lead_col;
UPDATE temp_matrix
  SET value = value / pivot_value
  WHERE row_num = i;
```


### Scalar multiple (non-zero) of one row added to another row. 

```sql
-- For every row other than i, eliminate the lead column entry
CREATE TEMPORARY TABLE temp_pivot AS
SELECT col_num, value
FROM temp_matrix
WHERE row_num = i;

SET k = 1;
WHILE k <= nr DO
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
END WHILE;
DROP TEMPORARY TABLE temp_pivot;
```




