---
course: SMDS
week: 3
source: "[[L3_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Bias of an Estimator
**In one line:** An estimator is unbiased if, averaged over many possible samples, it hits the true value.

**In plain words:** An *estimator* is a recipe for guessing an unknown number from data (e.g. "take the average"). An *estimate* is what the recipe gives on your actual data. A recipe is unbiased if it's right on average, no matter what the true value is. A broken clock (always guess 0.4) is right only when the truth happens to be 0.4, so it's biased.

**Symbols**
| Symbol | Means |
|---|---|
| $\theta$ | the true unknown parameter |
| $\hat\theta$ | "theta-hat", the estimator (our guess) |
| $\mathbb{E}_\theta$ | average over many samples when the truth is $\theta$ |
| $\bar X$ | sample mean |
| $\sigma^2$ | true variance |
| $n$ | sample size |

**Key points**
- Unbiased: $\mathbb{E}_\theta(\hat\theta)=\theta$ for every $\theta$
  In words: on average, the guess equals the truth, whatever the truth is.
- The sample mean $\bar X$ is unbiased for the true mean.
- Sample variance: divide by $n-1$, not $n$
  In words: dividing by $n$ comes out a bit too small on average. The deviations from the mean must sum to 0, so only $n-1$ of them are free ("degrees of freedom").
- Statistical inference = point estimate + confidence interval + hypothesis test.
- Bias–variance tradeoff: sometimes a little bias is worth a lot less wobble.

**Memorize vs. look up:** Memorize the definition and why $n-1$.

Related: [[Expectation]], [[Variance and Standard Deviation]], [[Likelihood Principle and MLE]], [[Hypothesis Testing]]
