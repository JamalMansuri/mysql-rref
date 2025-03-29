{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\fnil\fcharset0 .AppleSystemUIFontMonospaced-Regular;}
{\colortbl;\red255\green255\blue255;\red214\green85\blue98;\red155\green162\blue177;\red81\green156\blue233;
}
{\*\expandedcolortbl;;\cssrgb\c87843\c42353\c45882;\cssrgb\c67059\c69804\c74902;\cssrgb\c38039\c68235\c93333;
}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 #MySQL reduced row echelon form function\
\
I woke up 1 day and decided I needed to make this function within SQL, it was a great exercise in learning how to use SQL and json functions. \
\
With a help of vibe coding (cursor, whisper flow and ChatGPT o3-mini-high), I did it. \
\
\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f1\fs26 \cf2 ## Background\cf3 \
\
\cf2 ### Reduced Row Echelon Form (RREF)\cf3 \
The RREF of a matrix is a canonical form of a matrix in linear algebra. It satisfies the following conditions:\
\cf4 -\cf3  **Leading 1's:** Every nonzero row has a leading 1 (called a pivot).\
\cf4 -\cf3  **Zero Columns:** Each leading 1 is the only nonzero entry in its column.\
\cf4 -\cf3  **Ordered Rows:** All rows with all zero elements are at the bottom of the matrix.\
\cf4 -\cf3  **Row Ordering:** The leading 1 of a row is to the right of the leading 1 in the previous row.\
\
\cf2 ### Elementary Row Operations\cf3 \
To transform a matrix into its RREF, only three types of elementary row operations are allowed:\
\cf4 1.\cf3  **Row Swapping:** Exchanging two rows.\
\cf4 2.\cf3  **Row Scaling:** Multiplying a row by a nonzero constant.\
\cf4 3.\cf3  **Row Addition:** Adding a multiple of one row to another row.\
\
These operations ensure that the resulting matrix is equivalent to the original in terms of its row space and solution set.\
\
\cf2 ## How the Function Works\cf3 \
\
The `matrix_rref` function performs the following steps:\
\cf4 1.\cf3  **Input Parsing:**  \
   It accepts matrix data as a JSON array where each element contains `row_num`, `col_num`, and `value`.\
\
\cf4 2.\cf3  **Temporary Storage:**  \
   The function inserts this JSON data into a temporary table to work with the matrix elements.\
\
\cf4 3.\cf3  **RREF Algorithm:**  \
\cf4    -\cf3  It determines the matrix dimensions.\
\cf4    -\cf3  It iterates over the rows and columns to select pivots.\
\cf4    -\cf3  **Pivoting:** The function searches for a nonzero element (within a given tolerance) in the current column, then swaps rows if necessary.\
\cf4    -\cf3  **Normalization:** The pivot row is normalized by dividing by the pivot value.\
\cf4    -\cf3  **Elimination:** It eliminates the entries in the pivot column of all other rows using the allowed elementary operations.\
\cf4    -\cf3  A temporary table is used to safely extract pivot row values without causing MySQL errors related to reopening tables.\
\
\cf4 4.\cf3  **Output Construction:**  \
   Finally, the RREF matrix is reassembled into a JSON array and returned.\
\
\cf2 ## Usage Examples\cf3 \
\
\cf2 ### Square Matrix Example\cf3 \
```sql\
WITH RECURSIVE sample_matrix AS (\
    SELECT JSON_ARRAY(\
        JSON_OBJECT('row_num', 1, 'col_num', 1, 'value', 1.0),\
        JSON_OBJECT('row_num', 1, 'col_num', 2, 'value', 2.0),\
        JSON_OBJECT('row_num', 1, 'col_num', 3, 'value', 3.0),\
        JSON_OBJECT('row_num', 2, 'col_num', 1, 'value', 4.0),\
        JSON_OBJECT('row_num', 2, 'col_num', 2, 'value', 5.0),\
        JSON_OBJECT('row_num', 2, 'col_num', 3, 'value', 6.0),\
        JSON_OBJECT('row_num', 3, 'col_num', 1, 'value', 7.0),\
        JSON_OBJECT('row_num', 3, 'col_num', 2, 'value', 8.0),\
        JSON_OBJECT('row_num', 3, 'col_num', 3, 'value', 9.0)\
    ) AS matrix\
)\
SELECT JSON_PRETTY(matrix_rref(matrix, 1e-10)) AS rref_output FROM sample_matrix;
\f0\fs24 \cf0 \
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0
\cf0 \
\
}