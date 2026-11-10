---
course: LCDS
week: 3
source: "[[Strategy for Data Scientists - Chapter 8 - Visualization.pdf]], [[Leadership and Consulting - Week 3.pdf]]"
status: new
tags: [generated]
---
# Chart Selection
**In one line:** Pick the chart that makes the point instantly for *this* audience, then follow each chart type's rules.

**In plain words:** Start from the audience: who they are, how much detail they need, and what decision they'll make. Then choose the visual that's easiest for them to read. Visuals beat words, and numbers alone can hide patterns: datasets with identical averages can look totally different when plotted (Anscombe's Quartet, the Datasaurus Dozen). If a slide doesn't make immediate sense, something's wrong.

**Terms**
| Term | Means |
|---|---|
| Anscombe's Quartet | four datasets with the same summary statistics but very different plots |
| Callout | label or highlight pointing at the key data point |
| Accent color | one highlight color on otherwise single-color bars |
| Implied meaning | similar color, shape or size makes viewers see a group |

**Key points**
- **Bar:** horizontal labels, one color plus an accent for the key bar.
- **Pie:** at most 5 slices, must add to 100%, don't compare several pies (use stacked bars).
- **Line:** at most 4 lines; make a 45° slope look like 45°; data should fill about ⅔ of the y-axis.
- **Scatter:** encode extra variables with dot size and color.
- **Bubble:** scale by area, not diameter; labels visible.
- **Heat map:** simple outline, one color in varying shades.
- **Best practices:** design each slide carefully, focus on what matters, simplify, remove distractions, always include a legend, highlight the key info, "get rid of text: visualize the story".

**Memorize vs. look up:** Memorize "audience first" and the pie and bar rules. Look up the rest.

Related: [[Misleading Charts]], [[Building the Deck]], [[Dashboard Design Principles]]
