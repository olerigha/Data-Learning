---
course: SMDS
week: 5
source: "[[L5_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Deviance and Goodness of Fit
**In one line:** Deviance is logistic regression's version of "squared error": how far your model is from a perfect one.

**In plain words:** Picture three models. The **null** model ignores the inputs and predicts the overall average. The **saturated** model fits every point perfectly (useless in practice, but a ceiling). **Your** model sits in between. Deviance measures the gap between your model and perfect. Smaller deviance = better fit. For linear regression, deviance is exactly the squared error.

**Symbols**
| Symbol | Means |
|---|---|
| $\ell_\text{null}$ | log-likelihood of the intercept-only model |
| $\ell_\text{model}$ | log-likelihood of your model |
| $\ell_\text{sat}$ | log-likelihood of the perfect (saturated) model |
| $D_\text{null}$ | null deviance |
| $D_\text{res}$ | residual deviance (usually just "deviance") |
| $k$, $p$ | number of groups, number of weights |
| $\chi^2_{k-p}$ | chi-squared distribution used for the test |

**Key points**
- $\ell_\text{null}<\ell_\text{model}<\ell_\text{sat}\le0$
  In words: your model fits better than the lazy one and worse than the perfect one.
- $D_\text{res}=-2(\ell_\text{model}-\ell_\text{sat})$
  In words: twice the gap between your model and perfect. The −2 makes it positive and links it to chi-squared tests.
- $D_\text{null}=-2(\ell_\text{null}-\ell_\text{sat})$
  In words: the same gap for the lazy model.
- Grouped data only: if $D_\text{res}$ is much bigger than $k-p$, the model doesn't fit well (chi-squared test).
- Ungrouped data: that test doesn't work. Use "% deviance explained" ($1-D_\text{res}/D_\text{null}$) and look at prediction errors.

**Memorize vs. look up:** Memorize the three-model picture and the $D_\text{res}$ formula.

Related: [[Log Loss]], [[Grouped vs Ungrouped Data]], [[Coefficient of Determination]], [[Wald Test and Likelihood Ratio Test]], [[Regression Diagnostics]]
