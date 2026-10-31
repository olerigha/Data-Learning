**ADSP 31014 Statistical Models for Data Science**
**Course Project Part 1 — Gas Turbine CO and NOx Emissions**
Obaro Erigha

### Overview of Data Set

The data set contains 36,733 hourly records from a natural-gas-fired gas turbine at a combined-cycle power plant in north-western Turkey. The records cover five calendar years, 2011–2015. It was obtained from the UCI Machine Learning Repository (*Gas Turbine CO and NOx Emission Data Set*, Kaya, Tüfekci & Uzun, 2019), where it was published as a benchmark for predictive emission monitoring systems (PEMS). Each record is the hourly average of 11 signals:

- (3) Ambient conditions;
- (6) Process measurements taken around the compressor, combustor and turbine;
- (1) Turbine energy yield;
- (2) Regulated flue-gas emissions, carbon monoxide (CO) and nitrogen oxides (NOx).

The dataset contains five annual files with no timestamp or dates. Rows within each file are treated as chronological as stated in the data source description, which the clear seasonal cycle in Figure 6 supports.

[Insert Figure 1: Histograms of NOx and CO — `figures/fig1_hist_nox_co.png`]

*Figure 1: Distribution of hourly NOx (left) and CO (right) concentrations, 2011–2015.*

### Data Table Schema

The combined data set has 36,733 rows and 12 columns: the 11 sensor columns plus a `year` column added by myself during wrangling. Each row is one operating hour. Every column is a continuous decimal and none has missing values. Units follow the UCI documentation.

| Column Name | Description                               | Data Type | Example Value | Notes                                                                                                                                                                       |
| ----------- | ----------------------------------------- | --------- | ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AT          | Ambient temperature (°C)                 | decimal   | 4.588         | • Range −6.2 to 37.1 °C<br />• Mean 17.7 °C<br />• 62 hours below 0 °C <br />• Strong winter–summer cycle                                                        |
| AP          | Ambient pressure (mbar)                   | decimal   | 1018.7        | • Range 985.9–1036.6 mbar<br />• Recorded to 0.1 mbar (791 distinct values)                                                                                              |
| AH          | Ambient relative humidity (%)             | decimal   | 83.675        | • Range 24.1–100.2%<br />• Left-skewed (median 80.5) <br />• 478 hours above 100 % (sensor saturation)                                                                  |
| AFDP        | Air filter differential pressure (mbar)   | decimal   | 3.576         | • Range 2.1–7.6 mbar<br />• Mean falls from 4.31 (2012) to 3.60 (2015)                                                                                                   |
| GTEP        | Gas turbine exhaust pressure (mbar)       | decimal   | 23.979        | • Range 17.7–40.7 mbar<br />• Near-duplicate of CDP and TEY (r ≥ 0.96)                                                                                                  |
| TIT         | Turbine inlet temperature (°C)           | decimal   | 1086.2        | • Range 1000.8–1100.9; left-skewed <br />• 19.3 % of hours within 1 °C of the 1100.9 °C maximum                                                                        |
| TAT         | Turbine after (exhaust) temperature (°C) | decimal   | 549.83        | • Range 511.0–550.6 °C<br />• 63.9 % of hours within 1 °C of the 550.6 °C maximum                                                                                    |
| CDP         | Compressor discharge pressure (mbar)      | decimal   | 11.898        | • Range 9.9–15.2 mbar<br />• r = 0.99 with TEY                                                                                                                           |
| TEY         | Turbine energy yield (MWh)                | decimal   | 134.67        | • Range 100.0–179.5                                                                                                                                                       |
| CO          | Carbon monoxide (mg/m³)                  | decimal   | 0.327         | • Median 1.72 mg/m³<br />• mean 2.38 mg/m³<br />• max 44.1 mg/m³<br />• highly right-skewed                                                                       |
| NOX         | Nitrogen oxides (mg/m³)                  | decimal   | 81.952        | • Median 63.9, <br />• mean 65.3, <br />• range 25.9–119.9<br />•102 consecutive hours frozen at 60.38 in 2011 <br />• Annual mean drops by 8–10 units in 2014–2015 |
| year        | Source file year (added)                  | integer   | 2011          | • Year                                                                                                                                                                     |

### Data Cleaning and Processing

