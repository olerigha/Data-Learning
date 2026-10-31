"""
Part 1 - Exploratory data analysis of the gas turbine emission data.

Produces figures in figures/ and the numeric facts quoted in the Part 1 report
(Part_1/eda_stats.txt).
"""
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import statsmodels.api as sm
from matplotlib.colors import LinearSegmentedColormap

from data_prep import FIG_DIR, PART1_DIR, VARIABLES, load_clean

sys.stdout.reconfigure(encoding="utf-8")

# Palette (validated reference palette from the dataviz guidelines)
BLUE, ORANGE, AQUA, YELLOW, MAGENTA = "#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4"
INK, INK2, GRID = "#0b0b0b", "#52514e", "#e4e3df"
DIVERGING = LinearSegmentedColormap.from_list("div", [BLUE, "#f0efec", ORANGE])
SEQUENTIAL = LinearSegmentedColormap.from_list("seq", ["#cde2fb", "#5598e7", "#104281"])
YEAR_COLORS = dict(zip(range(2011, 2016), [BLUE, ORANGE, AQUA, YELLOW, MAGENTA]))

plt.rcParams.update({
    "figure.dpi": 110, "savefig.dpi": 300, "savefig.bbox": "tight",
    "font.size": 9, "axes.titlesize": 10, "axes.labelsize": 9,
    "axes.edgecolor": INK2, "axes.labelcolor": INK, "axes.titlecolor": INK,
    "xtick.color": INK2, "ytick.color": INK2,
    "axes.grid": True, "axes.axisbelow": True, "grid.color": GRID, "grid.linewidth": 0.6,
    "axes.spines.top": False, "axes.spines.right": False,
    "legend.frameon": False,
})

STATS = []


def note(msg):
    STATS.append(msg)
    print(msg)


def save(fig, name):
    fig.savefig(FIG_DIR / name)
    plt.close(fig)


def fig1_histograms(df):
    fig, axes = plt.subplots(1, 2, figsize=(7.5, 2.8))
    for ax, col, color, label in [(axes[0], "NOX", BLUE, "NOx (mg/m³)"),
                                  (axes[1], "CO", ORANGE, "CO (mg/m³)")]:
        s = df[col]
        ax.hist(s, bins=80, color=color, edgecolor="white", linewidth=0.3)
        ax.axvline(s.mean(), color=INK, ls="--", lw=1, label=f"Mean = {s.mean():.2f}")
        ax.axvline(s.median(), color=INK2, ls=":", lw=1.2, label=f"Median = {s.median():.2f}")
        ax.set_xlabel(label)
        ax.set_ylabel("Hours")
        ax.legend(loc="upper right", fontsize=8)
    axes[0].set_title("Distribution of NOx")
    axes[1].set_title("Distribution of CO (right tail to 44 mg/m³)")
    fig.tight_layout()
    save(fig, "fig1_hist_nox_co.png")
    for col in ("NOX", "CO"):
        s = df[col]
        note(f"{col}: mean {s.mean():.2f}, median {s.median():.2f}, sd {s.std():.2f}, "
             f"skew {s.skew():.2f}, P99 {s.quantile(.99):.2f}, max {s.max():.2f}")


def binned_mean(x, y, bins=25):
    cut = pd.qcut(x, bins, duplicates="drop")
    g = pd.DataFrame({"x": x, "y": y}).groupby(cut, observed=True).mean()
    return g.x.values, g.y.values


