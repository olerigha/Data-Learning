---
course: SMDS
week: 3
source: "[[L3_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Normal Distribution
**In one line:** The bell curve: symmetric, centered at its mean, and rarely far from it.

**In plain words:** Most values land near the middle and get rarer quickly as you move out. Every bell curve is the standard one (center 0, spread 1) slid over and stretched. Undo that slide-and-stretch and you've "standardized" the data. It matters because averages of many things tend to look normal (central limit theorem), and regression assumes normal errors.

**Symbols**
| Symbol | Means |
|---|---|
| $\mathcal{N}(\mu,\sigma^2)$ | normal distribution with center $\mu$ and variance $\sigma^2$ |
| $\mu$ | "mu", the mean (center) |
| $\sigma$ | "sigma", the standard deviation (spread) |
| $Z$ | a standard normal: $\mathcal{N}(0,1)$ |
| $\Phi$ | "Phi", the standard normal's cumulative probability function |

**Key points**
- $X=\mu+\sigma Z$
  In words: any normal is the standard one, stretched by $\sigma$ and shifted by $\mu$.
- $Z=\dfrac{X-\mu}{\sigma}$
  In words: standardize = subtract the mean, divide by the SD. The result has mean 0, SD 1.
- 68–95–99.7 rule: about 68% of values fall within 1 SD of the mean, 95% within 2, 99.7% within 3.
- Thin tails: values many SDs out are very rare. Kurtosis measures how heavy the tails are.
- (Same lecture: $\text{Unif}(a,b)$ is flat on $[a,b]$, with mean $(a+b)/2$.)

**Memorize vs. look up:** Memorize standardizing and the 68–95–99.7 rule.

Related: [[Bernoulli and Binomial Distributions]], [[Regression Assumptions]], [[t-Test for Coefficients]], [[Regression Diagnostics]]
