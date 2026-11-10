---
course: SMDS
week: 1
source: "[[adsp31014_lecture.html]]"
status: new
tags: [generated]
---
# Variance and Standard Deviation
**In one line:** How spread out a random quantity is around its average.

**In plain words:** Variance is the average *squared* distance from the mean. Because it's squared, its units are squared too (dollars²), so we usually take the square root to get the standard deviation, which is back in normal units. Shifting data doesn't change spread; stretching it does.

**Symbols**
| Symbol | Means |
|---|---|
| $\text{Var}(X)$ | variance of $X$ |
| $\text{SD}(X)$ | standard deviation of $X$ ($=\sqrt{\text{Var}(X)}$) |
| $\mathbb{E}(X)$ | mean of $X$ (see [[Expectation]]) |
| $\text{Cov}(X,Y)$ | covariance: how $X$ and $Y$ move together |
| $a, b$ | constants |

**Key points**
- $\text{Var}(X)=\mathbb{E}\big[(X-\mathbb{E}X)^2\big]$
  In words: on average, how far (squared) does $X$ land from its own mean?
- $\text{Var}(aX+b)=a^2\,\text{Var}(X)$ and $\text{SD}(aX+b)=|a|\,\text{SD}(X)$
  In words: adding $b$ slides everything over, so the spread doesn't change. Multiplying by $a$ stretches it: variance by $a^2$, SD by $|a|$.
- $\text{Var}(X+Y)=\text{Var}(X)+\text{Var}(Y)+2\,\text{Cov}(X,Y)$
  In words: the spread of a sum is the two spreads added, plus an extra term if they move together. If they're independent, that extra term is 0.
- A constant has variance 0, because it never changes.

**Example (R):** `var(x + 10)` equals `var(x)`; `var(10 * x)` equals `100 * var(x)`.

**Memorize vs. look up:** Memorize the scaling rule and the sum rule.

Related: [[Expectation]], [[Covariance and Correlation]], [[Bias of an Estimator]]
