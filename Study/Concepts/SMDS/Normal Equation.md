---
course: SMDS
week: 2
source: "[[adsp31014_mlr.pdf]]"
status: new
tags: [generated]
---
# Normal Equation
**In one line:** The formula that gives the best regression weights in one step.

**In plain words:** Setting the error's slope to zero gives a set of equations, one per weight. Solving them gives the best weights directly, with no trial and error. It only has a single answer if no input is an exact combination of the others. If one is (for example, two copies of the same column), there are infinitely many equally good answers.

**Symbols**
| Symbol | Means |
|---|---|
| $X$ | design matrix (inputs table, first column all 1's) |
| $X^\top$ | $X$ transposed (flipped) |
| $\vec y$ | list of actual outputs |
| $\hat{\vec\beta}$ | "beta-hat", the best weights |
| $(\cdot)^{-1}$ | matrix inverse (the matrix version of "divide by") |
| $\hat{\vec y}$ | list of fitted predictions |

**Key points**
- $X^\top X\,\vec\beta=X^\top\vec y$
  In words: the normal equation, $1+d$ equations for $1+d$ unknown weights.
- $\hat{\vec\beta}=(X^\top X)^{-1}X^\top\vec y$
  In words: "divide" $X^\top\vec y$ by $X^\top X$ to get the best weights.
- $X^\top X$ can't be inverted when columns of $X$ are redundant, e.g. perfect [[Multicollinearity]], or an intercept **plus** a dummy for every category.
- With one input it gives the same answer as [[Simple Linear Regression]].

**Memorize vs. look up:** Memorize the $\hat{\vec\beta}$ formula and when it fails.

Related: [[Matrix Calculus for Least Squares]], [[Multiple Linear Regression]], [[Multicollinearity]], [[Categorical Variables and Dummy Coding]]
