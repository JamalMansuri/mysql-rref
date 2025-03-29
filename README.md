# MySQL RREF Function

I woke up 1 day and decided I needed to make this function within SQL, it was a great exercise in learning how to use SQL and json functions. 

With a help of vibe coding (cursor, whisper flow and ChatGPT o3-mini-high), I did it. 
## Background

### Reduced Row Echelon Form (RREF)
The RREF of a matrix is a canonical form of a matrix in linear algebra. It satisfies the following conditions:
- **Leading 1's:** Every nonzero row has a leading 1 (called a pivot).
- **Zero Columns:** Each leading 1 is the only nonzero entry in its column.
- **Ordered Rows:** All rows with all zero elements are at the bottom of the matrix.
- **Row Ordering:** The leading 1 of a row is to the right of the leading 1 in the previous row.

### Elementary Row Operations
To transform a matrix into its RREF, only three types of elementary row operations are allowed:
1. **Row Swapping:** Exchanging two rows.
2. **Row Scaling:** Multiplying a row by a nonzero constant.
3. **Row Addition:** Adding a multiple of one row to another row.

These operations ensure that the resulting matrix is equivalent to the original in terms of its row space and solution set.

## How the Function Works

The `matrix_rref` function performs the following steps:
1. **Input Parsing:**  
   It accepts matrix data as a JSON array where each element contains `row_num`, `col_num`, and `value`.

2. **Temporary Storage:**  
   The function inserts this JSON data into a temporary table to work with the matrix elements.

3. **RREF Algorithm:**  
   - It determines the matrix dimensions.
   - It iterates over the rows and columns to select pivots.
   - **Pivoting:** The function searches for a nonzero element (within a given tolerance) in the current column, then swaps rows if necessary.
   - **Normalization:** The pivot row is normalized by dividing by the pivot value.
   - **Elimination:** It eliminates the entries in the pivot column of all other rows using the allowed elementary operations.
   - A temporary table is used to safely extract pivot row values without causing MySQL errors related to reopening tables.

4. **Output Construction:**  
   Finally, the RREF matrix is reassembled into a JSON array and returned.

## Usage Examples

### Square Matrix Example
```sql
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
SELECT JSON_PRETTY(matrix_rref(matrix, 1e-10)) AS rref_output FROM sample_matrix;
