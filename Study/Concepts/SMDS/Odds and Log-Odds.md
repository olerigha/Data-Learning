---
course: SMDS
week: 5
source: "[[L5_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Odds and Log-Odds
**In one line:** Odds compare "yes" to "no"; log-odds stretch that onto the whole number line so a straight line can model it.

**In plain words:** A probability lives between 0 and 1. Odds ("chance of yes ÷ chance of no") live between 0 and infinity. Taking the log spreads them over every number, negative to positive, with 0 meaning a 50/50 chance. In logistic regression, each input's weight tells you how much it **multiplies the odds**.

**Symbols**
| Symbol | Means |
|---|---|
| $p$ | probability of "yes" |
| $\frac{p}{1-p}$ | odds |
| $\log$ | natural log (base $e$) |
| $\beta_j$ | weight on input $x_j$ |
| $e^{\beta_j}$ | odds multiplier for +1 unit of $x_j$ |

**Key points**
- $\text{odds}=\dfrac{p}{1-p}$
  In words: how many times more likely "yes" is than "no".
- $\text{log-odds}=\log\dfrac{p}{1-p}$
  In words: the log of that. Negative means under 50%, 0 means exactly 50%, positive means over 50%.
- Weight reading: +1 unit of $x_j$ **multiplies the odds by $e^{\beta_j}$**. It does *not* add a fixed amount to the probability.

**Example:** winning chance 1/3 ⇒ odds $=\frac{1/3}{2/3}=\frac12$ ("one to two"). Taxi model: $\beta_\text{fare}=0.12$ ⇒ each extra dollar of fare multiplies the odds of a \$5+ tip by $e^{0.12}\approx1.13$ (about +13%).

**Memorize vs. look up:** Memorize both formulas and the $e^{\beta_j}$ reading.

Related: [[Logistic Regression]], [[Empirical Logit Plot]], [[Chicago Taxi Tips Case Study]]