def fig2_nox_vs_tit(df):
    fig, ax = plt.subplots(figsize=(5.2, 3.4))
    ax.scatter(df.TIT, df.NOX, s=3, alpha=0.12, color=BLUE, linewidths=0, rasterized=True)
    fit = sm.OLS(df.NOX, sm.add_constant(df.TIT)).fit()
    xs = np.linspace(df.TIT.min(), df.TIT.max(), 100)
    ax.plot(xs, fit.params.iloc[0] + fit.params.iloc[1] * xs, color=INK, lw=2,
            label=f"Linear fit (slope {fit.params.iloc[1]:.3f}, R² = {fit.rsquared:.3f})")
    bx, by = binned_mean(df.TIT, df.NOX)
    ax.plot(bx, by, color=ORANGE, lw=2, marker="o", ms=4, label="Binned mean (25 quantile bins)")
    ax.set_xlabel("Turbine inlet temperature, TIT (°C)")
    ax.set_ylabel("NOx (mg/m³)")
    ax.set_title("NOx vs turbine inlet temperature")
    ax.legend(loc="upper left", fontsize=8)
    fig.tight_layout()
    save(fig, "fig2_nox_vs_tit.png")
    note(f"NOx~TIT linear: slope {fit.params.iloc[1]:.4f}, R2 {fit.rsquared:.4f}, "
         f"r {np.corrcoef(df.TIT, df.NOX)[0, 1]:.3f}")
    note("Binned mean NOx by TIT bin: " + ", ".join(f"{x:.0f}:{y:.1f}" for x, y in zip(bx, by)))
    low = df.TIT < 1050
    note(f"TIT<1050 rows {low.sum()} ({low.mean():.1%}); mean NOx {df.NOX[low].mean():.2f} "
         f"vs TIT>=1050 {df.NOX[~low].mean():.2f}")


def fig3_co_vs_nox(df):
    fig, ax = plt.subplots(figsize=(5.4, 3.4))
    order = df.sort_values("TEY", ascending=False)
    sc = ax.scatter(order.NOX, order.CO, c=order.TEY, cmap=SEQUENTIAL.reversed(), s=3,
                    alpha=0.5, linewidths=0, rasterized=True)
    ax.set_yscale("log")
    ax.set_xlabel("NOx (mg/m³)")
    ax.set_ylabel("CO (mg/m³, log scale)")
    ax.set_title("CO vs NOx, coloured by turbine energy yield")
    cb = fig.colorbar(sc, ax=ax, pad=0.02)
    cb.set_label("TEY (MWh)")
    cb.solids.set_alpha(1)
    cb.outline.set_visible(False)
    fig.tight_layout()
    save(fig, "fig3_co_vs_nox.png")
    note(f"corr(CO,NOX) pearson {df.CO.corr(df.NOX):.3f}, spearman {df.CO.corr(df.NOX, method='spearman'):.3f}")
    bands = pd.cut(df.TEY, [0, 110, 125, 135, 145, 160, 200])
    note("By TEY band (mean NOx, mean CO, mean TIT, n):\n" +
         df.groupby(bands, observed=True).agg(NOx=("NOX", "mean"), CO=("CO", "mean"),
                                              TIT=("TIT", "mean"), n=("NOX", "size")).round(2).to_string())
    lo = df.TEY < 110
    note(f"Low load TEY<110: corr(CO,NOx) {df[lo].CO.corr(df[lo].NOX):.3f}; "
         f"TEY>=110: {df[~lo].CO.corr(df[~lo].NOX):.3f}")


def fig4_corr_heatmap(df):
    cols = list(VARIABLES)
    corr = df[cols].corr()
    fig, ax = plt.subplots(figsize=(5.6, 4.6))
    im = ax.imshow(corr, cmap=DIVERGING, vmin=-1, vmax=1)
    ax.set_xticks(range(len(cols)), cols, rotation=45, ha="right")
    ax.set_yticks(range(len(cols)), cols)
    ax.grid(False)
    for i in range(len(cols)):
        for j in range(len(cols)):
            v = corr.iloc[i, j]
            ax.text(j, i, f"{v:.2f}", ha="center", va="center", fontsize=7,
                    color="white" if abs(v) > 0.75 else INK)
    for s in ax.spines.values():
        s.set_visible(False)
    cb = fig.colorbar(im, ax=ax, fraction=0.046, pad=0.03)
    cb.outline.set_visible(False)
    ax.set_title("Pearson correlation matrix")
    fig.tight_layout()
    save(fig, "fig4_corr_heatmap.png")
    note("Correlation with NOX: " + corr.NOX.drop("NOX").sort_values().round(3).to_string().replace("\n", "; "))
    pairs = corr.where(np.triu(np.ones(corr.shape, bool), 1)).stack()
    note("Strongest |r| pairs: " + pairs.abs().sort_values(ascending=False).head(8).round(3).to_string().replace("\n", "; "))


