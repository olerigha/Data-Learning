---
course: SMDS
week: 4
source: "[[L4_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# AIC, BIC and Adjusted R-squared
**In one line:** Scores that reward good fit but charge a penalty for every extra input, so you can compare any two models.

**In plain words:** Plain $R^2$ always rises when you add inputs, even junk ones, so it can't pick models. These scores add a complexity penalty. AIC and BIC: lower is better. Adjusted $R^2$: higher is better. BIC's penalty is harsher, so it prefers smaller models. AIC and BIC numbers only mean something next to each other; there's no "good" AIC on its own.

**Symbols**
| Symbol | Means |
|---|---|
| $\ell$ | log-likelihood of the fitted model (higher = better fit) |
| $p$ | number of weights |
| $n$ | number of data points |
| $SS_\text{error}, SS_\text{total}$ | unexplained and total variation (see [[Coefficient of Determination]]) |

**Key points**
- $\text{AIC}=-2\ell+2p$
  In words: badness of fit plus 2 points per weight. Lower is better.
- $\text{BIC}=-2\ell+p\log n$
  In words: same, but each weight costs $\log n$ points, which is more than 2 once $n\ge8$.
- Adjusted $R^2=1-\dfrac{SS_\text{error}/(n-p)}{SS_\text{total}/(n-1)}$
  In words: $R^2$ with each variation divided by its degrees of freedom. It can go down when you add a useless input.
- Unlike F-tests, these work for non-nested models too.
- In practice, check all three and see which inputs keep getting picked.

**Memorize vs. look up:** Memorize lower/higher = better for each, and that BIC is stricter. Look up exact formulas.

Related: [[Coefficient of Determination]], [[F-Test for Nested Models]], [[Stepwise Selection]], [[Wald Test and Likelihood Ratio Test]]
