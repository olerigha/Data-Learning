#!/usr/bin/env python3
"""
annotate.py — Inject study annotations into adsp31014_lecture.html.

Usage:
    python3 annotate.py adsp31014_lecture.html working.html

Preserves the original file byte-for-byte except for:
  - one <style> block inserted just before </body>
  - a handful of annotation <div>s inserted immediately after
    specific anchor strings (Pandoc headings)
"""

import sys
from pathlib import Path

CSS = r"""
<style>
/* ===== Study annotation styles (appended last so they override) ===== */
.my-note, .my-key, .my-warn {
  padding: 10px 14px;
  margin: 14px 0;
  border-radius: 4px;
  font-size: 0.95em;
  line-height: 1.5;
}
.my-note  { background: #fffbe6; border-left: 4px solid #f0ad4e; }
.my-key   { background: #eaf5ff; border-left: 4px solid #337ab7; }
.my-warn  { background: #fdecea; border-left: 4px solid #d9534f; }

.my-note strong:first-child { color: #8a6d3b; }
.my-key  strong:first-child { color: #23527c; }
.my-warn strong:first-child { color: #a94442; }

.my-note ul, .my-key ul, .my-warn ul { margin-bottom: 0; }

.my-summary {
  background: #f5f5f5;
  border: 1px solid #ddd;
  border-radius: 6px;
  padding: 14px 18px;
  margin: 18px 0;
}
.my-summary h3 { margin-top: 0; }

mark.my-hl { background: #fff3a3; padding: 0 2px; }

/* Wider reading column than Pandoc's default 940px */
.main-container { max-width: 1100px; }
</style>
"""

# ----------------------------------------------------------------------
# (anchor, insertion) pairs. Insertion goes AFTER the first occurrence
# of anchor. Anchors are Pandoc-generated heading spans — stable across
# the file.
# ----------------------------------------------------------------------

CHEATSHEET = r"""
<div class="my-summary">
<h3>📌 Cheat sheet — the formulas worth memorizing</h3>
<ul>
  <li><strong>Linearity of E:</strong> <span class="math inline">\(\mathbb{E}(aX+b)=a\,\mathbb{E}(X)+b\)</span> (no independence needed).</li>
  <li><strong>Variance:</strong> <span class="math inline">\(\text{Var}(X)=\mathbb{E}(X^2)-(\mathbb{E}(X))^2\)</span>; <span class="math inline">\(\text{Var}(aX+b)=a^2\text{Var}(X)\)</span>.</li>
  <li><strong>Covariance:</strong> <span class="math inline">\(\text{Cov}(X,Y)=\mathbb{E}(XY)-\mathbb{E}(X)\mathbb{E}(Y)\)</span>.</li>
  <li><strong>Correlation:</strong> <span class="math inline">\(\text{Corr}(X,Y)=\text{Cov}(X,Y)/(\text{SD}(X)\text{SD}(Y))\in[-1,1]\)</span>.</li>
  <li><strong>Independence ⟹ Cov = 0, but not conversely.</strong></li>
  <li><strong>Simple OLS slope:</strong> <span class="math inline">\(\beta_1^*=\text{Cov}(X,Y)/\text{Var}(X)=\text{Corr}(X,Y)\cdot\text{SD}(Y)/\text{SD}(X)\)</span>.</li>
  <li><strong>Simple OLS intercept:</strong> <span class="math inline">\(\beta_0^*=\bar y_n-\beta_1^*\bar x_n\)</span>.</li>
  <li><strong>Multiple OLS:</strong> <span class="math inline">\(\hat\beta=(X'X)^{-1}X'y\)</span>.</li>
  <li><strong>R²:</strong> <span class="math inline">\(R^2=SS_\text{reg}/SS_\text{total}=1-SS_\text{err}/SS_\text{total}\)</span> (needs intercept).</li>
  <li><strong>VIF:</strong> <span class="math inline">\(\text{VIF}_j=1/(1-R_j^2)\)</span>; investigate if VIF &gt; 5.</li>
</ul>
</div>
"""

