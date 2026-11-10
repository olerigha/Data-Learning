---
course: SMDS
week: 1
source: "[[adsp31014_lecture.html]]"
status: new
tags: [generated]
---
# Parametric vs Nonparametric Models
**In one line:** Parametric = a fixed number of knobs to tune; nonparametric = the number of knobs grows with the data.

**In plain words:** A model is a simplified guess about how the data were produced. A parametric model commits to a shape up front (a line, a bell curve) and only tunes a few numbers. A nonparametric model lets the data decide the shape, so it gets more complex as you add data. This course is about parametric models.

**Symbols**
| Symbol | Means |
|---|---|
| $\theta$ | "theta", the model's parameters (the knobs) |
| $n$ | number of data points |
| $\text{Bern}(p)$ | coin-flip model with success chance $p$ |
| $\mathcal{N}(\mu,\sigma^2)$ | bell curve with center $\mu$ and spread $\sigma^2$ |
| $\beta_0,\dots,\beta_d$ | regression coefficients |

**Key points**
- Parametric examples: coin flips with $\text{Bern}(p)$ (1 knob), cholesterol with $\mathcal{N}(\mu,\sigma^2)$ (2 knobs), linear regression ($d+1$ knobs).
- Nonparametric examples: $k$-nearest neighbors, LOESS (a small regression around every point).
- Why model at all? To understand relationships, spot outliers, and predict new cases.

**Memorize vs. look up:** Memorize the definition and one example of each.

Related: [[Linear Model]], [[Bernoulli and Binomial Distributions]], [[Normal Distribution]]