def fig5_nox_by_at_decile(df):
    dec = pd.qcut(df.AT, 10)
    groups = [g.NOX.values for _, g in df.groupby(dec, observed=True)]
    labels = [f"{iv.left:.0f}–{iv.right:.0f}" for iv in dec.cat.categories]
    fig, ax = plt.subplots(figsize=(7.0, 3.0))
    bp = ax.boxplot(groups, patch_artist=True, widths=0.6,
                    medianprops=dict(color=INK, lw=1.5),
                    flierprops=dict(marker="o", ms=1.5, alpha=0.3, markeredgewidth=0, markerfacecolor=INK2),
                    whiskerprops=dict(color=INK2), capprops=dict(color=INK2))
    for patch in bp["boxes"]:
        patch.set(facecolor="#9ec5f4", edgecolor=BLUE)
    ax.set_xticks(range(1, 11), labels)
    ax.set_xlabel("Ambient temperature decile (°C)")
    ax.set_ylabel("NOx (mg/m³)")
    ax.set_title("NOx across ambient temperature deciles")
    fig.tight_layout()
    save(fig, "fig5_nox_by_at_decile.png")
    med = df.groupby(dec, observed=True).NOX.median()
    note("Median NOx by AT decile: " + ", ".join(f"{m:.1f}" for m in med.values))
    note(f"corr(AT,NOX) {df.AT.corr(df.NOX):.3f}; corr(AT,AH) {df.AT.corr(df.AH):.3f}")


def fig6_nox_over_time(df):
    fig, ax = plt.subplots(figsize=(7.0, 2.6))
    for y, d in df.groupby("year"):
        roll = d.NOX.rolling(168, center=True, min_periods=24).mean()
        ax.plot(d.row_in_year / len(d), roll, color=YEAR_COLORS[y], lw=1.6, label=str(y))
    ax.set_xlabel("Fraction of year elapsed (row order within each annual file)")
    ax.set_ylabel("NOx, 7-day rolling mean")
    ax.set_title("Seasonal NOx profile by year", pad=22)
    ax.legend(ncol=5, loc="lower center", bbox_to_anchor=(0.5, 1.0), fontsize=8)
    fig.tight_layout()
    save(fig, "fig6_nox_seasonal_by_year.png")
    note("Annual mean NOX: " + df.groupby("year").NOX.mean().round(2).to_string().replace("\n", "; "))
    for y, d in df.groupby("year"):
        note(f"{y}: corr(AT,NOX) {d.AT.corr(d.NOX):.3f}")


def extra_facts(df):
    note(f"AH>100: {(df.AH > 100).sum()} rows, max {df.AH.max()}")
    note(f"TAT within 1 °C of max ({df.TAT.max():.2f}): {(df.TAT >= df.TAT.max() - 1).mean():.1%}")
    note(f"TIT within 1 °C of max ({df.TIT.max():.1f}): {(df.TIT >= df.TIT.max() - 1).mean():.1%}")
    note(f"TIT unique values {df.TIT.nunique()}, resolution check (x10 integer): "
         f"{np.allclose(df.TIT * 10, np.round(df.TIT * 10))}")
    r2 = sm.OLS(df.TIT, sm.add_constant(df[["TAT", "TEY"]])).fit().rsquared
    note(f"R2 of TIT ~ TAT + TEY: {r2:.4f}")
    r2 = sm.OLS(df.TIT, sm.add_constant(df[["TAT", "CDP"]])).fit().rsquared
    note(f"R2 of TIT ~ TAT + CDP: {r2:.4f}")
    z = (df[list(VARIABLES)] - df[list(VARIABLES)].mean()) / df[list(VARIABLES)].std()
    note("Rows with |z|>4 by column: " + (z.abs() > 4).sum().to_string().replace("\n", "; "))
    note(f"CO min positive {df.CO.min():.5f}")
    top = df.CO.value_counts()
    stuck = df[df.CO == top.index[0]]
    note(f"Most repeated CO value {top.index[0]} x{top.iloc[0]} "
         f"(years {sorted(stuck.year.unique())}, rows {stuck.row_in_year.min()}-{stuck.row_in_year.max()})")


def main():
    df = load_clean()
    note(f"Rows {len(df)}, columns {df.shape[1]}")
    fig1_histograms(df)
    fig2_nox_vs_tit(df)
    fig3_co_vs_nox(df)
    fig4_corr_heatmap(df)
    fig5_nox_by_at_decile(df)
    fig6_nox_over_time(df)
    extra_facts(df)
    (PART1_DIR / "eda_stats.txt").write_text("\n".join(STATS), encoding="utf-8")


if __name__ == "__main__":
    main()