NOTES = [
    # ----- top-level welcome banner, placed right after the TOC's <hr /> -----
    ("<hr />\n<div id=\"prerequisite\"",
     CHEATSHEET + r"""
<div class="my-note">
  <strong>How to read this working copy.</strong>
  Blue boxes = key insight. Yellow boxes = extra context.
  Red boxes = caveat / common mistake. The professor's original text,
  math, code and figures are untouched; annotations are layered on top.
</div>
"""),

    # ----- §1 Prerequisite -----
    ('<span class="header-section-number">1</span> Prerequisite</h1>',
     r"""
<div class="my-key">
  <strong>The three prerequisites are the toolkit for the whole course.</strong>
  Expectation is <em>linear</em>, variance is <em>quadratic</em>,
  covariance/correlation is <em>bilinear</em>. Every OLS derivation in §3
  is a direct application of these three facts.
</div>
"""),

    # ----- §1.1 Expectation -----
    ('<span class="header-section-number">1.1</span> Expectation</h2>',
     r"""
<div class="my-key">
  <strong>Linearity of expectation is the single most-used fact in this course.</strong>
  It requires <em>no</em> independence and <em>no</em> distributional
  assumption. If you remember one thing from §1.1:
  <span class="math inline">\(\mathbb{E}(aX+b) = a\,\mathbb{E}(X) + b\)</span>.
</div>
<div class="my-warn">
  <strong>Common trap.</strong> <span class="math inline">\(\mathbb{E}(XY) = \mathbb{E}(X)\mathbb{E}(Y)\)</span>
  requires <em>independence</em>, but the converse is false: this equality
  does <em>not</em> imply independence. Two variables can be uncorrelated
  yet strongly dependent (see §1.3 for the canonical example).
</div>
"""),

    # ----- §1.2 Variance, SD -----
    ('<span class="header-section-number">1.2</span> Variance, Standard',
     r"""
<div class="my-note">
  <strong>Moment hierarchy — the direction that isn't stated.</strong>
  The lecture states: finite variance ⟹ finite mean. The converse
  (finite mean ⟹ finite variance) is <em>false</em>. Student's <span class="math inline">\(t\)</span>
  with 2 degrees of freedom has mean 0 but infinite variance — worth
  remembering as a counterexample.
</div>
"""),

    # ----- §1.3 Covariance, Correlation -----
    ('<span class="header-section-number">1.3</span> Covariance,',
     r"""
<div class="my-key">
  <strong>Independence ⟹ zero covariance, but not conversely.</strong>
  Covariance measures <em>linear</em> association only. The lecture's
  residualization trick — start from <span class="math inline">\(y = x^2 + \epsilon\)</span>,
  then subtract the projection of <span class="math inline">\(y\)</span>
  onto <span class="math inline">\(x\)</span> — produces a
  <span class="math inline">\(y\)</span> that is <em>exactly</em>
  uncorrelated with <span class="math inline">\(x\)</span> yet perfectly
  dependent on it (quadratic relationship). Classic exam trap.
</div>
<div class="my-note">
  <strong>"0.6 is a reasonably high correlation" — treat as domain-dependent.</strong>
  In social sciences, <span class="math inline">\(|r|\approx 0.6\)</span>
  is often called strong; in physics or engineering it would be weak.
  Rules of thumb for correlation are not universal.
</div>
"""),

    # ----- §2 Modeling -----
    ('<span class="header-section-number">2</span> Modeling</h1>',
     r"""
<div class="my-note">
  <strong>Why this lecture focuses on parametric models.</strong>
  A parametric model has a fixed number of parameters regardless of
  sample size <span class="math inline">\(n\)</span>. This makes it
  interpretable, cheap to fit, and theoretically tractable — provided
  the assumed form is roughly correct. Non-parametric models trade
  interpretability for flexibility and need more data.
</div>
"""),

    # ----- §3 Linear Regression Part 1 -----
    ('<span class="header-section-number">3</span> Linear Regression Part',
     r"""
<div class="my-key">
  <strong>Arc of this lecture.</strong>
  (1) Define the linear model and interpret coefficients.
  (2) Derive OLS in closed form for simple regression.
  (3) Generalize to multiple regression (see <code>adsp31014_mlr.pdf</code> — <em>not included here</em>).
  (4) Define <span class="math inline">\(R^2\)</span> via sums of squares.
  (5) Diagnose multicollinearity.
  (6) Extend to polynomial regression.
  By the end you should be able to fit, interpret, and critique a linear
  model in R.
</div>
"""),

    # ----- §3.1 Linear Model -----
    ('<span class="header-section-number">3.1</span> Linear Model</h2>',
     r"""
<div class="my-key">
  <strong>"Linear" refers to the parameters <span class="math inline">\(\beta\)</span>, not the inputs.</strong>
  The model is linear if <span class="math inline">\(y\)</span> is a
  linear combination of the <span class="math inline">\(\beta\)</span>'s.
  So <span class="math inline">\(\beta_1\log(x_1)+\beta_2 x_2^2+\beta_3 x_1 x_2\)</span>
  is still a linear model — just with engineered features. But
  <span class="math inline">\(\beta_0+\beta_1 x^{\beta_2}\)</span> is
  <em>not</em> linear because <span class="math inline">\(\beta_2\)</span>
  appears in an exponent.
</div>
"""),

    # ----- §3.2 Simple Linear Regression, OLS -----
    ('<span class="header-section-number">3.2</span> Simple Linear',
     r"""
<div class="my-key">
  <strong>OLS = minimize MSE.</strong> Setting the partial derivatives
  of <span class="math inline">\(\text{MSE} = \frac1n\sum_i(y_i-\hat y_i)^2\)</span>
  with respect to <span class="math inline">\(\beta_0,\beta_1\)</span>
  to zero yields the closed form:
  <br>
  <span class="math display">\[\beta_1^*=\frac{\text{Cov}(X,Y)}{\text{Var}(X)}=\text{Corr}(X,Y)\cdot\frac{\text{SD}(Y)}{\text{SD}(X)},\qquad \beta_0^*=\bar y_n-\beta_1^*\bar x_n.\]</span>
  The <span class="math inline">\(\text{Corr}\cdot\text{SD}(Y)/\text{SD}(X)\)</span>
  decomposition is the fastest way to sanity-check a slope.
</div>
<div class="my-note">
  <strong>Why the fitted line passes through <span class="math inline">\((\bar x_n,\bar y_n)\)</span>.</strong>
  Rearranging <span class="math inline">\(\beta_0^*=\bar y_n-\beta_1^*\bar x_n\)</span>
  gives <span class="math inline">\(\bar y_n=\beta_0^*+\beta_1^*\bar x_n\)</span>:
  the line passes through the center of mass of the data. Good visual
  sanity check.
</div>
<div class="my-warn">
  <strong>R gotcha — always pass a data frame.</strong>
  Use <code>lm(y ~ x, data = df)</code>, not <code>lm(df$y ~ df$x)</code>.
  The former stores variable names so
  <code>predict(model, newdata = ...)</code> works; the latter silently
  returns training-set fitted values instead of predictions on new data
  (the lecture demonstrates this right before §3.3 — don't skip that
  chunk).
</div>
"""),

    # ----- §3.3 Multiple Linear Regression -----
    ('<span class="header-section-number">3.3</span> Multiple Linear',
     r"""
<div class="my-warn">
  <strong>Content gap in this file.</strong> The explanatory text for
  multiple linear regression is in a separate PDF
  (<code>adsp31014_mlr.pdf</code>) that was <em>not</em> distributed with
  this HTML. Only the R code showing the matrix formulation is present.
  Ask your professor for the PDF before this section becomes
  exam-relevant.
</div>
<div class="my-note">
  <strong>What the R code is doing.</strong>
  <code>model.matrix(y ~ x)</code> builds the design matrix
  <span class="math inline">\(X\)</span> with a leading column of 1's
  for the intercept. Then <span class="math inline">\(\hat\beta=(X'X)^{-1}X'y\)</span>
  is the OLS solution, computed here by <code>solve()</code>. The fitted
  values <span class="math inline">\(X\hat\beta\)</span> match
  <code>fitted(model)</code>.
</div>
"""),

    # ----- §3.4 R² -----
    ('<span class="header-section-number">3.4</span> Coefficient of',
     r"""
<div class="my-key">
  <strong><span class="math inline">\(R^2\)</span> = fraction of variance explained.</strong>
  Decomposition (requires an intercept):
  <span class="math display">\[\underbrace{\sum_i(y_i-\bar y)^2}_{SS_\text{total}}=\underbrace{\sum_i(\hat y_i-\bar y)^2}_{SS_\text{reg}}+\underbrace{\sum_i(y_i-\hat y_i)^2}_{SS_\text{err}}.\]</span>
  Then <span class="math inline">\(R^2=SS_\text{reg}/SS_\text{total}=1-SS_\text{err}/SS_\text{total}\in[0,1]\)</span>.
  Interpretation: <span class="math inline">\(R^2=0.65\)</span> means 65%
  of the variance in <span class="math inline">\(y\)</span> is explained
  by the model; 35% remains in the residuals.
</div>
<div class="my-note">
  <strong><span class="math inline">\(R^2\)</span> and MSE carry the same information</strong>
  for a fixed dataset, because <span class="math inline">\(R^2=1-\text{MSE}\cdot n/SS_\text{total}\)</span>
  and <span class="math inline">\(SS_\text{total}\)</span> is a constant.
  Minimizing MSE and maximizing <span class="math inline">\(R^2\)</span>
  give the same optimum. The reason to report <span class="math inline">\(R^2\)</span>
  is that it is <em>normalized</em> to <span class="math inline">\([0,1]\)</span>,
  so it's comparable across datasets (though not across different
  response variables).
</div>
"""),

    # ----- §3.5 Multicollinearity -----
    ('<span class="header-section-number">3.5</span>',
     r"""
<div class="my-key">
  <strong>Multicollinearity hurts parameters, not predictions.</strong>
  When predictors are highly correlated, the model can still fit and
  predict well, but individual coefficients become unstable and
  uninterpretable. Two consequences:
  <ul>
    <li><strong>Identifiability fails</strong> under perfect correlation:
      infinitely many <span class="math inline">\(\beta\)</span> vectors
      give the same fit. R silently drops a variable and reports
      <code>NA</code> with "not defined because of singularities" —
      it does <em>not</em> error.</li>
    <li><strong>Numerical instability</strong> under near-perfect
      correlation: coefficients swing wildly with tiny perturbations.
      In the lecture's example, VIF <span class="math inline">\(\approx 1.7\times 10^7\)</span>
      and coefficients are around <span class="math inline">\(\pm 5000\)</span>
      for a response on the order of 1–8.</li>
  </ul>
</div>
<div class="my-note">
  <strong>VIF rule of thumb.</strong> Regress <span class="math inline">\(x_j\)</span>
  on the other predictors; let <span class="math inline">\(R_j^2\)</span>
  be the resulting <span class="math inline">\(R^2\)</span>. Then
  <span class="math inline">\(\text{VIF}_j=1/(1-R_j^2)\)</span>.
  VIF &gt; 5 = investigate; VIF &gt; 10 = act. High VIF means the
  variable is redundant <em>given the others in the model</em> — it
  doesn't automatically mean you should drop it. Domain knowledge
  decides which variable to keep. Note also that the lecture's
  <code>1 - cor(x1, x2)</code> output <code>6.71e-09</code> is
  <em>1 minus</em> the correlation, i.e. the correlation is essentially 1.
</div>
"""),

    # ----- §3.6 Polynomial Regression -----
    ('<span class="header-section-number">3.6</span> Polynomial',
     r"""
<div class="my-key">
  <strong>Polynomial regression is still linear regression.</strong>
  Engineer features <span class="math inline">\(x,x^2,\ldots,x^p\)</span>
  and fit an ordinary linear model. In R: <code>I(x^2)</code> or
  <code>poly(x, 2, raw = TRUE)</code>. The <code>I()</code> wrapper is
  needed because <code>^</code> has special meaning inside a formula
  (interactions); <code>raw = TRUE</code> prevents <code>poly()</code>
  from returning orthogonal polynomials.
</div>
<div class="my-key">
  <strong>Why always keep lower-order terms.</strong>
  If your model were missing the linear term, an affine reparametrization
  <span class="math inline">\(x\mapsto x+c\)</span> would introduce one
  anyway: <span class="math inline">\(\beta_2(x+c)^2=\beta_2 c^2+2\beta_2 c\cdot x+\beta_2 x^2\)</span>.
  Since linear regression predictions should be invariant under affine
  reparametrization of <span class="math inline">\(x\)</span>, dropping
  lower-order terms breaks that invariance. Practical rule: if you
  include <span class="math inline">\(x^p\)</span>, include
  <span class="math inline">\(x^{p-1},\ldots,x,1\)</span> too.
</div>
"""),
]


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 1
    src_path, dst_path = Path(sys.argv[1]), Path(sys.argv[2])
    html = src_path.read_text(encoding="utf-8")

    if "</body>" not in html:
        print("ERROR: </body> not found — is this a Pandoc HTML file?")
        return 2

    # Inject CSS just before </body>
    html = html.replace("</body>", CSS + "\n</body>", 1)

    # Inject each annotation after its anchor
    missing = []
    for anchor, insertion in NOTES:
        if anchor in html:
            html = html.replace(anchor, anchor + insertion, 1)
        else:
            missing.append(anchor[:80])

    dst_path.write_text(html, encoding="utf-8")
    print(f"Wrote {dst_path}  ({len(html):,} bytes)")
    if missing:
        print("\nWARNING — the following anchors were not found:")
        for m in missing:
            print("  -", m)
        print("(The file may have been edited since these notes were written.)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())