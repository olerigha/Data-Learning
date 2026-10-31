**ADSP 31014 Statistical Models for Data Science**
**Course Project Part 2 — Linear Regression Model for Gas Turbine NOx Emissions**
Obaro Erigha

### Business Problem

The plant's operations and environmental compliance teams want to know which operating conditions are associated with lower NOx emissions *at a given level of power output*. The aim is to cut NOx without giving up turbine energy yield (TEY), which is the plant's revenue. The questions are:
1. Holding output fixed, how does NOx respond to the turbine inlet temperature (TIT) the control system runs at?
2. How much of the NOx variation is driven by ambient conditions the plant cannot control (temperature, pressure, humidity), which matters for planning and permit headroom?
3. How well does a model built on historical data predict NOx in later years, as a predictive emission monitoring system (PEMS) would need to?

### Data and Model Setup

The cleaned data from Part 1 (36,624 hourly records) were split **chronologically**. Data from 2011–2013 form the training set (22,089 rows) and data from 2014–2015 form the hold-out test set (14,535 rows). Candidate models were compared on an inner chronological validation: each was fit on 2011–2012 and scored on 2013. The test years were used only once, to evaluate the final model.

The response variable is NOx. Explanatory variables were chosen from the six ambient and process variables that are neither emissions nor near-duplicates of output. CO was excluded because it is a second emission produced by the same combustion state, not an operating condition the plant sets. Every predictor was centred at its training mean so that the intercept and linear terms describe a typical operating hour. The final model formula is

    log(NOx) ~ AT + AP + AH + TIT + TIT² + TEY        (all predictors centred)

The model has 7 parameters, with R² = 0.650 on the log scale (0.620 on the original NOx scale). See Appendix 1 for the model summary and estimated coefficients.

### Final Model and Interpretation

Because the response is log-transformed, each coefficient β approximates a 100·β % change in NOx per unit change in the predictor, holding the other predictors fixed. All terms are significant at p < 0.001.

| Term | Estimate | Effect on NOx (other predictors fixed) |
|---|---|---|
| AT | −0.0294 | −2.9 % per °C of ambient temperature |
| AP | −0.0026 | −0.26 % per mbar of ambient pressure |
| AH | −0.0040 | −0.39 % per percentage point of relative humidity |
| TEY | −0.0204 | −2.0 % per additional MWh, at the same TIT |
| TIT, TIT² | 0.0229, 0.00035 | +2.3 % per °C at the mean TIT (1083 °C); +3.5 % per °C at 1100 °C; minimum at 1051 °C |

- **Firing temperature and output must be read together.** In normal operation TIT rises 0.95 °C for each extra MWh of output (R² = 0.81). Combining the two coefficients along that line, one more MWh at the typical TIT increase changes NOx by only +0.13 %. That is why the marginal correlation between NOx and load is close to zero (Part 1). The usable lever is *TIT relative to load*. At the mean operating point, reaching the same TEY with TIT 10 °C lower is associated with **17.6 % less NOx**. TIT varies by 7.3 °C (one standard deviation) around its expected value at any given load, so a 10 °C reduction stays within conditions the turbine has actually run.
- **Curvature in TIT captures the part-load regime.** The quadratic is convex, with its minimum at 1051 °C. Only 4.2 % of training hours lie below that point. These are part-load hours where NOx and CO both rise, so the practical recommendation is to avoid sustained operation in that low-load band, not to aim for 1051 °C.
- **Ambient conditions.** Each extra 1 °C of ambient temperature lowers NOx by 2.9 %, so one standard deviation of AT (7.3 °C) is worth about 19 %. Winter is therefore the binding season for NOx compliance. Once temperature is controlled for, humidity *reduces* NOx (−0.39 % per point), which reverses the misleading positive marginal correlation seen in Part 1 and matches the known cooling effect of water vapour on flame temperature.

### Performance and Diagnostics

