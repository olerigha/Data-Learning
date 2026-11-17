---
tags: [course-hub]
---
# SMDS — Statistical Models for Data Science (ADSP 31014)

The arc so far: probability review → linear regression as optimization → linear regression as a statistical model (tests, selection, diagnostics) → logistic regression for binary outcomes → Poisson regression for counts.

**How this course's material works:** the professor keeps one master lecture doc ([[adsp31014_lecture_master.html]]) and keeps extending it. Each week's `L<N>` PDF is a printout taken before class, so it often runs ahead of what's actually covered, and some weeks have no new PDF. The concepts below are grouped by master-doc **section**; the class log at the bottom records what was actually taught each week.

## Concepts by section

### §1–2 Prerequisites and modeling
- [[Expectation]] · [[Variance and Standard Deviation]] · [[Covariance and Correlation]]
- [[Parametric vs Nonparametric Models]]

### §3 Linear regression, part 1
- **Model and fit:** [[Linear Model]] · [[Simple Linear Regression]] · [[Coefficient of Determination]]
- **Matrix form:** [[L2 Norm]] · [[Multiple Linear Regression]] · [[Matrix Calculus for Least Squares]] · [[Normal Equation]] (also in [[adsp31014_mlr.pdf]])
- **Feature engineering:** [[Multicollinearity]] · [[Polynomial Regression]] · [[Categorical Variables and Dummy Coding]] · [[Interaction Terms]]

### §4 Statistical models
- [[Bernoulli and Binomial Distributions]] · [[Normal Distribution]]
- [[Bias of an Estimator]] · [[Likelihood Principle and MLE]]

### §5 Linear regression, part 2: inference and selection
- [[Regression Assumptions]] · [[Hypothesis Testing]]
- [[t-Test for Coefficients]] · [[F-Test for Nested Models]] · [[AIC, BIC and Adjusted R-squared]] · [[Stepwise Selection]]
- [[Regression Diagnostics]]

### §6 Logistic regression
- **Model:** [[Logistic Regression]] · [[Odds and Log-Odds]] · [[Log Loss]]
- **Classifying:** [[Confusion Matrix]] · [[Decision Boundary]]
- **Fit and selection:** [[Grouped vs Ungrouped Data]] · [[Deviance and Goodness of Fit]] · [[Wald Test and Likelihood Ratio Test]]
- **In practice (Chicago taxi notebooks):** [[Class Imbalance]] · [[Empirical Logit Plot]] · [[Fitting Logistic Regression in Python and R]] · [[Chicago Taxi Tips Case Study]]

### §7 Poisson regression
Source: [[L7_ADSP 31014 Statistical Models for Data Science.pdf]]; not yet covered in class as of Week 7.
- [[Poisson Distribution]] · [[Poisson Regression]] · [[Poisson Deviance and Residuals]] · [[Rate Data and Offset]]

## Class log
| Week | Lecture file | Covered in class | My notes |
|---|---|---|---|
| 1 | [[adsp31014_lecture.html]] | §1–3.4 | |
| 2 | [[adsp31014_mlr.pdf]] | §3.3 matrix form | |
| 3 | [[L3_ADSP 31014 Statistical Models for Data Science.pdf]] | §3.5–4.7 (per the PDF) | |
| 4 | [[L4_ADSP 31014 Statistical Models for Data Science.pdf]] | §5 (per the PDF) | |
| 5 | [[L5_ADSP 31014 Statistical Models for Data Science.pdf]] | §6 (per the PDF) | |
| 6 | no new PDF; [[chicago_taxi_trip_logistic_regression_python.ipynb]], [[chicago_taxi_trip_logistic_regression_r.Rmd]] | §6 continued; taxi case study | |
| 7 | [[L7_ADSP 31014 Statistical Models for Data Science.pdf]] (§7 Poisson) | §6.9 deviance and goodness of fit | [[Week 7 - Poisson Regression]] |

Weeks 1–6 are inferred from the PDFs, since there are no class notes for them; Week 7 comes from your class notes.

## Threads across sections
- **Least squares:** [[Simple Linear Regression]] → [[Normal Equation]] → [[Regression Assumptions]] (OLS = MLE under normal errors)
- **Likelihood:** [[Likelihood Principle and MLE]] → [[Log Loss]] → [[Deviance and Goodness of Fit]] → [[Wald Test and Likelihood Ratio Test]]
- **Model selection:** [[t-Test for Coefficients]] / [[F-Test for Nested Models]] (linear) ↔ [[Wald Test and Likelihood Ratio Test]] (logistic), with [[AIC, BIC and Adjusted R-squared]] for non-nested models
