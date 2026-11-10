---
course: SMDS
week: 2
source: "[[adsp31014_mlr.pdf]]"
status: new
tags: [generated]
---
# L2 Norm
**In one line:** The length of a list of numbers, measured as straight-line distance (Pythagoras).

**In plain words:** Treat a list of numbers as an arrow from the origin. Its length is the square root of the sum of the squares. Why it matters: "sum of squared errors" is just the squared length of the error list, so least squares becomes "make the error arrow as short as possible".

**Symbols**
| Symbol | Means |
|---|---|
| $\vec v$ | a vector (a list of numbers $v_1,\dots,v_n$) |
| $\lVert \vec v\rVert$ | the L2 norm (length) of $\vec v$ |
| $\vec y, \hat{\vec y}$ | the list of actual values and the list of predictions |

**Key points**
- $\lVert\vec v\rVert=\sqrt{v_1^2+\dots+v_n^2}$
  In words: square each entry, add them up, take the square root.
- $\lVert\vec y-\hat{\vec y}\rVert^2=\sum_i(y_i-\hat y_i)^2$
  In words: the squared length of the error list is the sum of squared errors.
- With a single number, the norm is just its absolute value.

**Memorize vs. look up:** Memorize both lines.

Related: [[Multiple Linear Regression]], [[Matrix Calculus for Least Squares]], [[Simple Linear Regression]]
