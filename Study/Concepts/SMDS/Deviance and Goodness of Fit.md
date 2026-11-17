---
course: SMDS
week: 7
source: "[[L5_ADSP 31014 Statistical Models for Data Science.pdf]] §6.9; class 2026-11-10"
status: new
tags: [generated]
---
# Deviance and Goodness of Fit
**In one line:** Deviance measures how far your model is from a perfect model; the chi-squared goodness-of-fit test asks whether that gap is too big.

**In plain words:** Picture three models. The **null** model ignores the inputs and always predicts the overall average. The **saturated** model fits every data point (or group) perfectly. It's useless in practice, but no model can beat it, so it's the benchmark. **Your** model sits somewhere in between. Deviance is the size of the gap between a model and the perfect one, measured with log-likelihoods. A small residual deviance means your model is almost as good as perfect. Deviance plays the role that squared error plays in linear regression.

**Symbols**
| Symbol | Means |
|---|---|
| $\ell$ | log-likelihood: how probable the data are under a model (closer to 0 = better fit) |
| $\ell_\text{null}$ | log-likelihood of the null (intercept-only) model |
| $\ell_\text{model}$ | log-likelihood of your fitted model |
| $\ell_\text{sat}$ | log-likelihood of the saturated ("perfect") model |
| $D_\text{null}$ | null deviance: gap between the null model and perfect |
| $D_\text{res}$ | residual deviance: gap between your model and perfect |
| $k$ | number of groups (rows after grouping identical inputs) |
| $p$ | number of $\beta$ weights in your model ($1+d$) |
| $k-p$ | residual degrees of freedom |
| $\chi^2_{k-p}$ | chi-squared distribution with $k-p$ degrees of freedom; its average value is $k-p$ |
| $H_0$, $H_a$ | null and alternative hypothesis |

**Key points**
- $\ell_\text{null}<\ell_\text{model}<\ell_\text{sat}\le0$
  In words: your model beats the lazy one but can never beat the perfect one. What matters is where it sits in that gap.
- $D_\text{null}=-2(\ell_\text{null}-\ell_\text{sat})>0$
  In words: twice the gap between the lazy model and perfect.
- $D_\text{res}=-2(\ell_\text{model}-\ell_\text{sat})>0$
  In words: twice the gap between your model and perfect. Deviance is always measured against the saturated model.
- **Why −2?** The minus sign makes deviance positive. The 2 is exactly the scaling that makes it follow a chi-squared distribution, which is what lets us test it.
- In logistic regression the "scale" (dispersion) is fixed at 1, so *scaled deviance* and *deviance* are the same number.
- **χ² goodness-of-fit test** (grouped data only):
  - $H_0$: the model fits well. $H_a$: it doesn't.
  - If $H_0$ is true, $D_\text{res}\approx\chi^2_{k-p}$.
    In words: a well-fitting model's residual deviance behaves like a chi-squared number with $k-p$ degrees of freedom.
  - Big $D_\text{res}$ ⇒ $\ell_\text{model}$ far below $\ell_\text{sat}$ ⇒ small right-tail p-value ⇒ reject $H_0$: poor fit.
  - **Rule of thumb:** a chi-squared's average equals its degrees of freedom. So if $D_\text{res}$ is much smaller than $k-p$, the p-value is large and the model fits. If it's much larger, the model doesn't fit.
- **Only for grouped data** with big enough groups. For ungrouped data (e.g. any continuous input), the test isn't valid. Use "% deviance explained" $=1-D_\text{res}/D_\text{null}$ and look at prediction errors instead.
- Linear regression link: the lecture renames $SS_\text{total}$ to $SS_\text{null}$ and $SS_\text{error}$ to $SS_\text{model}$; for linear regression the residual deviance *is* that sum of squares.
- Residual types: response ($y-\hat p$), Pearson (standardized), deviance (the most fundamental for GLMs).

**Example (class, Week 7):** $\ell_\text{null}=-12.72$, $\ell_\text{model}=-6.449$, $\ell_\text{sat}=-6.25$.
- $D_\text{null}=-2(-12.72+6.25)=12.94$
- $D_\text{res}=-2(-6.449+6.25)=0.398$

In words: the null model is far from perfect, but your model nearly closes the gap. A residual deviance of 0.4 is below even a 1-degree-of-freedom chi-squared's average (1), so the p-value is large and the model fits well.

**Memorize vs. look up:** Memorize the three-model ordering, both deviance formulas, the test's $H_0$, and the "compare $D_\text{res}$ with its degrees of freedom" rule.

Related: [[Log Loss]], [[Grouped vs Ungrouped Data]], [[Coefficient of Determination]], [[Wald Test and Likelihood Ratio Test]], [[Regression Diagnostics]], class notes [[Week 7 - Poisson Regression]]
