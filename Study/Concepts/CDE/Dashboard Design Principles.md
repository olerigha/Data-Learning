---
course: CDE
week: 6
source: "[[Week6-BusinessIntelligence.pdf]]"
status: new
tags: [generated]
---
# Dashboard Design Principles
**In one line:** Design for the decision-maker: one question per dashboard, KPIs on top, the right chart for each question, and no clutter.

**In plain words:** Start from who will use the dashboard and what decision they need to make. Put the few headline numbers at the top and the detail below. Choose the chart from the question (trend → line, compare → bar), remove decoration that carries no information, and use color only to point at something. A number with nothing to compare it to (last month, target) means nothing.

**Terms**
| Term | Means |
|---|---|
| Chart junk | gridlines, 3D, decoration that adds no information |
| Data-ink ratio | Tufte: maximize ink spent on data |
| Pre-attentive attributes | position, color, size: noticed instantly |
| Progressive disclosure | summary first, detail on demand |
| Choropleth | map with regions shaded by a value |

**Key points**
- **Chart choice:** trend → line (time on the x-axis); compare categories → bar (sorted by value); part-to-whole → stacked bar / treemap (no pies over 3 slices); distribution → histogram / box plot; relationship → scatter.
- **Anti-patterns:** too many metrics, 3D charts, truncated y-axis, rainbow color scales, missing context.
- **Storytelling:** lead with the insight; annotate turning points; context → conflict → resolution.
- **At scale:** pre-aggregate, cache, stagger refreshes, under 5 alerts per user per day, archive stale dashboards.
- Tools practiced: Tableau, Excel, Metabase.

**Memorize vs. look up:** Memorize the chart-choice list and the anti-patterns.

Related: [[KPIs and the Semantic Layer]], [[BI vs Standard Reporting]], [[Chart Selection]], [[Three-Tier Data Apps]]
