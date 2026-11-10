---
course: SMDS
week: 1
source: "[[adsp31014_lecture.html]]"
status: new
tags: [generated]
---
# Coefficient of Determination ($R^2$)
**In one line:** The fraction of the ups and downs in $y$ that your model explains.

**In plain words:** Start with the laziest model: always predict the average $y$. Its total error is the "total variation". Your real model makes smaller errors. $R^2$ says what share of that total variation your model got rid of. 1 = perfect, 0 = no better than guessing the average.

**Symbols**
| Symbol | Means |
|---|---|
| $y_i$ | actual value of point $i$ |
| $\hat y_i$ | model's prediction for point $i$ |
| $\bar y$ | average of all $y$'s |
| $SS_\text{total}$ | total sum of squares: total variation in $y$ |
| $SS_\text{reg}$ | regression sum of squares: variation the model explains |
| $SS_\text{error}$ | error sum of squares: variation left unexplained |

**Key points**
- $SS_\text{total}=\sum(y_i-\bar y)^2$
  In words: how far the data sit from their average, squared and added up.
- $SS_\text{error}=\sum(y_i-\hat y_i)^2$
  In words: how far the data sit from the model's predictions.
- $SS_\text{total}=SS_\text{reg}+SS_\text{error}$
  In words: total variation = explained part + unexplained part (when the model has an intercept).
- $R^2=1-\dfrac{SS_\text{error}}{SS_\text{total}}$
  In words: one minus the share of variation still unexplained.
- Higher $R^2$ ⇔ lower MSE (same information). $R^2$ also equals the squared correlation between actual and predicted values.

**Example:** total 18.68, unexplained 6.45 ⇒ $R^2=1-6.45/18.68=0.655$, so the model explains about 65%.

**Memorize vs. look up:** Memorize the decomposition and the $R^2$ formula.

Related: [[Simple Linear Regression]], [[AIC, BIC and Adjusted R-squared]], [[F-Test for Nested Models]], [[Deviance and Goodness of Fit]]
