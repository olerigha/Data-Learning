---
course: SMDS
week: 2
source: "[[adsp31014_mlr.pdf]]"
status: new
tags: [generated]
---
# Multiple Linear Regression
**In one line:** Linear regression with several inputs, written as one matrix equation.

**In plain words:** Instead of writing one equation per data point, stack all the inputs into a table (the design matrix $X$), all the weights into a list $\vec\beta$, and all the outputs into a list $\vec y$. Then "predictions = table × weights". The goal is still to make the squared errors as small as possible.

**Symbols**
| Symbol | Means |
|---|---|
| $n$ | number of data points (rows) |
| $d$ | number of inputs |
| $X$ | design matrix: $n$ rows × $(1+d)$ columns; first column is all 1's (for the intercept) |
| $\vec\beta$ | list of the $1+d$ weights ($\beta_0,\dots,\beta_d$) |
| $\vec y$ | list of the $n$ actual outputs |
| $X\vec\beta$ | list of the $n$ predictions |
| $\lVert\cdot\rVert$ | length of a list (see [[L2 Norm]]) |

**Key points**
- $\vec y\approx X\vec\beta$
  In words: each prediction is that row's inputs times the weights, added up.
- $\min_{\vec\beta}\lVert\vec y-X\vec\beta\rVert^2$
  In words: choose the weights that make the total squared error smallest.
- The column of 1's is how the intercept $\beta_0$ gets in.
- R: `model.matrix(y ~ x)` shows $X$.

**Memorize vs. look up:** Memorize what $X$, $\vec\beta$ and $\vec y$ are and their shapes.

Related: [[Simple Linear Regression]], [[L2 Norm]], [[Normal Equation]], [[Multicollinearity]], [[Categorical Variables and Dummy Coding]]