[Insert Figure 8: Actual vs predicted NOx, training and test — `figures/fig8_actual_vs_predicted.png`]

| Data | R² (NOx scale) | RMSE (mg/m³) | MAE (mg/m³) | Mean error (actual − predicted) |
|---|---|---|---|---|
| Training 2011–2013 | 0.620 | 6.81 | 4.60 | 0.00 |
| Validation 2013 (model fit on 2011–2012) | 0.514 | 8.40 | 6.02 | — |
| **Test 2014–2015** | **0.035** | **10.39** | **7.79** | **−5.74** |
| — Test 2014 only | 0.245 | 8.66 | 5.95 | −2.33 |
| — Test 2015 only | −0.128 | 11.83 | 9.57 | −9.05 |

Test performance is poor in R² terms, but the cause is specific. Predicted and actual NOx remain well correlated in the test years (r = 0.74), so the model ranks hours correctly. The problem is that it **over-predicts NOx by 5.7 mg/m³ on average**, and the bias grows from 2.3 in 2014 to 9.1 in 2015 (Figure 10). If that constant offset is removed, test RMSE falls from 10.39 to 8.66 and MAE from 7.79 to 6.54, close to the 2013 validation error. This is the 2014 level shift identified in Part 1. Refitting the model on all five years with year indicators puts NOx at 3.9 % (2014) and 12.4 % (2015) below the 2011 level after adjusting for every predictor. The model captures the operating physics correctly, but the turbine's baseline emission level changed after 2013 for a reason the data do not record.

[Insert Figure 10: Rolling mean of prediction error over time — `figures/fig10_residuals_over_time.png`]

[Insert Figure 7: Residuals vs fitted values — `figures/fig7_residuals_vs_fitted.png`]   [Insert Figure 9: Normal Q-Q plot of residuals — `figures/fig9_qq_residuals.png`]

- **Residuals vs fitted (Figure 7).** Across the bulk of the data (fitted log NOx between 3.95 and 4.75) the residuals are centred on zero with roughly constant spread. The LOWESS curve bends away only at the extremes, where few part-load hours lie. The log scale removed most of the heteroscedasticity: the correlation between |residual| and fitted value is 0.08, against 0.12 for the untransformed model. The Breusch–Pagan test still rejects constant variance (LM = 1,695), but at n = 22,089 almost any departure is significant.
- **Normality (Figure 9).** The Q-Q plot follows the line between roughly ±2 SD but has heavy tails (excess kurtosis 3.8; 308 standardised residuals beyond ±3). Coefficient estimates are unaffected, but prediction intervals based on a normal distribution would be too narrow in the tails.
- **Autocorrelation.** The Durbin–Watson statistic is 0.56 and the lag-1 residual autocorrelation is 0.72. Consecutive hours share unmodelled conditions, so ordinary OLS standard errors are too small. Newey–West (HAC, 24-lag) standard errors are 2.9–4.5 times larger, yet every retained term remains significant at p < 0.001.

### Key Considerations in Modelling

- **Multicollinearity.** With all nine ambient and process variables included, VIFs reach 442 (TEY), 427 (TIT), 356 (CDP), 261 (GTEP) and 165 (TAT). CDP and GTEP carry the same information as TEY (r ≥ 0.96), and TIT is almost a deterministic function of TAT and load (Part 1). Dropping CDP, GTEP and TAT brought all VIFs down to 11.1 or less and cost only 0.019 in adjusted R² (0.492 to 0.473 on the linear scale). TEY was kept as the output variable named in the business problem, and TIT as the main control lever. In the final model the linear TIT term has a VIF of 35.6. This comes mostly from its correlation with TIT², which is structural to a polynomial term and is not new collinearity; the remaining terms have VIFs of 23.4 (TEY) and below 5.4.
- **Log transformation.** NOx is right-skewed (skewness 1.11 in training). The log reduces this to 0.46, cuts residual skewness from 1.19 to 0.54, and reduces heteroscedasticity. It also turns coefficients into percentage effects, which suit emission-reduction targets.
- **Feature engineering and model selection.** The residuals of the purely linear model followed the non-linear TIT pattern seen in Part 1, Figure 2: they were positive at the lowest TIT and negative just above it. Adding TIT² raised validation R² from 0.26 to 0.46 and cut validation RMSE from 10.35 to 8.84. A TIT × TEY interaction was tested and added nothing (validation RMSE 10.34). Adding TEY² improved validation only marginally (8.42) while pushing the TIT and TEY VIFs to 80 and 63. AFDP became non-significant once frozen-sensor rows were removed (p = 0.57 OLS; 0.88 HAC). Dropping it gave the best validation result of all candidates (RMSE 8.40, R² 0.514) with the fewest terms, so it was removed.

