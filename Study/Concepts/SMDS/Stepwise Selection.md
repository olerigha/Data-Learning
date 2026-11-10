---
course: SMDS
week: 4
source: "[[L4_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Stepwise Selection
**In one line:** Build a model by adding or removing one input at a time, instead of trying every combination.

**In plain words:** With many inputs there are too many possible models to fit them all. So go greedy: at each step make the single best move (add the most useful input, or drop the least useful one) and stop when no move helps. It's fast, but it can miss inputs that only work as a pair.

**Symbols**
| Symbol | Means |
|---|---|
| null model | intercept only, no inputs |
| full model | every input included |
| $k$ | penalty setting in R's `step()`: 2 = AIC, $\log n$ = BIC |

**Key points**
- **Forward:** start from the null model; add the most useful input each round; stop when nothing helps (e.g. p > 0.2).
- **Backward:** start from the full model; remove the least useful input each round.
- **Stepwise:** either add or remove at each step.
- Forward can miss a pair that's only useful together. Backward needs the full model to be fittable.
- Both cope with multicollinearity: redundant inputs rarely get added and tend to get removed.
- R: `add1()`, `drop1()`, `step()`. `step()` always decides using AIC or BIC.
- The order inputs enter or leave hints at their importance.

**Memorize vs. look up:** Memorize the three procedures and their weak spots. Look up the R arguments.

Related: [[F-Test for Nested Models]], [[AIC, BIC and Adjusted R-squared]], [[Multicollinearity]], [[t-Test for Coefficients]]
