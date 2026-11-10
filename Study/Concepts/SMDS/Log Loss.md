---
course: SMDS
week: 5
source: "[[L5_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Log Loss
**In one line:** The error score logistic regression minimizes; it punishes confident wrong answers very hard.

**In plain words:** For each point, look at the probability the model gave to what *actually* happened, and take its log. Add those up: that's the log-likelihood. Log loss is the same thing with a minus sign, so lower is better. If the model said "1% chance" and the event happened, the penalty is huge. MSE isn't used because it makes the math messy and doesn't punish confident mistakes enough.

**Symbols**
| Symbol | Means |
|---|---|
| $y_i$ | actual outcome (0 or 1) |
| $p_i$ | model's predicted probability that $y_i=1$ |
| $\ell(\beta)$ | log-likelihood (higher = better) |
| $\beta$ | the model weights |

**Key points**
- $\ell(\beta)=\sum_i\big[y_i\log p_i+(1-y_i)\log(1-p_i)\big]$
  In words: for each point, take the log of the probability the model gave to the outcome that actually happened, and add them up.
- Log loss $=-\ell(\beta)$
  In words: flip the sign so it's an error to minimize. Minimizing log loss = maximum likelihood.
- No closed-form answer (unlike regression). Solved step by step; R uses Fisher scoring.
- Gotcha: if a line separates the 0's and 1's perfectly, the weights run off to infinity, R warns "did not converge", and standard errors explode.

**Memorize vs. look up:** Memorize what the formula says in words, and "log loss = −log-likelihood".

Related: [[Likelihood Principle and MLE]], [[Logistic Regression]], [[Deviance and Goodness of Fit]], [[Fitting Logistic Regression in Python and R]]
