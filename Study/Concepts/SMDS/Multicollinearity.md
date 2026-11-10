---
course: SMDS
week: 3
source: "[[L3_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Multicollinearity
**In one line:** Two or more inputs carry nearly the same information, so the model can't tell which one deserves the credit.

**In plain words:** If height-in-inches and height-in-cm are both inputs, the model could give all the weight to either one, or split it any way, and predict equally well. So the weights become unstable and hard to interpret, even though predictions stay fine. It's about the inputs only, not $y$, and it can involve a mix of several inputs, not just one pair.

**Symbols**
| Symbol | Means |
|---|---|
| $x_j$ | the $j$-th input |
| $R_j^2$ | $R^2$ from predicting $x_j$ using all the *other* inputs |
| $\text{VIF}_j$ | variance inflation factor for input $x_j$ |
| $\beta_j$ | weight on $x_j$ |

**Key points**
- $\text{VIF}_j=\dfrac{1}{1-R_j^2}$
  In words: if the other inputs can predict $x_j$ well ($R_j^2$ near 1), the VIF blows up, so $x_j$ is redundant.
- Rule of thumb: VIF > 5 (i.e. $R_j^2>0.8$) is strong evidence. Consider dropping that input. If two inputs both have high VIF, keep one of them.
- Perfect case (e.g. $x_2=4x_1$): R says "1 not defined because of singularities".
- Symptoms: weights jump around with small data changes, and the "+1 in $x_j$, all else equal" reading stops making sense.
- It usually does **not** hurt fit or predictions, only the interpretation of the weights.

**Memorize vs. look up:** Memorize the VIF formula, the >5 rule, and "hurts interpretation, not prediction".

Related: [[Normal Equation]], [[Covariance and Correlation]], [[Categorical Variables and Dummy Coding]], [[t-Test for Coefficients]], [[Stepwise Selection]]
