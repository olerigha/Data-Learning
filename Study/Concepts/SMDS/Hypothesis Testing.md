---
course: SMDS
week: 4
source: "[[L4_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Hypothesis Testing
**In one line:** Assume "nothing interesting is going on", then check how surprising your data would be under that assumption.

**In plain words:** The null hypothesis is the boring default (the coin is fair, the input does nothing). You boil the data down to one number, the test statistic, and ask: if the boring default were true, how often would we see something this extreme or more? That chance is the p-value. A tiny p-value means the data look very unusual under the default, so you reject it.

**Symbols**
| Symbol | Means |
|---|---|
| $H_0$ | null hypothesis: the default / no-effect claim |
| $H_1$ | alternative hypothesis: the challenger |
| $\alpha$ | "alpha", the significance level (e.g. 0.05) |
| $\chi^2_k$ | chi-squared distribution: sum of $k$ squared standard normals |
| $t_\nu$ | Student's t distribution: like a normal with fatter tails |
| $F_{d_1,d_2}$ | F distribution: ratio of two chi-squareds |

**Key points**
- p-value $=P_{H_0}(\text{a result at least this extreme})$
  In words: if the default were true, the chance of data this surprising or more.
- Small p-value (below $\alpha$) ⇒ reject $H_0$.
- **Type I error:** reject a true $H_0$ (a false alarm, usually the worse one). **Type II error:** miss a real effect.
- Common mistake: the p-value is **not** the probability that $H_0$ is true.
- The $\chi^2$, $t$ and $F$ distributions are the reference curves the tests compare against.

**Memorize vs. look up:** Memorize the p-value definition, the common mistake, and Type I vs II.

Related: [[t-Test for Coefficients]], [[F-Test for Nested Models]], [[Wald Test and Likelihood Ratio Test]], [[Bias of an Estimator]]
