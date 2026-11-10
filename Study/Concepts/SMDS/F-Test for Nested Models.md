---
course: SMDS
week: 4
source: "[[L4_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# F-Test for Nested Models
**In one line:** Does the bigger model reduce error enough to justify its extra inputs?

**In plain words:** A bigger model always fits at least as well, because it can ignore the extra inputs. The F-test asks whether the error dropped by *more than you'd expect by chance* for the number of inputs you added. "Nested" means the small model is the big model with some weights set to zero.

**Symbols**
| Symbol | Means |
|---|---|
| $SS_\text{error}^\text{small}, SS_\text{error}^\text{large}$ | squared error of the small and large model |
| $p_\text{small}, p_\text{large}$ | number of weights in each model |
| $n$ | number of data points |
| $f$ | the F-statistic |
| $F_{d_1,d_2}$ | F distribution used for the p-value |

**Key points**
- $H_0$: the small model is good enough.
- $f=\dfrac{(\text{error drop})\,/\,(\text{extra weights})}{SS_\text{error}^\text{large}\,/\,(n-p_\text{large})}$
  In words: error saved per added weight, compared with the big model's leftover error per degree of freedom.
- Big $f$ ⇒ small p-value ⇒ the extra inputs are worth it.
- Uses: add one input, pick a polynomial degree, test an interaction, merge categories, and the "is anything useful?" test at the bottom of `summary()`.
- R: `anova(small.model, large.model)`.
- Only for nested models; otherwise use AIC/BIC.

**Memorize vs. look up:** Memorize the idea and $H_0$. Look up the exact formula.

Related: [[t-Test for Coefficients]], [[Hypothesis Testing]], [[AIC, BIC and Adjusted R-squared]], [[Stepwise Selection]], [[Polynomial Regression]], [[Wald Test and Likelihood Ratio Test]]
