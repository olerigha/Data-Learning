---
course: SMDS
week: 1
source: "[[adsp31014_lecture.html]]"
status: new
tags: [generated]
---
# Simple Linear Regression
**In one line:** Draw the straight line through the data that makes the squared prediction errors as small as possible.

**In plain words:** For any line, measure how far each point sits above or below it (the residual), square those gaps, and average them. That average is the MSE. "Ordinary least squares" (OLS) picks the one line with the smallest MSE. The best line always goes through the middle of the data (the average $x$, average $y$ point). Squaring makes the math easy, but it also lets outliers pull the line a lot.

**Symbols**
| Symbol | Means |
|---|---|
| $x_i, y_i$ | the $i$-th data point's input and output |
| $n$ | number of data points |
| $\beta_0, \beta_1$ | intercept and slope of the line |
| $\hat y_i$ | "y-hat", the line's prediction for point $i$ |
| $r_i = y_i-\hat y_i$ | residual: actual minus predicted |
| $\bar x, \bar y$ | "x-bar", "y-bar": the averages of $x$ and $y$ |
| $\beta^*$ | the best (optimal) value of $\beta$ |

**Key points**
- $\text{MSE}=\frac1n\sum_i(y_i-\hat y_i)^2$
  In words: average the squared gaps between actual and predicted.
- $\beta_1^*=\dfrac{\text{Cov}(X,Y)}{\text{Var}(X)}$
  In words: best slope = how much $x$ and $y$ move together, divided by how much $x$ moves on its own.
- $\beta_0^*=\bar y-\beta_1^*\bar x$
  In words: pick the intercept so the line passes through (average $x$, average $y$).
- If you standardize both $x$ and $y$, the slope becomes their correlation.
- Changing units of $x$ changes the slope's number, not the predictions.
- R: `model <- lm(y ~ x, data = df)` then `predict(model, newdata = data.frame(x = 10))`.

**Example:** $x=(0.4,0.8,1.2,1.7,2.1)$, $y=(2,5,4.3,4.2,8)$ gives $\hat y=1.51+2.57x$.

**Memorize vs. look up:** Memorize the two $\beta^*$ formulas and "the line passes through the averages".

Related: [[Linear Model]], [[Covariance and Correlation]], [[Coefficient of Determination]], [[Multiple Linear Regression]], [[Normal Equation]]
