---
course: SMDS
week: 1
source: "[[adsp31014_lecture.html]]"
status: new
tags: [generated]
---
# Expectation
**In one line:** The average value you'd get if you could repeat something random forever.

**In plain words:** Expectation is the "center" of a random quantity. Its most useful property: the average of a sum is the sum of the averages, and constants just come along for the ride. That works every time, even when the variables depend on each other.

**Symbols**
| Symbol | Means |
|---|---|
| $X, Y$ | random variables (numbers that come out of a random process) |
| $\mathbb{E}(X)$ | expectation (mean) of $X$ |
| $a, b$ | ordinary fixed numbers (constants) |
| $X \perp Y$ | $X$ and $Y$ are independent (one tells you nothing about the other) |

**Key points**
- $\mathbb{E}(aX+b)=a\,\mathbb{E}(X)+b$
  In words: scale and shift the variable, and its average gets scaled and shifted the same way.
- $\mathbb{E}(X+Y)=\mathbb{E}(X)+\mathbb{E}(Y)$
  In words: the average of a sum is the sum of the averages. This always holds.
- $\mathbb{E}(XY)=\mathbb{E}(X)\,\mathbb{E}(Y)$ **only if** $X\perp Y$
  In words: the average of a product splits apart only when the two variables are independent.

**Example:** If $X$ averages 5, then $3X+2$ averages $3\times5+2=17$.

**Memorize vs. look up:** Memorize all three rules.

Related: [[Variance and Standard Deviation]], [[Covariance and Correlation]], [[Bias of an Estimator]]
