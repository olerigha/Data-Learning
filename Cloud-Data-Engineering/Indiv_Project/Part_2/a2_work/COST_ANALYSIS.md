# Part 7 — Cost, Teardown & Cloud Hygiene (report draft)

Prices: AWS Pricing API, **US East (Ohio)**, retrieved 2026-11-01, MySQL, on-demand unless noted. Month = 730 hours.

## 7a. Actual cost of this assignment (to be confirmed by billing screenshot)
| Item | Rate | Usage | Cost |
|---|---|---|---|
| db.t3.micro Single-AZ | $0.017/h | created 18:56 CST → deleted ~21:xx CST (≈2.3 h) | ≈ $0.04 |
| gp2 20 GiB Single-AZ | $0.115/GB-mo | 20 GiB × 2.3 h / 730 | ≈ $0.01 |
| Public IPv4 | $0.005/h | ≈2.3 h | ≈ $0.01 |
| Backups | retention 0 | — | $0 |
| **Total** | | | **≈ $0.06** (credit-based free plan; final figure from Billing) |

## 7c. Production 24/7 estimate (this database, hardened)
Assumptions:
- **P-1:** same class db.t3.micro; current data is 28,897 rows (~10 MB).
- **P-2:** Multi-AZ for redundancy.
- **P-3:** 20 GiB gp3.
- **P-4:** 7-day automated backups. Backup storage up to the provisioned size (20 GB) is free, and the incremental backups of ~10 MB of data stay inside that.
- **P-5:** private subnet, so no public IPv4.

| Component | Rate | Math | $/month |
|---|---|---|---|
| Instance, Multi-AZ | $0.034/h | 0.034 × 730 | **$24.82** |
| Storage gp3, Multi-AZ | $0.23/GB-mo | 0.23 × 20 | **$4.60** |
| Backups, 7-day | $0.095/GB-mo beyond free | ≤20 GB free allowance | **$0.00** (worst case if 20 GB exceeded: +$1.90) |
| Public IPv4 | $0.005/h | 0 (private) | $0.00 (if public: +$3.65) |
| Extended Support | — | MySQL 8.4 is in standard support | $0.00 (8.0 would add a per-vCPU-hour surcharge) |
| **Total** | | | **≈ $29.42/month** (≈ $353/yr); worst case with public IP + extra backups ≈ $35/month |

**Cost-reduction technique:** buy a **1-year Reserved Instance** for the always-on Multi-AZ instance.
- **No Upfront:** $0.0239/h × 730 = **$17.45/mo** vs $24.82 on-demand, which saves **$7.37/mo (−30%)**. Total becomes ≈ **$22.05/month**.
- **1-yr Partial Upfront:** $100 upfront + $0.0114/h, an effective $16.65/mo (−33%).
- **3-yr Partial Upfront:** $214 upfront + $0.0082/h, an effective $11.93/mo (−52%).

This is appropriate because a campus energy platform runs 24/7 with stable, predictable load.

**Report text (2–3 sentences):** Running this database 24/7 in production as a Multi-AZ db.t3.micro with 20 GiB gp3 storage and 7-day backups would cost about **$29.42/month**: $24.82 instance (0.034 × 730 h) + $4.60 storage (0.23 × 20 GB) + $0 backups (within the free allowance equal to provisioned storage), or about $353/year in us-east-2. Because the platform's load is steady and always-on, a 1-year No-Upfront Reserved Instance lowers the instance charge to $17.45/month (−30%), bringing the total to about $22/month without any upfront payment. Keeping the instance private (no public IPv4, saving $3.65/month) and on MySQL 8.4 (avoiding 8.0 Extended Support fees) protects that saving.

## 7b. Teardown
See PROJECT_LOG / COST_LOG for the delete command, its output and confirmation.
