---
course: SMDS
week: 6
source: "[[chicago_taxi_trip_logistic_regression_python.ipynb]]"
status: new
tags: [generated]
---
# Fitting Logistic Regression in Python and R
**In one line:** Four ways to fit the same model, all giving the same weights.

**In plain words:** R's `glm` and Python's statsmodels give the full statistics table (p-values, deviance, AIC). scikit-learn is built for prediction and adds regularization by default, so you have to switch that off to get the same answer. Two gotchas matter more than the syntax.

**Symbols**
| Symbol | Means |
|---|---|
| `family=binomial` | tells the software the outcome is yes/no (logistic) |
| `C` | sklearn's regularization setting; `np.inf` = none |
| linear predictor | $\beta_0+\beta_1x$ before the S-curve |

**Key points**
- **R:** `glm(tips_5 ~ fare, family = binomial, data = data)`, then `summary()`, `anova()`, `AIC()`.
- **statsmodels (formula):** `smf.glm('tips_5 ~ fare', family=sm.families.Binomial(), data=df).fit()`
  - Gotcha: make $y$ a `pd.Categorical` with `categories=[True, False]`, because the **first** category counts as "yes".
  - `.predict()` gives probabilities; `.predict(which='linear')` gives the straight-line part.
- **statsmodels (arrays):** `sm.GLM(y, sm.add_constant(x), family=sm.families.Binomial())`. You add the intercept column yourself.
- **scikit-learn:** `LogisticRegression(C=np.inf).fit(x, y)`
  - Gotcha: without `C=np.inf` it regularizes, and the weights won't match `glm`.
  - `.predict_proba()` gives [P(no), P(yes)]; `.predict()` uses a 0.5 cutoff; `.score()` is accuracy.
- Interactions in sklearn: build the product column yourself (`x['fare_airport'] = x['fare'] * x['airport']`).

**Memorize vs. look up:** Memorize the two gotchas. Look up the rest when coding.

Related: [[Logistic Regression]], [[Log Loss]], [[Chicago Taxi Tips Case Study]], [[Interaction Terms]]
