---
course: SMDS
week: 3
source: "[[L3_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Interaction Terms
**In one line:** Multiply two inputs together so that the effect of one can depend on the other.

**In plain words:** Without an interaction, temperature affects "feels-like" the same way on sunny and windy days (parallel lines). Adding temperature × windy lets windy days have their **own slope** too. It's the same as fitting a separate line to each group.

**Symbols**
| Symbol | Means |
|---|---|
| $x_1, x_2$ | two inputs (e.g. temperature, windy yes/no) |
| $x_1x_2$ | the interaction: their product, used as a new input |
| $\beta_3$ | weight on the interaction: the *change in slope* between groups |
| main effects | the plain $x_1$ and $x_2$ terms |

**Key points**
- $y=\beta_0+\beta_1x_1+\beta_2x_2+\beta_3x_1x_2+\epsilon$
  In words: when $x_2=0$ the slope on $x_1$ is $\beta_1$; when $x_2=1$ it's $\beta_1+\beta_3$.
- R: `x1:x2` = the interaction alone; `x1 * x2` = `x1 + x2 + x1:x2`.
- `(x1+x2+x3)^2` gives all two-way interactions.

**Example:** Sunny: feel = 2.55 + 1.18 × temp. The interaction weight (−0.39) says Windy's slope is 0.39 lower.

**Memorize vs. look up:** Memorize `:` vs `*` and "own slope per group".

Related: [[Categorical Variables and Dummy Coding]], [[Polynomial Regression]], [[Linear Model]], [[F-Test for Nested Models]], [[Chicago Taxi Tips Case Study]]
