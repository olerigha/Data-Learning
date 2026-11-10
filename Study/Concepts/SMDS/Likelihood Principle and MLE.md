---
course: SMDS
week: 3
source: "[[L3_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Likelihood Principle and MLE
**In one line:** Pick the parameter value that makes the data you actually saw the most probable.

**In plain words:** For each possible value of the unknown knob, ask: "if this were true, how likely is my data?" That score is the likelihood. The maximum likelihood estimate (MLE) is the knob value with the highest score. We work with the log of the likelihood because it turns a product into a sum, which is easier to handle and doesn't run into tiny-number problems.

**Symbols**
| Symbol | Means |
|---|---|
| $\theta$ | the unknown parameter |
| $x_1,\dots,x_n$ | the observed data |
| $p_\theta(x_i)$ | probability of seeing $x_i$ if the parameter is $\theta$ |
| $L(\theta)$ | likelihood |
| $\ell(\theta)$ | log-likelihood ($=\log L$) |
| $\arg\max$ | "the value that maximizes" |
| $\hat\theta_\text{MLE}$ | the maximum likelihood estimate |

**Key points**
- $L(\theta)=\prod_i p_\theta(x_i)$
  In words: multiply the probabilities of every data point (they're independent).
- $\ell(\theta)=\sum_i\log p_\theta(x_i)$
  In words: the log turns the product into a sum, with the same best $\theta$.
- $\hat\theta_\text{MLE}=\arg\max_\theta \ell(\theta)$
  In words: the parameter value that makes the data most likely.
- Results: coin flips ⇒ $\hat p$ = share of heads. Bell curve ⇒ $\hat\mu$ = sample mean, $\hat\sigma^2$ = divide-by-$n$ variance (biased).
- Can misbehave: all tails ⇒ $\hat p=0$, "the coin can never land heads".

**Memorize vs. look up:** Memorize the idea, why we take logs, and the coin-flip result.

Related: [[Bernoulli and Binomial Distributions]], [[Bias of an Estimator]], [[Regression Assumptions]], [[Log Loss]], [[Wald Test and Likelihood Ratio Test]]
