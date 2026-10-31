"""
Part 2 - Multiple linear regression for NOx emissions.

Chronological split: train 2011-2013, test 2014-2015. Model selection uses an
inner chronological validation (fit 2011-2012, validate 2013) so the 2014-2015
test years are only touched once, by the final model.

Outputs:
    Part_2/model_comparison.csv     candidate models (in-sample + validation)
    Part_2/vif.csv                  VIF tables
    Part_2/final_model_summary.txt  statsmodels summary() of the final model
    Part_2/model_stats.txt          metrics and quantities quoted in the report
    figures/fig7..fig10             diagnostics
"""
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf
from scipy import stats
from statsmodels.stats.diagnostic import het_breuschpagan
from statsmodels.stats.outliers_influence import variance_inflation_factor

from data_prep import FIG_DIR, PART2_DIR, load_clean
from part1_eda import BLUE, ORANGE, INK, INK2  # shared palette and rcParams

sys.stdout.reconfigure(encoding="utf-8")

PREDICTORS = ["AT", "AP", "AH", "AFDP", "TIT", "TEY"]
CANDIDATES = {
    "M0 all 9 sensors, NOx":        ("NOx ~ AT + AP + AH + AFDP + GTEP + TIT + TAT + TEY + CDP", False),
    "M1 reduced linear, NOx":       ("NOx ~ AT_c + AP_c + AH_c + AFDP_c + TIT_c + TEY_c", False),
    "M2 reduced linear, log NOx":   ("np.log(NOx) ~ AT_c + AP_c + AH_c + AFDP_c + TIT_c + TEY_c", True),
    "M3 + TIT:TEY, log NOx":        ("np.log(NOx) ~ AT_c + AP_c + AH_c + AFDP_c + TIT_c * TEY_c", True),
    "M4 + TIT^2, NOx":              ("NOx ~ AT_c + AP_c + AH_c + AFDP_c + TIT_c + I(TIT_c**2) + TEY_c", False),
    "M5 + TIT^2, log NOx":          ("np.log(NOx) ~ AT_c + AP_c + AH_c + AFDP_c + TIT_c + I(TIT_c**2) + TEY_c", True),
    "M6 + TIT^2 + TEY^2, log NOx":  ("np.log(NOx) ~ AT_c + AP_c + AH_c + AFDP_c + TIT_c + I(TIT_c**2) + TEY_c + I(TEY_c**2)", True),
    "M7 M5 minus AFDP (final)":     ("np.log(NOx) ~ AT_c + AP_c + AH_c + TIT_c + I(TIT_c**2) + TEY_c", True),
}
FINAL = "M7 M5 minus AFDP (final)"

STATS = []


def note(msg):
    STATS.append(str(msg))
    print(msg)


def center(df, means):
    df = df.copy()
    for c in PREDICTORS:
        df[c + "_c"] = df[c] - means[c]
    return df


def predict_nox(model, data, log):
    """Prediction on the original NOx scale (Duan smearing correction for log models)."""
    if log:
        smear = np.mean(np.exp(model.resid))
        return np.exp(model.predict(data)) * smear
    return model.predict(data)


def metrics(y, yhat):
    e = y - yhat
    return {"R2": 1 - np.sum(e ** 2) / np.sum((y - y.mean()) ** 2),
            "RMSE": np.sqrt(np.mean(e ** 2)), "MAE": np.mean(np.abs(e)),
            "Bias(actual-pred)": e.mean()}


def vif_table(data, cols):
    X = sm.add_constant(data[cols])
    return pd.Series({c: variance_inflation_factor(X.values, i) for i, c in enumerate(X.columns) if c != "const"})


