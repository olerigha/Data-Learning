---
course: SMDS
week: 5
source: "[[L5_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Grouped vs Ungrouped Data
**In one line:** When every input is a category, rows with identical inputs can be pooled into "$y$ yeses out of $n$".

**In plain words:** Say the only input is hotel star rating (1–5). Instead of one row per review, you can have one row per star rating: "120 tidy out of 200 reviews". That's grouped data, modeled with a Binomial instead of a coin flip. The fitted model is identical. What changes is the number of "observations", which matters for some tests. With any continuous input (like fare), every row is its own group, so the data are ungrouped.

**Symbols**
| Symbol | Means |
|---|---|
| $k$ | number of groups (distinct input combinations) |
| $n_i$ | number of rows in group $i$ |
| $y_i$ | number of yeses in group $i$ |
| $\text{Binom}(n_i,p_i)$ | count of yeses out of $n_i$ tries |
| long / wide format | one row per observation / one row per group |

**Key points**
- Grouped model: $Y_i\sim\text{Binom}(n_i,p_i)$
  In words: each group's yes-count is a binomial with that group's probability.
- Same weights, predictions and fitted probabilities as the ungrouped version.
- Different: observations go from $n$ to $k$, which changes degrees of freedom and deviance.
- Some classical tests (deviance goodness-of-fit) only work for grouped data with big groups.
- R: `glm(cbind(y, n - y) ~ x, family = binomial)`, or proportions with `weights = n`.

**Memorize vs. look up:** Memorize what grouping changes and what it doesn't. Look up the R syntax.

Related: [[Bernoulli and Binomial Distributions]], [[Deviance and Goodness of Fit]], [[Logistic Regression]]
