---
course: SMDS
week: 1
source: "[[adsp31014_lecture.html]]"
status: new
tags: [generated]
---
# Linear Model
**In one line:** Predict $y$ as a weighted sum of the inputs, plus some unexplained noise.

**In plain words:** Each input gets a weight. Multiply each input by its weight, add them up, add a starting value, and that's the prediction. Whatever the model can't explain is the "error". "Linear" means the *weights* enter in a simple added-up way; the inputs themselves can be squared or logged.

**Symbols**
| Symbol | Means |
|---|---|
| $y$ | the response: what you want to predict |
| $x_1,\dots,x_d$ | the inputs (features, explanatory variables) |
| $d$ | how many inputs there are |
| $\beta_0$ | intercept: the prediction when every $x$ is 0 |
| $\beta_j$ | weight (coefficient) on input $x_j$ |
| $\epsilon$ | "epsilon", the error / noise the model can't explain |

**Key points**
- $y=\beta_0+\beta_1x_1+\dots+\beta_dx_d+\epsilon$
  In words: the prediction is a starting value plus each input times its weight, and $\epsilon$ is what's left over.
- Reading a weight: if $x_j$ goes up by 1 (everything else the same), $y$ goes up by $\beta_j$.
- One input = simple linear regression; two or more = multiple linear regression.
- Numeric $y$ = regression; category $y$ = classification.
- Still linear: $\beta_1\log x_1+\beta_2x_2^2$ (just new inputs). Not linear: $\beta_1x^{\beta_2}$ (a weight sits in an exponent).

**Memorize vs. look up:** Memorize the equation, how to read $\beta_j$, and what makes it "linear".

Related: [[Simple Linear Regression]], [[Multiple Linear Regression]], [[Polynomial Regression]], [[Interaction Terms]], [[Logistic Regression]]
