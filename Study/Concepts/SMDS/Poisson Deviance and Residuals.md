---
course: SMDS
week: 7
source: "[[L7_ADSP 31014 Statistical Models for Data Science.pdf]] §7.5–7.6"
status: new
tags: [generated]
---
# Poisson Deviance and Residuals
**In one line:** Poisson regression reuses logistic regression's toolkit (null/saturated models, deviance, χ² tests, residuals), just with Poisson formulas.

**In plain words:** Same three-model picture as before. The **null** model predicts the overall average count for everyone. The **saturated** model predicts each point's own count exactly ($\hat\lambda_i=y_i$), which is perfect but useless. **Your** model sits between them. Residual deviance is twice the gap between your model and perfect; small means a good fit. Residuals need standardizing because bigger counts naturally wobble more.

**Symbols**
| Symbol | Means |
|---|---|
| $y_i$ | observed count for point $i$ |
| $\hat\lambda_i$ | your model's predicted average count for point $i$ |
| $\ell_\text{null},\ \ell_\text{model},\ \ell_\text{sat}$ | log-likelihoods of the null, your, and the saturated model |
| $D_\text{null},\ D_\text{res}$ | null deviance, residual deviance |
| $k-p$ | residual degrees of freedom (number of data points or groups minus number of weights) |
| $\chi^2_{k-p}$ | chi-squared distribution used for the goodness-of-fit p-value |

**Key points**
- $\ell_\text{null}<\ell_\text{model}<\ell_\text{sat}<0$, and the saturated model sets $\hat\lambda_i=y_i$.
- $D_\text{res}=-2(\ell_\text{model}-\ell_\text{sat})=2\sum_i y_i\log\dfrac{y_i}{\hat\lambda_i}$ (when the model has an intercept)
  In words: add up, over all points, how far each actual count is from its prediction on a log-ratio scale. A count of 0 contributes 0.
- With an intercept, the predicted counts add up to the actual total: $\sum\hat\lambda_i=\sum y_i$.
- **χ² goodness of fit:** $D_\text{res}\approx\chi^2_{k-p}$ if the model fits. It's only roughly valid when counts are large (about $y_i\ge10$). R: `pchisq(deviance(m), df.residual(m), lower.tail = FALSE)`.
- Wald z-test, χ² likelihood ratio test and AIC/BIC work exactly as in logistic regression.
- **Residuals:**
  - Response: $y_i-\hat\lambda_i$ (not comparable across points, since variance $=\lambda_i$).
  - Pearson: $\dfrac{y_i-\hat\lambda_i}{\sqrt{\hat\lambda_i}}$
    In words: the miss divided by the expected spread, so points are comparable.
  - Deviance: built from each point's share of $D_\text{res}$ (R's default `residuals(model)`).

**Memorize vs. look up:** Memorize "saturated = $\hat\lambda_i=y_i$", the Pearson residual, and that the χ² test needs large counts.

Related: [[Deviance and Goodness of Fit]], [[Poisson Regression]], [[Wald Test and Likelihood Ratio Test]], [[AIC, BIC and Adjusted R-squared]]
