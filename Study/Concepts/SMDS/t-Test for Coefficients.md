---
course: SMDS
week: 4
source: "[[L4_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# t-Test for Coefficients
**In one line:** Checks whether one input's weight is really different from zero.

**In plain words:** Divide the estimated weight by its uncertainty (standard error). If the weight is big compared with how wobbly it is, the input probably matters. The question being asked is always: "given **all the other** inputs are already in the model, does this one still add anything?" That's why removing one input changes everyone else's p-values.

**Symbols**
| Symbol | Means |
|---|---|
| $\hat\beta_j$ | estimated weight for input $x_j$ |
| $\text{s.e.}(\hat\beta_j)$ | standard error: how uncertain that estimate is |
| $t$ | the t-statistic |
| $t_{n-p}$ | t distribution with $n-p$ degrees of freedom |
| $n$, $p$ | number of data points, number of weights |

**Key points**
- $H_0:\beta_j=0$ ("this input is useless").
- $t=\dfrac{\hat\beta_j}{\text{s.e.}(\hat\beta_j)}$
  In words: how many standard errors the estimate sits away from zero.
- Compare with $t_{n-p}$ to get the p-value. It's the `Pr(>|t|)` column in `summary(model)`.
- Same answer as an F-test that drops just that input: $F=t^2$.
- With multicollinearity, two useful inputs can **both** look useless.
- For a category level, it only compares that level with the baseline. Use an F-test to test the whole category.

**Memorize vs. look up:** Memorize the statistic and its "all others already in" meaning.

Related: [[Hypothesis Testing]], [[F-Test for Nested Models]], [[Multicollinearity]], [[Categorical Variables and Dummy Coding]], [[Wald Test and Likelihood Ratio Test]]
