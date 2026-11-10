---
course: SMDS
week: 4
source: "[[L4_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Regression Diagnostics
**In one line:** Look at the leftover errors (residuals) to check whether the model's assumptions hold.

**In plain words:** If the model is right, the residuals should look like random noise: no pattern, the same spread everywhere, roughly bell-shaped. Patterns in the residuals tell you what's wrong and how to fix it. If assumptions break, p-values and confidence intervals can't be trusted, though predictions may still be useful.

**Symbols**
| Symbol | Means |
|---|---|
| $r_i$ | residual for point $i$ (actual − predicted) |
| homoscedasticity | "same spread": constant error variance |
| heteroscedasticity | spread changes across the data |
| Q-Q plot | plot of residuals against what a perfect bell curve would give |

**Key points**
- **Linearity** (most important): plot residuals vs each input. A curve or systematic +/− pattern ⇒ add a transform, polynomial, or interaction.
- **Constant spread:** residuals fanning out (e.g. bigger houses, bigger price errors) ⇒ heteroscedasticity. Test: Breusch–Pagan (`lmtest::bptest`).
  - Fixes: model $\log y$ when errors grow with $y$, or use weighted least squares.
- **Normality:** Q-Q plot of residuals (`qqnorm`, `qqline`) should be a straight line. Tests: Shapiro–Wilk, Kolmogorov–Smirnov.
  - Only the residuals need to look normal, not the raw $y$ values.
- Big data almost always breaks something; judge whether it matters for your goal.

**Memorize vs. look up:** Memorize which plot checks which assumption, and the log fix. Look up the test names.

Related: [[Regression Assumptions]], [[Normal Distribution]], [[Polynomial Regression]], [[Deviance and Goodness of Fit]]
