---
course: SMDS
week: 6
source: "[[chicago_taxi_trip_logistic_regression_python.ipynb]]"
status: new
tags: [generated]
---
# Empirical Logit Plot
**In one line:** A picture that checks whether logistic regression's straight-line assumption fits your data.

**In plain words:** A scatter of 0's and 1's is unreadable. So cut the input into bins, compute the share of yeses in each bin, and convert that share to log-odds. If logistic regression is a good fit, those points fall roughly on a straight line, the model's line. A bend means you need a transform or extra term.

**Symbols**
| Symbol | Means |
|---|---|
| bucket / bin | a range of $x$ values grouped together |
| fraction | share of $y=1$ inside a bucket |
| $\log\frac{\text{fraction}}{1-\text{fraction}}$ | the bucket's log-odds (empirical logit) |
| linear predictor | $\hat\beta_0+\hat\beta_1x$, the model's straight-line part |

**Key points**
- Step 1: bin $x$ (`pd.cut` into ~100 buckets) and plot each bucket's yes-fraction. It should follow the S-curve.
- Step 2: plot each bucket's log-odds against $x$, with the model's straight line on top.
  In words: if the dots hug the line, the model's shape is right.
- With a yes/no input (airport or not), draw separate dots and lines per group to see whether the slopes differ.
- It's the logistic version of the residual-vs-$x$ linearity check.

**Memorize vs. look up:** Memorize the idea: bin → fraction → log-odds → straight line? Look up the plotting code.

Related: [[Odds and Log-Odds]], [[Regression Diagnostics]], [[Interaction Terms]], [[Chicago Taxi Tips Case Study]]
