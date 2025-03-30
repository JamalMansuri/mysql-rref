# MySQL RREF Function

I was studying some linear algebra and decided I needed to bend MySQL to my will since I was also learning SQL at work. This function lets you convert a matrix into reduced row-echelon form (i.e., Gaussian elimination)

With a help of vibe coding (cursor, whisper flow and ChatGPT o3-mini-high), I did it. 


## What is Reduced Row Echelon Form / Gaussian elimination (RREF)?

Gaussian elimination uses systematic row operations—swapping, scaling, and adding multiples of rows—to transform a matrix into its reduced row echelon form (RREF), simplifying the solution of linear equations. For instance, with the matrix
\begin{pmatrix}
1 & 2 & 3 \\
4 & 5 & 6 \\
7 & 8 & 9
\end{pmatrix}
we use the first row as a pivot to eliminate entries below the leading 1, then repeat the process for each subsequent row until the matrix is fully reduced.

the RREF becomes

\[
\begin{pmatrix}
1 & 0 & -1 \\
0 & 1 & 2 \\
0 & 0 & 0
\end{pmatrix}
\]
  
## How the Nested While Loops Work

- **Main Loop:**  
  Iterates over each row (tracked by variable `i`) while advancing the current pivot column (`lead_col`). It stops when all rows or columns are processed.

- **Pivot Search Loop:**  
  A nested loop (with variable `j`) searches downward from the current row to find a candidate pivot — a cell whose absolute value exceeds the given tolerance. If found, the loop exits; otherwise, the pivot column is advanced.

- **Elimination Loop:**  
  Another inner loop (using variable `k`) iterates through all rows (except the pivot row) to eliminate the values in the current pivot column. This is done by computing a factor for each row and subtracting the appropriate multiple of the pivot row from it. A temporary pivot table is used to simplify accessing the pivot row’s values during these updates.



