---
course: SMDS
week: 6
source: "[[chicago_taxi_trip_logistic_regression_python.ipynb]]"
status: new
tags: [generated]
---
# Class Imbalance
**In one line:** One outcome is much more common than the other, so "always guess the common one" is already right most of the time.

**In plain words:** Before modeling, count how many yeses and nos you have. If 81% are "no", a model that always says "no" scores 81% accuracy without learning anything. Your real model has to beat that baseline. That's also why accuracy alone can mislead, and why precision, recall and the cutoff matter.

**Symbols**
| Symbol | Means |
|---|---|
| majority class | the more common outcome |
| baseline accuracy | share of the majority class |
| $\tau$ | cutoff for calling "yes" |

**Key points**
- First EDA check in the taxi notebook: `df['tips_5'].value_counts()` plus a percent column.
- Taxi data: 81% of trips tip under \$5, 19% tip \$5+.
- The fare-only model scores 87.9% accuracy. That's only about 7 points better than always guessing "no".
- Also compare each group's yes-rate with the overall rate (bar charts with a dashed line at the overall average) to spot useful inputs.

**Memorize vs. look up:** Memorize "compare accuracy with the majority-class baseline".

Related: [[Confusion Matrix]], [[Chicago Taxi Tips Case Study]], [[Logistic Regression]]
