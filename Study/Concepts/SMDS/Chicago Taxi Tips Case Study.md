---
course: SMDS
week: 6
source: "[[chicago_taxi_trip_logistic_regression_python.ipynb]]"
status: new
tags: [generated]
---
# Chicago Taxi Tips Case Study
**In one line:** A full logistic regression project: predict whether a 2022 Chicago taxi trip gets a \$5+ tip.

**In plain words:** A rideshare company entering Chicago wants to know what drives big tips. Using 100,000 trips, the class built features, explored them, fit three models, and picked the best. Fare and airport trips matter most. Letting the airport effect change with fare (an interaction) didn't help, so the simpler model wins.

**Symbols**
| Symbol | Means |
|---|---|
| $p$ | probability of a \$5+ tip |
| $\text{logit}(p)$ | log-odds of a \$5+ tip |
| $\mathbf 1_\text{airport}$ | 1 if the trip starts or ends at Midway/O'Hare, else 0 |
| LRT, AIC | likelihood ratio test and Akaike score for picking models |

**Key points**
- **Features built:** `early_morning` (4–6 am), `airport`, `trip_minutes`, `speed`.
- **EDA verdict:** useful = fare (or trip miles) > airport > early morning > Sunday. Useless = trip minutes, speed, payment type, company.
- **Model 1:** $\text{logit}(p)=-4.78+0.12\,\text{fare}$
  In words: higher fares raise the odds of a big tip (about +13% per dollar).
- **Model 2:** $\text{logit}(p)=-4.27+0.056\,\text{fare}+2.85\,\mathbf 1_\text{airport}$
  In words: airport trips multiply the odds by $e^{2.85}\approx17$ at the same fare.
- **Model 3:** add fare × airport. The interaction weight is ≈ −0.001, basically zero.
- **Decision:** LRT p ≈ 0.56 and AIC slightly worse with the interaction (49,848 vs 49,846), so keep Model 2.

**Memorize vs. look up:** Memorize the workflow (problem → features → EDA → fit → Wald/LRT/AIC). The numbers are for reference.

Related: [[Class Imbalance]], [[Empirical Logit Plot]], [[Fitting Logistic Regression in Python and R]], [[Wald Test and Likelihood Ratio Test]], [[AIC, BIC and Adjusted R-squared]], [[Odds and Log-Odds]], [[Interaction Terms]]
