---
course: CDE
week: 2
source: "[[Week2-CloudServicesDesign.pdf]]"
status: new
tags: [generated]
---
# Functional vs Non-Functional Requirements
**In one line:** Functional requirements say *what* the system must do; non-functional ones say *how well* (speed, uptime, cost, privacy).

**In plain words:** System design starts with requirements. "Return 20 personalized videos" is functional: a feature. "Return them in under 150 ms, 99.99% of the time, for under $0.0005 each" is non-functional: quality targets. Non-functional numbers drive the architecture: they decide caching, storage choices and scaling, and they force trade-offs.

**Terms**
| Term | Means |
|---|---|
| Functional requirement | a behavior or feature |
| Non-functional requirement | a quality target: latency, availability, cost, security |
| p99 latency | 99% of requests are faster than this |
| Availability 99.99% | about 52 minutes of downtime a year |
| RPS | requests per second |
| Cold start (recommender) | new users or items with no history |
| MAU | monthly active users |

**Key points**
- Case study: a video recommender on AWS for 10M MAU.
  - **Functional:** 20 recommendations, near-real-time updates, handle cold start, filter watched/disliked, use context (time, device), trending fallback, REST API, log everything for A/B tests.
  - **Non-functional:** p99 < 150 ms, 99.99% availability, 10K RPS peak, model < 1 h stale, features < 5 min fresh, < $0.0005 per recommendation, PII anonymized (GDPR), scale 10× in < 5 min.
- Design steps: requirements → high-level architecture → data and training pipeline → API and caching → cost estimate → trade-offs, resilience, scale.
- Trade-offs to name: consistency vs availability, cost vs latency, simplicity vs accuracy.

**Memorize vs. look up:** Memorize the difference and the six design steps.

Related: [[Well-Architected Framework]], [[Cloud Cost Management]], [[Three-Tier Data Apps]], [[Problem Statements]]
