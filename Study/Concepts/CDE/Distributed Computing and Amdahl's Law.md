---
course: CDE
week: 8
source: "[[Week8-ParallelDistributed.pdf]]"
status: new
tags: [generated]
---
# Distributed Computing and Amdahl's Law
**In one line:** Spread work across many processors or machines when one isn't enough, but the part that can't be split up caps how much faster you can go.

**In plain words:** Big data is data too large or complex for ordinary tools on one machine. Parallel processing splits a job across several processors. A distributed system spreads data and work across many independent machines that look like one system to the user. Both add overhead: coordination, network delay, handling failures. Amdahl's law says that if part of the job must run one step at a time, adding more processors only helps the rest, so total speedup hits a ceiling.

**Symbols**
| Symbol | Means |
|---|---|
| $S$ | overall speedup of the whole task (e.g. 3 = three times faster) |
| $p$ | fraction of the original run time that *can* be sped up (0 to 1) |
| $1-p$ | fraction that stays serial (can't be sped up) |
| $s$ | speedup of the parallel part (e.g. number of processors) |

**Key points**
- $S=\dfrac{1}{(1-p)+\dfrac{p}{s}}$
  In words: new time = the serial part (unchanged) + the parallel part divided by $s$. Speedup is old time ÷ new time.
- As $s\to\infty$, $S\to\dfrac{1}{1-p}$
  In words: even with infinite processors, you can't beat 1 ÷ (serial fraction).
- **Distributed system:** independent nodes acting as one, scaled horizontally. Trade-offs: coordination overhead, network latency, harder fault tolerance.
- Rule from the course: distribute only when one machine isn't enough (pandas/DuckDB < 10 GB, Polars 10–100 GB, Spark > 100 GB).

**Example:** 90% of a job can be parallelized ($p=0.9$) on 10 processors ($s=10$): $S=1/(0.1+0.09)\approx5.3\times$. With infinite processors it's capped at $1/0.1=10\times$.

**Memorize vs. look up:** Memorize what Amdahl's law says and the $1/(1-p)$ ceiling.

Related: [[MapReduce, Spark, Dask and Ray]], [[Spark Architecture]], [[Cloud Economics and Elasticity]], [[The 4 Vs of Data]]

*The worked example is an illustration; the slide gives the formula.*
