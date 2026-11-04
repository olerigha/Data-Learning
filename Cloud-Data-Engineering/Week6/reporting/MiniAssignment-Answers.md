# Classic Models Dashboard: Mini-Assignment

## Build steps (warehouse version)

Table names in the local DW script (`Week5/warehouse/classicmodelsdw.sql`) are different from the handout. Use whichever names your server actually shows:

| Handout name              | Local DW script name | Relate on                                 |
| ------------------------- | -------------------- | ----------------------------------------- |
| `fact_sales_order_line` | `factOrderDetails` | (base table)                              |
| `dim_customer`          | `dimCustomers`     | `customerKey = customerKey`             |
| `dim_product`           | `dimProducts`      | `productKey = productKey`               |
| `dim_date`              | `dimtime`          | `orderDateId = dateId`                  |
| extended sales amount     | `lineTotal`        | (measure, = quantityOrdered × priceEach) |

1. **Connect:** Connect → To a Server → MySQL → enter the host, port, username and password → Database `classicmodels_dw` (or `classicmodelsdw`).
2. **Model:** drag the fact table onto the canvas. Drag each dimension next to it so it makes a relationship ("noodle"), not a join. Set each clause to the surrogate key shown above.
3. **Geo role:** right-click `country` (from the customer dimension, not the employee one) → Geographic Role → Country/Region.
4. **Format:** right-click `lineTotal` → Default Properties → Number Format → Currency, 0 decimals. You can rename it *Sales*.
5. **Sheet "Sales by Country":** double-click `country` → Marks: Map → `SUM(lineTotal)` on Color (Blues) and Label → `country` on Label.
6. **Sheet "Sales by Vendor":** `productVendor` on Rows, `SUM(lineTotal)` on Columns → Sort Descending → `SUM(lineTotal)` on Label.
7. **Sheet "Sales Trend by Product Line":** `date` (from the date dimension) on Columns as continuous Month → `SUM(lineTotal)` on Rows → Marks: Line → `productLine` on Color.
8. **Dashboard:** New Dashboard → drag in the three sheets (map and bar on top, trend along the bottom). On one sheet, put `productLine` on Filters → Show Filter → filter menu → Apply to Worksheets → All Using Related Data Sources. This makes the one filter control all three charts.
9. Screenshot the dashboard.

## Answers

Total sales = **$9,604,190.61** across 2,996 order lines. Check this in Tableau first: put `SUM(lineTotal)` on Text in a blank sheet.

**1. Top three countries:** **USA ($3.27M, 34.1%)**, **Spain ($1.10M, 11.4%)**, **France ($1.01M, 10.5%)**.
*Insight:* The US alone brings in about a third of revenue, and the top three bring in 56%, so demand is concentrated in a few markets. That makes the US relationship critical, and markets outside the top three are room to grow.

**2. Top vendor:** **Classic Metal Creations ($934,554)**. With the filter on **Classic Cars**, it is **still #1 ($702,577)**. Gearbox Collectibles ($539,935) moves to #2, and Unimax Art Galleries (#2 overall) drops out of the top three.
*Insight:* Classic Metal Creations gets about 75% of its sales from Classic Cars, so it is our most important supplier to protect. It is also a concentration risk if that one line slows down.

**3. Top product line:** **Classic Cars ($3.85M, 40.1% of sales)**, about double Vintage Cars ($1.80M).
*Pattern:* The trend has a strong yearly seasonal spike in **October–November** (Classic Cars hits about $404K and $416K in the two November peaks, roughly 2–3× a normal month). Every line follows the same shape. One year in the data has only five months (Jan–May), so its yearly total looks like a drop but isn't one. In the original MySQL data this is the last year, 2005.
*Insight:* Sales peak before the holidays, so inventory and marketing for Classic Cars should ramp up by early fall. Compare years only on months both years have.

> Your warehouse may use 2003–2005 instead of 2014–2016, depending on how it was loaded. The patterns and dollar totals are the same either way.
