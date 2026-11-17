---
course: SMDS
week: 7
source: "[[L7_ADSP 31014 Statistical Models for Data Science.pdf]] §7.1–7.2"
status: new
tags: [generated]
---
# Poisson Distribution
**In one line:** A distribution for counts (0, 1, 2, …) of rare events, like accidents per year or customers per hour, where the average and the spread are the same number.

**In plain words:** When you count how many times something happens in a fixed window (an hour, a year, a city), and each individual event is unlikely but there are many chances for it, the count tends to follow a Poisson distribution. It has one knob, $\lambda$, the average count. The bigger the average, the bigger the spread. If you have many trials each with a tiny chance, the Binomial count is almost exactly Poisson, which is simpler to work with.

**Symbols**
| Symbol | Means |
|---|---|
| $X$ | the random count |
| $\lambda$ | "lambda", the rate / intensity: the average count ($\lambda>0$) |
| $x$ | a specific count value: 0, 1, 2, … |
| $e$ | Euler's number, ≈ 2.718 |
| $x!$ | "x factorial": $x\times(x-1)\times\dots\times1$ ($0!=1$) |
| $\text{Binom}(n,p)$ | count of successes in $n$ tries with chance $p$ each |

**Key points**
- $P(X=x)=\dfrac{e^{-\lambda}\lambda^x}{x!}$ for $x=0,1,2,\dots$
  In words: the chance of seeing exactly $x$ events when the average is $\lambda$.
- $\mathbb{E}(X)=\text{Var}(X)=\lambda$
  In words: the mean and the variance are equal, so busier counts are also noisier.
- Shape: single peak near $\lambda$, skewed to the right.
- **Law of rare events:** if $n$ is large and $p$ is small, $\text{Binom}(n,p)\approx\text{Poisson}(np)$.
  In words: many chances × small probability each ⇒ the count is about Poisson with average $np$.
- With very large counts, the central limit theorem lets you treat them as roughly normal too. The same data can be modeled several ways (linear, logistic or Poisson).

**Example:** Cars in a city having an accident this year. Strictly it's Binomial (a fixed number of cars, each with a small chance), but with many cars and a tiny chance each, Poisson is a good, simpler approximation.

**Memorize vs. look up:** Memorize mean = variance = $\lambda$ and the law of rare events. Look up the PMF if needed.

Related: [[Poisson Regression]], [[Bernoulli and Binomial Distributions]], [[Normal Distribution]], [[Likelihood Principle and MLE]]