### Shortcomings

- **Non-stationarity.** The model cannot anticipate a step change in baseline emissions. For PEMS use it would need regular recalibration, for example by re-estimating the intercept against a reference analyzer, or by including maintenance and tuning records that this data set lacks.
- **Association, not causation.** The −17.6 % figure for a 10 °C lower TIT at the same output is an observational association. TIT is calculated by the control system, not set independently, so the recommendation should be confirmed through controlled tuning trials before it is relied on for compliance.
- **Ambient pressure sign.** The negative AP coefficient runs against the standard emission pressure correction, under which NOx rises with pressure. It is small (−1.7 % per standard deviation) and probably absorbs seasonal weather patterns, so it should not be read as physical.
- **Unmodelled regimes.** Part-load hours (TEY below 110 MWh) are over-predicted by about 3.5 % on average, and the highest-load hours by about 4 %. A linear model with a single quadratic term cannot fully represent the combustor's switching between operating modes.
- **Correlated errors.** Strong serial correlation means the effective sample size is much smaller than 22,089, and the nominal p-values and confidence intervals in Appendix 1 are optimistic.

---

### Appendix 1 — Final Model Summary (statsmodels OLS, training data 2011–2013)

Predictors are centred at their training means: AT 17.759 °C, AP 1012.774 mbar, AH 79.555 %, TIT 1083.045 °C, TEY 133.482 MWh.

```
                            OLS Regression Results
==============================================================================
Dep. Variable:            np.log(NOx)   R-squared:                       0.650
Model:                            OLS   Adj. R-squared:                  0.650
Method:                 Least Squares   F-statistic:                     6849.
Date:                Thu, 29 Oct 2026   Prob (F-statistic):               0.00
Time:                        21:39:28   Log-Likelihood:                 21688.
No. Observations:               22089   AIC:                        -4.336e+04
Df Residuals:                   22082   BIC:                        -4.331e+04
Df Model:                           6
Covariance Type:            nonrobust
=================================================================================
                    coef    std err          t      P>|t|      [0.025      0.975]
---------------------------------------------------------------------------------
Intercept         4.1188      0.001   3517.800      0.000       4.116       4.121
AT_c             -0.0294      0.000   -183.556      0.000      -0.030      -0.029
AP_c             -0.0026      0.000    -24.931      0.000      -0.003      -0.002
AH_c             -0.0040   5.67e-05    -69.796      0.000      -0.004      -0.004
TIT_c             0.0229      0.000    105.909      0.000       0.022       0.023
I(TIT_c ** 2)     0.0004   3.51e-06    100.678      0.000       0.000       0.000
TEY_c            -0.0204      0.000   -110.461      0.000      -0.021      -0.020
==============================================================================
Omnibus:                     2902.898   Durbin-Watson:                   0.557
Prob(Omnibus):                  0.000   Jarque-Bera (JB):            14709.454
Skew:                           0.540   Prob(JB):                         0.00
Kurtosis:                       6.849   Cond. No.                         959.
==============================================================================

Notes:
[1] Standard Errors assume that the covariance matrix of the errors is correctly specified.
```
