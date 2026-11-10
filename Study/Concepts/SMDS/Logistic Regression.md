---
course: SMDS
week: 5
source: "[[L5_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Logistic Regression
**In one line:** A linear model for yes/no outcomes: it predicts the *probability* of "yes".

**In plain words:** A straight line can go below 0 or above 1, which makes no sense for a probability. Logistic regression fixes this by using the line to predict the **log-odds** instead (which can be any number), then squashing that back into a probability between 0 and 1 with an S-shaped curve. Despite the name, it's for classification, not regression.

**Symbols**
| Symbol | Means |
|---|---|
| $Y_i$ | the yes/no outcome for point $i$ (1 = yes, 0 = no) |
| $p_i$ | probability that $Y_i=1$ |
| $\text{Bern}(p_i)$ | a coin flip with chance $p_i$ (see [[Bernoulli and Binomial Distributions]]) |
| $\text{logit}(p)$ | log-odds: $\log\frac{p}{1-p}$ |
| $\text{expit}(z)$ | the S-curve $\frac{1}{1+e^{-z}}$; undoes the logit |
| $\beta_0,\dots,\beta_d$ | weights, as in linear regression |
| link function | the function connecting the probability to the straight-line part |

**Key points**
- $\text{logit}(p_i)=\beta_0+\beta_1x_{i1}+\dots+\beta_dx_{id}$
  In words: the log-odds of "yes" is a straight-line function of the inputs.
- $p_i=\dfrac{1}{1+e^{-(\beta_0+\beta_1x_{i1}+\dots)}}$
  In words: push the straight-line value through the S-curve to get a probability.
- $\beta_0$ slides the S-curve left or right; $\beta_1$ makes it steeper or flatter.
- It's a generalized linear model (GLM) with a logit link. Other links: probit (almost the same results), and log-log types for rare events.
- Dummies, interactions, polynomials, and VIF all work as in linear regression.
- R: `glm(y ~ x, family = binomial)`.

**Memorize vs. look up:** Memorize the logit equation and the S-curve formula. Look up the other links.

Related: [[Odds and Log-Odds]], [[Log Loss]], [[Bernoulli and Binomial Distributions]], [[Decision Boundary]], [[Linear Model]], [[Fitting Logistic Regression in Python and R]]