def compare_models(df):
    a, b = df[df.year <= 2012], df[df.year == 2013]
    a, b = center(a, a[PREDICTORS].mean()), center(b, a[PREDICTORS].mean())
    tr = df[df.year <= 2013]
    tr = center(tr, tr[PREDICTORS].mean())
    rows = []
    for name, (f, log) in CANDIDATES.items():
        m_tr = smf.ols(f, tr).fit()
        m_a = smf.ols(f, a).fit()
        val = metrics(b.NOx, predict_nox(m_a, b, log))
        ins = metrics(tr.NOx, predict_nox(m_tr, tr, log))
        rows.append({"model": name, "params": len(m_tr.params), "adj_R2 (own scale)": m_tr.rsquared_adj,
                     "train RMSE": ins["RMSE"], "val2013 RMSE": val["RMSE"], "val2013 MAE": val["MAE"],
                     "val2013 R2": val["R2"], "resid skew": stats.skew(m_tr.resid)})
    out = pd.DataFrame(rows)
    out.round(4).to_csv(PART2_DIR / "model_comparison.csv", index=False)
    note("Model comparison (train 2011-13 in-sample; validation fit 2011-12 -> 2013):")
    note(out.round(4).to_string(index=False))


def diagnostics_plots(m, tr, te, yhat_tr, yhat_te):
    # Fig 7: residuals vs fitted (log scale, training)
    fig, ax = plt.subplots(figsize=(5.0, 3.2))
    ax.scatter(m.fittedvalues, m.resid, s=3, alpha=0.15, color=BLUE, linewidths=0, rasterized=True)
    ax.axhline(0, color=INK, lw=1)
    low = sm.nonparametric.lowess(m.resid, m.fittedvalues, frac=0.1, it=0,
                                  delta=0.01 * np.ptp(m.fittedvalues))
    ax.plot(low[:, 0], low[:, 1], color=ORANGE, lw=2, label="LOWESS smooth")
    ax.set_xlabel("Fitted log(NOx)")
    ax.set_ylabel("Residual")
    ax.set_title("Residuals vs fitted (training, 2011–2013)")
    ax.legend(loc="upper right", fontsize=8)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "fig7_residuals_vs_fitted.png")
    plt.close(fig)

    # Fig 8: actual vs predicted on NOx scale, train and test
    fig, axes = plt.subplots(1, 2, figsize=(7.2, 3.3), sharex=True, sharey=True)
    for ax, y, yh, title, color in [(axes[0], tr.NOx, yhat_tr, "Training 2011–2013", BLUE),
                                    (axes[1], te.NOx, yhat_te, "Test 2014–2015", ORANGE)]:
        ax.scatter(yh, y, s=3, alpha=0.15, color=color, linewidths=0, rasterized=True)
        lim = [25, 120]
        ax.plot(lim, lim, color=INK, lw=1, ls="--", label="y = x")
        mm = metrics(y, yh)
        ax.set_title(f"{title}\nR² = {mm['R2']:.3f}, RMSE = {mm['RMSE']:.2f}")
        ax.set_xlabel("Predicted NOx (mg/m³)")
        ax.set_xlim(lim)
        ax.set_ylim(lim)
    axes[0].set_ylabel("Actual NOx (mg/m³)")
    axes[0].legend(loc="upper left", fontsize=8)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "fig8_actual_vs_predicted.png")
    plt.close(fig)

    # Fig 9: normal Q-Q of training residuals
    fig, ax = plt.subplots(figsize=(3.6, 3.2))
    (osm, osr), (slope, intercept, _) = stats.probplot(m.resid, dist="norm")
    ax.scatter(osm, osr, s=3, color=BLUE, linewidths=0, rasterized=True)
    ax.plot(osm, slope * osm + intercept, color=INK, lw=1)
    ax.set_xlabel("Theoretical normal quantile")
    ax.set_ylabel("Ordered residual")
    ax.set_title("Normal Q-Q (training residuals)")
    fig.tight_layout()
    fig.savefig(FIG_DIR / "fig9_qq_residuals.png")
    plt.close(fig)

    # Fig 10: test residuals over time (bias drift)
    fig, ax = plt.subplots(figsize=(7.0, 2.6))
    allres = pd.concat([tr.assign(res=tr.NOx - yhat_tr), te.assign(res=te.NOx - yhat_te)])
    allres["t"] = allres.year + allres.row_in_year / allres.groupby("year").row_in_year.transform("max")
    roll = allres.res.rolling(168, center=True, min_periods=24).mean()
    ax.plot(allres.t, roll, color=BLUE, lw=1.2)
    ax.axhline(0, color=INK, lw=1)
    ax.axvline(2014, color=INK2, ls="--", lw=1)
    ax.text(2013.97, ax.get_ylim()[1] * 0.85, "train | test", ha="right", color=INK2, fontsize=8)
    ax.set_xlabel("Year")
    ax.set_ylabel("Residual NOx (mg/m³)\n7-day rolling mean")
    ax.set_title("Prediction error over time (actual − predicted)")
    fig.tight_layout()
    fig.savefig(FIG_DIR / "fig10_residuals_over_time.png")
    plt.close(fig)


