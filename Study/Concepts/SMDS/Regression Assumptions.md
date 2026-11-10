---
course: SMDS
week: 4
source: "[[L4_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Regression Assumptions
**In one line:** Treat regression as a probability model: the truth is a straight line plus random bell-curve noise.

**In plain words:** Until now regression was just "find the best line". Now we add a story about where the data came from: each $y$ is the line's value plus random noise, and that noise is normal, has the same spread everywhere, and is independent from point to point. With that story, the best-line answer is also the maximum-likelihood answer, and we get p-values and confidence intervals.

**Symbols**
| Symbol | Means |
|---|---|
| $Y_i$ | the random response for point $i$ |
| $x_{ij}$ | input $j$ for point $i$ (treated as fixed, not random) |
| $\beta_0,\dots,\beta_d$ | true weights |
| $\epsilon_i$ | random error for point $i$ |
| $\mathcal{N}(0,\sigma^2)$ | bell curve centered at 0 with spread $\sigma$ |
| iid | "independent and identically distributed" |
| $p$ | number of weights, $1+d$ |
| $s^2$ | estimate of the error variance $\sigma^2$ |

**Key points**
- $Y_i=\beta_0+\beta_1x_{i1}+\dots+\beta_dx_{id}+\epsilon_i$, with $\epsilon_i\overset{iid}{\sim}\mathcal{N}(0,\sigma^2)$
  In words: response = straight-line part + independent bell-curve noise with the same spread for every point.
- Four assumptions: **linear** mean, **independent** errors, **constant variance** (homoscedasticity), **normal** errors.
- Normal errors ⇒ maximizing likelihood is the same as minimizing MSE, so OLS = MLE.
- $s^2=\dfrac{SS_\text{error}}{n-p}$
  In words: estimate the noise variance by dividing the squared errors by the leftover degrees of freedom.
- Payoff: hypothesis tests for picking inputs, and confidence intervals for predictions.

**Memorize vs. look up:** Memorize the model line and the four assumptions.

Related: [[Likelihood Principle and MLE]], [[Normal Distribution]], [[Regression Diagnostics]], [[t-Test for Coefficients]], [[Logistic Regression]]
