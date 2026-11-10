---
course: SMDS
week: 3
source: "[[L3_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Bernoulli and Binomial Distributions
**In one line:** Bernoulli = one yes/no event. Binomial = how many yeses in $n$ independent tries.

**In plain words:** Flip a possibly unfair coin once: heads (1) or tails (0). That's Bernoulli, with one knob $p$, the chance of a 1. Flip it $n$ times and count the heads: that's Binomial. The binomial is just $n$ Bernoullis added up, so its mean and variance are $n$ times the Bernoulli ones.

**Symbols**
| Symbol | Means |
|---|---|
| $p$ | probability of success (a 1) |
| $n$ | number of independent tries |
| $X$ | the random outcome |
| $\binom nx$ | "n choose x": number of ways to get $x$ successes in $n$ tries |

**Key points**
- Bernoulli: $P(X=x)=p^x(1-p)^{1-x}$ for $x\in\{0,1\}$
  In words: chance is $p$ if $x=1$ and $1-p$ if $x=0$, packed into one formula.
- Mean $p$, variance $p(1-p)$. Variance is biggest at $p=0.5$ (most uncertain).
- Binomial: $P(X=x)=\binom nx p^x(1-p)^{n-x}$
  In words: (ways to arrange $x$ successes) × (chance of $x$ successes) × (chance of the rest failing).
- Binomial mean $np$, variance $np(1-p)$.
- Bernoulli is what [[Logistic Regression]] models. Binomial shows up in A/B tests and grouped data.

**Memorize vs. look up:** Memorize the means and variances. Look up the binomial formula.

Related: [[Normal Distribution]], [[Likelihood Principle and MLE]], [[Logistic Regression]], [[Grouped vs Ungrouped Data]]
