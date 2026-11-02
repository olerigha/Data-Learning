# ASSUMPTIONS

| ID | Area | Assumption | Number | Why | Status |
|---|---|---|---|---|---|
| A-001 | Units | All BDG2 energy meter readings are kWh (CHW and steam are thermal kWh) | 1 ton = 3.51685 kWh | BDG2 paper Tables 4–5 | **VERIFIED** (paper) |
| A-002 | Location | Bull = Austin, TX (US/Central, 30.2672,-97.7431) | — | A1 carry-over; paper lists UT Austin among sites | Consistent, not explicitly mapped |
| A-003 | Volume | 308 meters × 92 days | 28,336 rows | D-003 | **VERIFIED** (script output) |
| A-004 | CHW rate | Chilled water cost = TX commercial elec price ÷ central plant COP | COP 4.0 → $0.0204–0.0206/kWh-th | Electric centrifugal chillers ≈ 0.7–0.9 kW/ton incl. auxiliaries ≈ COP 4–5 | ASSUMED, pending G1-2 |
| A-005 | Steam rate | Gas-fired boiler steam | $0.034/kWh-th | ≈$8/MMBtu TX commercial gas ÷ 0.8 boiler efficiency ≈ $10/MMBtu; 1 MMBtu = 293.07 kWh | ASSUMED |
| A-006 | Daily aggregation | Daily kWh = sum of non-null hourly values; null when 0 hours reported | — | Partial days kept and flagged via hours_reported | Applied |
| A-007 | Price grain | One TX commercial price per calendar month applies to all hours | 8.24 / 8.17 / 8.16 ¢ | EIA-861M is monthly; campus is a commercial-class customer | Applied |
| A-008 | Normalization | A building has at most one meter per utility type, so (building, utility) identifies a meter | 308 pairs = 308 meters | Observed in BDG2 Bull; BDG2 names meters by building per utility file | VERIFIED (data) |
| A-009 | Normalization | Each sub-usage belongs to exactly one primary usage | 15 subs, 0 with >1 parent | FD6 check | VERIFIED (data) |
| A-010 | Normalization | Weather is observed per site per day (not per building) | 92 site-days | BDG2 weather is keyed by site_id | VERIFIED (source schema) |
| A-011 | Normalization | Tariff is set per utility per calendar month; stored unit_rate is a business decision (contract rate), not recomputed from EIA price at query time | 9 rows | Keeps rate auditable if a negotiated rate replaces the EIA basis | ASSUMED |
| A-012 | Cleansing | Sub-usage casing standardised to Title Case on load ('office'→'Office', 'garage'→'Garage') | 2 values, 6 buildings | Anomaly is documented in Part 2; storing it twice in a lookup table would create a false category | DECISION D-007 |
| A-013 | Derived data | gross_sqft and est_daily_cost_usd are not stored in 3NF; computed in SQL | sqft = sqm × 10.7639; cost = kWh × unit_rate_usd | Derived attributes are transitive dependencies | Applied |
| A-014 | Cost figure | Authoritative quarter cost = SQL exact SUM(kWh × unit_rate_usd) | $14,832,619.22 | DECIMAL arithmetic is exact; the CSV's derived column used float rounding ($14,832,619.04) | VERIFIED (local SQL = Python Decimal) |
