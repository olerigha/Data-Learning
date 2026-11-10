---
course: SMDS
week: 2
source: "[[adsp31014_mlr.pdf]]"
status: new
tags: [generated]
---
# Matrix Calculus for Least Squares
**In one line:** Find the best weights the same way you find the bottom of a parabola: take the derivative and set it to zero.

**In plain words:** The squared error, written in matrix form, is a bowl-shaped (quadratic) function of the weights. At the bottom of a bowl the slope is zero. So you take the derivative with respect to the weights (the "gradient"), set it equal to zero, and solve. That gives the [[Normal Equation]].

**Symbols**
| Symbol | Means |
|---|---|
| $X$ | design matrix (inputs table) |
| $\vec\beta$ | list of weights |
| $\vec y$ | list of actual outputs |
| $X^\top$ | "X transpose": $X$ flipped so rows become columns |
| $\nabla$ | "gradient": the derivative with respect to every weight at once |

**Key points**
- 1-D warm-up: $a\beta^2-2b\beta+c$ has derivative $2a\beta-2b$; set to 0 ⇒ $\beta=b/a$.
- Matrix version: $\nabla_{\vec\beta}\lVert\vec y-X\vec\beta\rVert^2=2X^\top X\vec\beta-2X^\top\vec y$
  In words: the slope of the error with respect to the weights. It has the same shape as the 1-D case, with $X^\top X$ playing "$a$" and $X^\top\vec y$ playing "$b$".
- Set it to 0 ⇒ $X^\top X\vec\beta=X^\top\vec y$.

**Memorize vs. look up:** Memorize the idea (gradient = 0) and the 1-D analogy. Look up matrix-derivative rules.

Related: [[Normal Equation]], [[Multiple Linear Regression]], [[L2 Norm]]
