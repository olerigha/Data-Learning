---
course: SMDS
week: 3
source: "[[L3_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Polynomial Regression
**In one line:** Fit a curve by adding $x^2$, $x^3$, … as extra inputs.

**In plain words:** If the data bend, make new columns from the input, like $x$ squared, and feed them in as if they were separate inputs. The model is still "linear" because the weights are just added up; only the inputs are curved. Always keep the lower powers too (the plain $x$ and the intercept).

**Symbols**
| Symbol | Means |
|---|---|
| $x$ | the original input |
| $x^2, x^3$ | new inputs made by squaring / cubing $x$ |
| $\beta_0,\beta_1,\beta_2$ | weights for the intercept, $x$, and $x^2$ |

**Key points**
- $y=\beta_0+\beta_1x+\beta_2x^2+\epsilon$
  In words: a parabola. Same regression machinery, with $x^2$ as a second input.
- Keep lower-order terms: fit $\beta_0+\beta_1x+\beta_2x^2$, not just $\beta_2x^2$. Shifting $x$ (e.g. changing units) brings the lower terms back anyway.
- R gotcha: write `I(x^2)` or `poly(x, 2, raw = TRUE)`. A plain `x^2` in a formula means something else (interaction).
- Pick the degree with sequential F-tests.

**Memorize vs. look up:** Memorize "keep lower-order terms" and the `I()` gotcha.

Related: [[Linear Model]], [[Interaction Terms]], [[F-Test for Nested Models]], [[Regression Diagnostics]]
