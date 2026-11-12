---
course: SMDS
week: 5
source: "[[L5_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Decision Boundary
**In one line:** The line (or flat surface) that splits "predict yes" from "predict no"; for logistic regression it's always straight.

Flying Carpet Example:

Tau is the threshold

**In plain words:** Saying "the probability is above the cutoff" is the same as saying "the straight-line part is above some number". So the border between yes and no is a straight line with two inputs, a flat plane with three, and so on. That's why logistic regression is called a *linear* classifier.

**Symbols**
| Symbol | Means |
|---|---|
| $\hat p$ | predicted probability |
| $\tau$ | cutoff |
| $\text{logit}(\tau)$ | the cutoff converted to log-odds |
| $\beta_0+\beta_1x_1+\dots$ | the straight-line part of the model |

**Key points**
- $\hat p\ge\tau \iff \beta_0+\beta_1x_1+\dots+\beta_dx_d\ge\text{logit}(\tau)$
  In words: being above the probability cutoff is the same as the straight-line score being above a fixed number.
- With cutoff 0.5, $\text{logit}(0.5)=0$, so the boundary is where the straight-line part equals 0.
- Example: hours studied vs midterm score; a straight line separates predicted pass from predicted fail.

**Memorize vs. look up:** Memorize the equivalence and that 0.5 ↔ 0.

Related: [[Confusion Matrix]], [[Logistic Regression]], [[Odds and Log-Odds]]
