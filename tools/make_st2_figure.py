#!/usr/bin/env python3
"""UMS V1 - tools/make_st2_figure.py   (ST-2)"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

fig = plt.figure(figsize=(13.5, 7.0))
gs = fig.add_gridspec(1, 2, width_ratios=[1.9, 1.0], wspace=0.02)

ax = fig.add_subplot(gs[0])
ax.imshow(mpimg.imread("docs/v_hook_family.png"))
ax.set_title("One file, tube 15 to 50: bore, wrap and height all follow", fontsize=10.5)
ax.axis("off")
for frac, label in ((0.12, "15"), (0.37, "25"), (0.62, "32"), (0.88, "50")):
    ax.annotate(f"\u00d8{label}", xy=(frac, 0.03), xycoords="axes fraction",
                fontsize=9, ha="center")

ax2 = fig.add_subplot(gs[1])
ax2.imshow(mpimg.imread("docs/v_hook_xray.png"))
ax2.set_title("Transparent, with both voids drawn solid", fontsize=10.5)
ax2.axis("off")
ax2.annotate("wall shell: 0.05 down the middle of the\nhook wall, 3 short of each end of the arc\nand 2 short of each side face",
             xy=(0.55, 0.80), xytext=(0.02, 0.96), xycoords="axes fraction",
             textcoords="axes fraction", fontsize=8.5, va="center",
             arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
ax2.annotate("detent cavity", xy=(0.46, 0.22), xytext=(0.02, 0.10),
             xycoords="axes fraction", textcoords="axes fraction", fontsize=8.5,
             va="center", arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))

fig.suptitle("UMS V1 — ST-2: the parametric back part", fontsize=12)
fig.tight_layout(rect=[0, 0, 1, 0.96])
fig.savefig("docs/st2_overview.png", dpi=110)
print("wrote docs/st2_overview.png")