def main():
    df = load_clean().rename(columns={"NOX": "NOx"})
    train_raw, test_raw = df[df.year <= 2013], df[df.year >= 2014]
    means = train_raw[PREDICTORS].mean()
    tr, te = center(train_raw, means), center(test_raw, means)
    note(f"Train rows {len(tr)}, test rows {len(te)}")
    note("Training means used for centering: " + means.round(3).to_string().replace("\n", "; "))
    note(f"Mean NOx train {tr.NOx.mean():.2f}, test {te.NOx.mean():.2f}")
    note(f"Skewness NOx (train) {stats.skew(tr.NOx):.3f}; log(NOx) {stats.skew(np.log(tr.NOx)):.3f}")

    # Multicollinearity
    v_all = vif_table(tr, ["AT", "AP", "AH", "AFDP", "GTEP", "TIT", "TAT", "TEY", "CDP"])
    v_red = vif_table(tr, PREDICTORS)
    pd.DataFrame({"VIF_all_9": v_all, "VIF_reduced": v_red}).round(2).to_csv(PART2_DIR / "vif.csv")
    note("VIF all 9 process/ambient sensors:\n" + v_all.round(1).to_string())
    note("VIF reduced set:\n" + v_red.round(2).to_string())

    compare_models(df)

    # Final model
    f, log = CANDIDATES[FINAL]
    m = smf.ols(f, tr).fit()
    (PART2_DIR / "final_model_summary.txt").write_text(m.summary().as_text(), encoding="utf-8")
    print(m.summary())
    vif_final = pd.Series({n: variance_inflation_factor(m.model.exog, i)
                           for i, n in enumerate(m.model.exog_names) if n != "Intercept"})
    note("VIF final model terms:\n" + vif_final.round(2).to_string())

    yhat_tr, yhat_te = predict_nox(m, tr, log), predict_nox(m, te, log)
    note(f"Smearing factor {np.mean(np.exp(m.resid)):.5f}")
    note(f"Final model: R2(log) {m.rsquared:.4f}, adj {m.rsquared_adj:.4f}, F {m.fvalue:.1f}, "
         f"resid SE {np.sqrt(m.scale):.4f}, AIC {m.aic:.1f}")
    for name, y, yh in [("Train", tr.NOx, yhat_tr), ("Test", te.NOx, yhat_te)]:
        note(f"{name} (NOx scale): " + ", ".join(f"{k} {v:.3f}" for k, v in metrics(y, yh).items()))
    for y in (2014, 2015):
        s = te.year == y
        note(f"Test {y}: " + ", ".join(f"{k} {v:.3f}" for k, v in metrics(te.NOx[s], yhat_te[s]).items()))
    bias = (te.NOx - yhat_te).mean()
    note(f"Test corr(actual,pred) {np.corrcoef(te.NOx, yhat_te)[0, 1]:.4f}; "
         f"RMSE after removing constant test bias {np.sqrt(np.mean((te.NOx - yhat_te - bias) ** 2)):.3f}; "
         f"MAE after bias removal {np.mean(np.abs(te.NOx - yhat_te - bias)):.3f}")

    # Interpretation of coefficients (percent change in NOx)
    p = m.params
    for c in ["AT_c", "AP_c", "AH_c", "TEY_c"]:
        note(f"{c}: coef {p[c]:.5f} -> {100 * (np.exp(p[c]) - 1):+.2f}% NOx per unit; p={m.pvalues[c]:.3g}")
    b1, b2 = p["TIT_c"], p["I(TIT_c ** 2)"]
    vertex = means["TIT"] - b1 / (2 * b2)
    note(f"TIT slope at training mean ({means['TIT']:.1f}): {100 * (np.exp(b1) - 1):+.2f}% per °C; "
         f"vertex (minimum NOx at fixed other vars) TIT = {vertex:.1f} °C")
    for t in (1040, 1060, 1080, 1100):
        tc = t - means["TIT"]
        note(f"  marginal effect at TIT {t}: {100 * (np.exp(b1 + 2 * b2 * tc) - 1):+.2f}% per °C")
    note(f"Share of training rows with TIT below vertex: {(tr.TIT < vertex).mean():.1%}")
    # Standardized effect: one training SD change
    sd = tr[PREDICTORS].std()
    for c in ["AT", "AP", "AH", "TEY"]:
        note(f"1 SD ({sd[c]:.2f}) of {c}: {100 * (np.exp(p[c + '_c'] * sd[c]) - 1):+.2f}% NOx")
    # Scenario: same TEY, TIT lowered by 10 °C from the mean operating point
    note(f"10 °C lower TIT at mean TEY (from mean TIT): {100 * (np.exp(-10 * b1 + 100 * b2) - 1):+.2f}% NOx")

    # Residual diagnostics
    bp = het_breuschpagan(m.resid, m.model.exog)
    note(f"Breusch-Pagan LM {bp[0]:.1f}, p {bp[1]:.3g}")
    note(f"Residual skew {stats.skew(m.resid):.3f}, excess kurtosis {stats.kurtosis(m.resid):.3f}")
    note(f"Durbin-Watson {sm.stats.durbin_watson(m.resid):.3f}")
    note(f"Residual lag-1 autocorrelation {pd.Series(m.resid.values).autocorr(1):.3f}")
    lin = smf.ols(CANDIDATES["M1 reduced linear, NOx"][0], tr).fit()
    note(f"Linear-scale M1 residual skew {stats.skew(lin.resid):.3f}, "
         f"corr(|resid|, fitted) {np.corrcoef(lin.fittedvalues, np.abs(lin.resid))[0, 1]:.3f}; "
         f"log M5 corr(|resid|, fitted) {np.corrcoef(m.fittedvalues, np.abs(m.resid))[0, 1]:.3f}")
    infl = m.get_influence()
    cooks = infl.cooks_distance[0]
    note(f"Max Cook's D {cooks.max():.4f}; rows with Cook's D > 4/n: {(cooks > 4 / len(tr)).sum()}")
    note(f"|standardized resid| > 3: {(np.abs(infl.resid_studentized_internal) > 3).sum()}")
    # Robustness: HC3 standard errors
    hc = smf.ols(f, tr).fit(cov_type="HC3")
    note("HC3 p-values: " + hc.pvalues.round(4).to_string().replace("\n", "; "))
    hac = smf.ols(f, tr).fit(cov_type="HAC", cov_kwds={"maxlags": 24})
    note("HAC (Newey-West, 24 lags) SE ratio to OLS SE: " +
         (hac.bse / m.bse).round(2).to_string().replace("\n", "; "))
    note("HAC p-values: " + hac.pvalues.round(4).to_string().replace("\n", "; "))
    # How TIT co-moves with TEY in normal operation
    tt = smf.ols("TIT ~ TEY", tr).fit()
    g = tt.params["TEY"]
    note(f"Training TIT~TEY slope {g:.3f} °C per MWh, R2 {tt.rsquared:.3f}, "
         f"residual SD of TIT given TEY {np.sqrt(tt.scale):.2f} °C")
    note(f"Net effect of +1 MWh moving along typical TIT-TEY line (at mean TIT): "
         f"{100 * (np.exp(p['TEY_c'] + g * b1) - 1):+.2f}% NOx")
    # Is the 2014 shift explained by inputs? year effects in an all-years fit
    allc = center(df, means)
    yr = smf.ols(f + " + C(year)", allc).fit()
    note("Year effects (log scale) in all-years fit: " +
         ", ".join(f"{k[-5:-1]}: {100 * (np.exp(v) - 1):+.1f}%" for k, v in yr.params.filter(like="year").items()))
    # Residuals by TEY band (training)
    band = pd.cut(tr.TEY, [0, 110, 125, 135, 145, 160, 200])
    note("Mean training residual (log) by TEY band: " +
         m.resid.groupby(band, observed=True).mean().round(4).to_string().replace("\n", "; "))

    diagnostics_plots(m, tr, te, yhat_tr, yhat_te)
    (PART2_DIR / "model_stats.txt").write_text("\n".join(STATS), encoding="utf-8")


if __name__ == "__main__":
    main()