The five annual files were concatenated and tagged with `year`. A within-year row index was also kept so that seasonal patterns could be examined. No missing values were found in any column. Two data-quality problems were identified, and those rows were removed:

- **Exact duplicate records (7 rows):** Two runs of identical consecutive rows in 2014 (5 and 4 copies, respectively).
- **Frozen NOx analyzer (102 rows):** NOx reads exactly 60.38 mg/m³ for 102 consecutive hours in 2011 while every other signal keeps moving. Highly unusual for hourly averages to repeat for more than a few hours, so these identical consecutive NOx values were treated as an analyzer fault.

Physically impossible values were kept rather than removed. There are relative humidity slightly above 100 %, TAT and TIT at their control ceilings, and the CO tail up to 44 mg/m³. These represent either sensor saturation or real operating states, not data-entry errors. The resulting cleaned data set has **36,624 rows**.

### Exploratory Findings

**Emission distributions (Figure 1).** NOx is unimodal and centred around 60–65 mg/m³, with a long right tail: the 99th percentile is 105 and the maximum 120. CO is far more skewed. Its median is only 1.72 mg/m³, yet 1 % of hours exceed 11 mg/m³.

[Insert Figure 2: Scatter plot of NOx vs TIT with trend line — `figures/fig2_nox_vs_tit.png`]

**NOx versus turbine inlet temperature (Figure 2).** Combustion theory would predict that NOx would rise with firing temperature. However, the pooled data show the opposite on average: the linear fit has a slope of −0.14 mg/m³ per °C, but it explains only 4.6 % of the variance. Hours below 1050 °C, which are 6.3 % of the data and mostly part-load operation, average 80.5 mg/m³ of NOx, against 64.3 above that temperature. Between about 1055 °C and 1080 °C NOx is fairly flat near 60. There is a distinct cluster at 1083–1087 °C, the base-load operating point, where mean NOx jumps to 70–74. That is consistent with the expected positive temperature effect once load is held roughly constant.

[Insert Figure 3: Scatter plot of CO vs NOx — `figures/fig3_co_vs_nox.png`]

**CO–NOx trade-off (Figure 3).** Combustion theory would expect a trade off  the two pollutants: hotter, more complete combustion lowers CO but raises NOx. The data agress with this and shows CO falls sharply as TIT rises (r = −0.71), from a mean of 6.2 mg/m³ below 110 MWh to 1.2 mg/m³ above 160 MWh. The NOx side does not show up as a simple inverse relationship.  At partial load the turbine emits more of both pollutants.

[Insert Figure 4: Correlation heatmap — `figures/fig4_corr_heatmap.png`]

**Correlation structure (Figure 4).** The process variables form one tightly correlated block that describes turbine load: CDP–TEY r = 0.99, GTEP–CDP 0.98, GTEP–TEY 0.96, and TIT–TEY 0.91. TAT is negatively related to that block because exhaust temperature is held at its control limit as load increases. Ambient temperature is the single strongest correlate of NOx (r = −0.56). Every load-related variable has only a weak marginal correlation with NOx (|r| ≤ 0.21). The heatmap also points to severe multicollinearity.

[Insert Figure 5: Boxplot of NOx across AT deciles — `figures/fig5_nox_by_at_decile.png`]

**Ambient temperature effect (Figure 5).** Median NOx falls steadily from 77.6 mg/m³ in the coldest temperatures (below 7.9 °C) to 57.3 mg/m³ at 22.5–24.9 °C, and then levels off at about 57 in the three warmest temperatures. The relationship is strong and holds in every year.

### Anomalies and Interesting Aspects

[Insert Figure 6: Seasonal NOx profile by year — `figures/fig6_nox_seasonal_by_year.png`]

- **Step change in NOx after 2013 (Figure 6).** Annual mean NOx is 67.7, 68.8 and 70.0 mg/m³ in 2011–2013, then drops to 60.1 in 2014 and 59.9 in 2015. Ambient conditions and turbine output did not change by a comparable amount: mean AT and TEY are within 1.3 °C and 3.6 MWh of each other across all five years.
- **Frozen sensors.** Besides the removed NOx run, CO repeats one value (0.11124 mg/m³) 21 times early in 2014.
- **Varying part-load share.** The share of part-load hours (TEY below 110 MWh) varies from 2.6 % in 2011 to 16.0 % in 2013, so the annual emission mix depends partly on how the unit was operated.
