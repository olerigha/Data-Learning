---
course: SMDS
week: 5
source: "[[L5_ADSP 31014 Statistical Models for Data Science.pdf]]"
status: new
tags: [generated]
---
# Confusion Matrix
**In one line:** A 2×2 scorecard of right and wrong yes/no calls, once you pick a cutoff.

**In plain words:** Logistic regression gives probabilities, not decisions. Pick a cutoff (say 0.5): above it you call "yes", below it "no". Then count four boxes: correct yes, correct no, false alarms, and misses. The cutoff is a business choice about which mistake costs more.

**Symbols**
| Symbol | Means |
|---|---|
| $\hat p_i$ | predicted probability of "yes" |
| $\tau$ | "tau", the cutoff (threshold) |
| $\hat y_i$ | predicted label: 1 if $\hat p_i\ge\tau$, else 0 |
| TP, FP, TN, FN | true positive, false positive (false alarm), true negative, false negative (miss) |

**Key points** (spam filter, 1 = spam)
- **Accuracy** = share of all emails classified correctly.
- **Recall / TPR** = TP ÷ all real spam
  In words: of the real spam, how much did we catch?
- **FPR** = FP ÷ all real good emails
  In words: of the good emails, how many did we wrongly flag?
- **Precision** = TP ÷ everything flagged
  In words: of what we flagged, how much was really spam?
- Raising $\tau$: fewer "yes" calls, so recall and FPR both drop and precision usually rises.
- ROC curve = recall vs FPR across all cutoffs; AUC is the area under it.

**Memorize vs. look up:** Memorize the four metrics in words and what raising $\tau$ does.

Related: [[Decision Boundary]], [[Logistic Regression]], [[Class Imbalance]]
