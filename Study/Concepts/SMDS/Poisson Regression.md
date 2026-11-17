---
course: SMDS
week: 7
source: "[[L7_ADSP 31014 Statistical Models for Data Science.pdf]] §7.2–7.4"
status: new
tags: [generated]
---
# Poisson Regression
**In one line:** A GLM for count outcomes: predict the **log of the expected count** as a straight-line function of the inputs.

**In plain words:** Counts can't be negative, and they get noisier as they get bigger, so plain linear regression is a poor fit. Poisson regression assumes each count is Poisson with its own average $\lambda_i$. It models $\log\lambda_i$ with the usual weighted sum of inputs, then takes the exponential to get back a positive average. Because of the log, each weight acts as a **multiplier** on the expected count, not an add-on. Like logistic regression, it's fit by maximum likelihood with an iterative algorithm, since there's no closed-form answer.

**Symbols**
| Symbol | Means |
|---|---|
| $Y_i$ | the count for data point $i$ (0, 1, 2, …) |
| $\lambda_i$ | the expected (average) count for point $i$; also its variance |
| $\text{Poisson}(\lambda_i)$ | Poisson distribution with average $\lambda_i$ |
| $x_{i1},\dots,x_{id}$ | the $d$ inputs for point $i$ (treated as fixed) |
| $\beta_0,\dots,\beta_d$ | weights shared by all points; estimated from data |
| $\log$ | natural log; the **link function** |
| $e^{(\cdot)}$ | exponential; undoes the log |

**Key points**
- Assumptions: fixed inputs; independent counts; $Y_i\sim\text{Poisson}(\lambda_i)$; log link.
- $\log\lambda_i=\beta_0+\beta_1x_{i1}+\dots+\beta_dx_{id}$
  In words: the log of the expected count is a straight-line function of the inputs.
- $\lambda_i=e^{\beta_0+\beta_1x_{i1}+\dots+\beta_dx_{id}}$
  In words: take the exponential to get a positive expected count.
- **Reading a weight:** +1 unit of $x_j$ (all else fixed) **multiplies** the expected count by $e^{\beta_j}$.
- $\text{Var}(Y_i)=\lambda_i$: the spread grows naturally with the count.
- **Not the same as `lm(log(y) ~ x)`.** That models the average of $\log y$; Poisson models the log of the average of $y$. These differ (Jensen's inequality), and `lm(log(y))` breaks when $y=0$.
- Fit: maximum likelihood, solved by Fisher scoring. R: `glm(y ~ x, family = poisson)`; `predict(model, newdata, type = "response")` gives $\hat\lambda$.

**Example:** Customers per hour ($y$) vs promotion discount ($x$). If $\hat\beta_\text{promo}=0.05$, each extra unit of discount multiplies expected customers by $e^{0.05}\approx1.05$ (about +5%).

**Memorize vs. look up:** Memorize the log-link equation and the "multiplies by $e^{\beta_j}$" reading.

Related: [[Poisson Distribution]], [[Poisson Deviance and Residuals]], [[Rate Data and Offset]], [[Logistic Regression]], [[Odds and Log-Odds]], [[Likelihood Principle and MLE]]

*The 0.05 coefficient in the example is an illustration, not the lecture's fitted value.*
