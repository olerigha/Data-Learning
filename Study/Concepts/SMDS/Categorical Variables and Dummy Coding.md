---
course: SMDS
week: 3
source: "[[L3_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Categorical Variables and Dummy Coding
**In one line:** Turn categories into 0/1 columns so a regression can use them.

**In plain words:** A model can't multiply "Windy" by a number. So make a yes/no column for each category: 1 if the row is that category, 0 if not. One category is left out and becomes the **baseline**. Every other category's weight means "how much higher or lower than the baseline". Never keep all the columns *and* the intercept: they'd add up to the intercept column, and the model breaks.

**Symbols**
| Symbol | Means |
|---|---|
| $K$ | number of categories (levels) |
| $\mathbf{1}\{\text{Windy}\}$ | indicator: 1 if the row is Windy, else 0 |
| $\beta_0$ | intercept; with dummies, the baseline group's starting value |
| $\beta_\text{Windy}$ | how much Windy's line is shifted vs the baseline |

**Key points**
- $\text{feel}=\beta_0+\beta_1\,\text{temp}+\beta_\text{Windy}\,\mathbf 1\{\text{Windy}\}$
  In words: Sunny days use intercept $\beta_0$; Windy days use $\beta_0+\beta_\text{Windy}$. Both share the same slope, so you get two parallel lines.
- R picks the alphabetically first level as the baseline. Change it with `relevel()`.
- Use $K-1$ dummies with an intercept, or $K$ dummies with no intercept (`y ~ 0 + ...`). Never both.
- Python: `pd.get_dummies`, sklearn `OneHotEncoder`.

**Memorize vs. look up:** Memorize the baseline interpretation and "drop one level or the intercept".

Related: [[Multicollinearity]], [[Interaction Terms]], [[Normal Equation]], [[F-Test for Nested Models]], [[t-Test for Coefficients]]
