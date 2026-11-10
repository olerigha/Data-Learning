---
course: SMDS
week: 1
source: "[[adsp31014_lecture.html]]"
status: new
tags: [generated]
---
# Covariance and Correlation
**In one line:** Measures of how strongly two variables move together *in a straight-line way*.

**In plain words:** Covariance is positive when two variables tend to be high together, and negative when one is high while the other is low. Its size depends on units, so it's hard to read. Correlation fixes that by rescaling to a number between −1 and 1. Both only see straight-line patterns: a perfect U-shape can have zero correlation.

**Symbols**
| Symbol | Means |
|---|---|
| $\text{Cov}(X,Y)$ | covariance of $X$ and $Y$ |
| $\text{Corr}(X,Y)$ | correlation of $X$ and $Y$, always between −1 and 1 |
| $\mathbb{E}$ | expectation (average) |
| $\text{SD}$ | standard deviation |

**Key points**
- $\text{Cov}(X,Y)=\mathbb{E}(XY)-\mathbb{E}(X)\,\mathbb{E}(Y)$
  In words: the average of the product, minus the product of the averages.
- $\text{Corr}(X,Y)=\dfrac{\text{Cov}(X,Y)}{\text{SD}(X)\,\text{SD}(Y)}$
  In words: covariance divided by both spreads, which removes the units.
- Correlation of ±1 means the points lie exactly on a line.
- Independent ⇒ correlation 0. But correlation 0 does **not** mean independent (e.g. $y=x^2$).
- Shifting or stretching (by a positive number) doesn't change correlation.
- In practice, a correlation around 0.6 is already fairly strong.

**Memorize vs. look up:** Memorize the correlation formula and "uncorrelated ≠ independent".

Related: [[Variance and Standard Deviation]], [[Simple Linear Regression]], [[Multicollinearity]], [[Coefficient of Determination]]
