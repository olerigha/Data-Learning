---
course: SMDS
week: 7
source: "[[L7_ADSP 31014 Statistical Models for Data Science.pdf]] §7.7"
status: new
tags: [generated]
---
# Rate Data and Offset
**In one line:** When counts come from groups of different sizes, model the *rate* (count ÷ size) by adding $\log(\text{size})$ as an **offset**: a known term with no weight to estimate.

**In plain words:** A big city will have more accidents than a small one just because more people live there. What you really care about is the accident *rate* per person, and how speed limits change it. The trick: keep modeling the count with Poisson regression, but add the log of the population (the "exposure") to the right-hand side with its weight fixed at exactly 1. That's the offset. It's part of the data, not something to estimate.

**Symbols**
| Symbol | Means |
|---|---|
| $y_i$ | count for unit $i$ (accidents in city $i$) |
| $c_i$ | exposure: how many chances there were (city population) |
| $y_i/c_i$ | the rate (accidents per person) |
| $\lambda_i$ | expected count for unit $i$ |
| $x_i$ | input (speed limit) |
| $\beta_0,\beta_1$ | weights to estimate |
| $\log c_i$ | the **offset**: known, weight fixed at 1 |

**Key points**
- $\log\dfrac{\lambda_i}{c_i}=\beta_0+\beta_1x_i$
  In words: the log of the expected *rate* is a straight-line function of the input.
- Rewritten: $\log\lambda_i=\log c_i+\beta_0+\beta_1x_i$
  In words: same model for the count, with $\log c_i$ added on as a fixed extra term.
- R: `glm(accident ~ speed + offset(log(city)), family = poisson)`, or the `offset =` argument.
- If you just add `log(city)` as an ordinary input, it gets its own weight $\beta_2$. A Wald z-test of $\beta_2=1$ checks whether counts really grow in proportion to size.

**Memorize vs. look up:** Memorize what exposure and offset mean and why the offset's weight is fixed at 1.

Related: [[Poisson Regression]], [[Poisson Distribution]], [[Wald Test and Likelihood Ratio Test]]
