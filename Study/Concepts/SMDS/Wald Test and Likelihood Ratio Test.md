---
course: SMDS
week: 5
source: "[[L5_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Wald Test and Likelihood Ratio Test
**In one line:** Logistic regression's versions of the t-test and F-test for deciding which inputs to keep.

**In plain words:** The **Wald test** checks one weight: is it far from zero compared with its uncertainty? It's the p-value R prints next to each weight. The **likelihood ratio test (LRT)** compares a smaller model to a bigger one: did the deviance drop enough to be worth the extra inputs? Unlike in linear regression, the two can disagree. When they do, trust the LRT.

**Symbols**
| Symbol | Means |
|---|---|
| $\hat\beta_j$ | estimated weight |
| $\text{s.e.}$ | its standard error (uncertainty) |
| $z$ | Wald statistic, compared with a standard normal $\mathcal{N}(0,1)$ |
| $D_\text{res}^\text{small}, D_\text{res}^\text{large}$ | deviance of the smaller and larger model |
| $p_\text{small}, p_\text{large}$ | number of weights in each |
| $\chi^2$ | chi-squared distribution used for the LRT p-value |

**Key points**
- Wald: $z=\dfrac{\hat\beta_j}{\text{s.e.}}$
  In words: how many standard errors the weight is from zero. It's the `Pr(>|z|)` column in `summary()`.
- LRT: $D_\text{res}^\text{small}-D_\text{res}^\text{large}\sim\chi^2_{p_\text{large}-p_\text{small}}$
  In words: how much the deviance dropped, compared with what chance alone would give for that many extra inputs.
- Both are approximate. The LRT is usually more reliable, so prefer it.
- R: `anova(small, large, test = "Chisq")` or `drop1(model, test = "Chisq")`.
- Linear regression: still use the exact F-test. Non-nested models: use AIC/BIC.

**Memorize vs. look up:** Memorize what each test compares, and "prefer LRT".

Related: [[t-Test for Coefficients]], [[F-Test for Nested Models]], [[Deviance and Goodness of Fit]], [[AIC, BIC and Adjusted R-squared]], [[Hypothesis Testing]], [[Chicago Taxi Tips Case Study]]
