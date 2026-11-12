---
tags: [course-hub]
---
# SMDS — Statistical Models for Data Science (ADSP 31014)

The arc so far: probability review → linear regression as optimization → linear regression as a statistical model (tests, selection, diagnostics) → logistic regression for binary outcomes.

## Weeks

### Week 1 — Prerequisites and simple linear regression
Source: [[adsp31014_lecture.html]] §1–3.4
- [[Expectation]] · [[Variance and Standard Deviation]] · [[Covariance and Correlation]]
- [[Parametric vs Nonparametric Models]] · [[Linear Model]]
- [[Simple Linear Regression]] · [[Coefficient of Determination]]

### Week 2 — Multiple linear regression in matrix form
Source: [[adsp31014_mlr.pdf]]
- [[L2 Norm]] · [[Multiple Linear Regression]] · [[Matrix Calculus for Least Squares]] · [[Normal Equation]]

### Week 3 — Feature engineering and statistical models
Source: [[L3_ADSP 31014 Statistical Models for Data Science.pdf]] §3.5–4.7
- [[Multicollinearity]] · [[Polynomial Regression]] · [[Categorical Variables and Dummy Coding]] · [[Interaction Terms]]
- [[Bernoulli and Binomial Distributions]] · [[Normal Distribution]]
- [[Bias of an Estimator]] · [[Likelihood Principle and MLE]]

### Week 4 — Linear regression part 2: inference and model selection
Source: [[L4_ADSP 31014 Statistical Models for Data Science.pdf]] §5
- [[Regression Assumptions]] · [[Hypothesis Testing]]
- [[t-Test for Coefficients]] · [[F-Test for Nested Models]] · [[AIC, BIC and Adjusted R-squared]] · [[Stepwise Selection]]
- [[Regression Diagnostics]]

### Week 5 — Logistic regression
Source: [[L5_ADSP 31014 Statistical Models for Data Science.pdf]] §6
- [[Logistic Regression]] · [[Odds and Log-Odds]] · [[Log Loss]]
- [[Confusion Matrix]] · [[Decision Boundary]]
- [[Grouped vs Ungrouped Data]] · [[Deviance and Goodness of Fit]] · [[Wald Test and Likelihood Ratio Test]]

### Week 6 — Logistic regression in practice (Chicago taxi tips)
Source: [[chicago_taxi_trip_logistic_regression_python.ipynb]],[[chicago_taxi_trip_logistic_regression_r.Rmd]]
- [[Class Imbalance]] · [[Empirical Logit Plot]] · [[Fitting Logistic Regression in Python and R]] · [[Chicago Taxi Tips Case Study]]

## Threads across weeks
- **Least squares:** [[Simple Linear Regression]] → [[Normal Equation]] → [[Regression Assumptions]] (OLS = MLE under normal errors)
- **Likelihood:** [[Likelihood Principle and MLE]] → [[Log Loss]] → [[Deviance and Goodness of Fit]] → [[Wald Test and Likelihood Ratio Test]]
- **Model selection:** [[t-Test for Coefficients]] / [[F-Test for Nested Models]] (linear) ↔ [[Wald Test and Likelihood Ratio Test]] (logistic), with [[AIC, BIC and Adjusted R-squared]] for non-nested models
