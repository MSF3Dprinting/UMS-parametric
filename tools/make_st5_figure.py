#!/usr/bin/env python3
"""UMS V1 - tools/make_st5_figure.py   (ST-5)"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

fig, axes = plt.subplots(1, 2, figsize=(10.5, 7.0))
axes[0].imshow(mpimg.imread("docs/v_front_blank.png"))
axes[0].set_title("Blank, from behind: the V1 socket, nothing else", fontsize=10.5)
axes[0].annotate("socket is V1 exactly, seat at the top,\ndimple 26.58 below the floor top",
                 xy=(0.50, 0.55), xytext=(0.02, 0.06), xycoords="axes fraction",
                 textcoords="axes fraction", fontsize=8.5,
                 arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
axes[1].imshow(mpimg.imread("docs/v_front_adapter.png"))
axes[1].set_title("Adapter, from the front: bolt slots and nut channels", fontsize=10.5)
axes[1].annotate("slots run up and down, so a pitch\nthat is a little out still lands",
                 xy=(0.48, 0.80), xytext=(0.02, 0.95), xycoords="axes fraction",
                 textcoords="axes fraction", fontsize=8.5,
                 arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
axes[1].annotate("nut channel, closed by the\nholder's own back wall",
                 xy=(0.48, 0.22), xytext=(0.02, 0.06), xycoords="axes fraction",
                 textcoords="axes fraction", fontsize=8.5,
                 arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
for ax in axes:
    ax.axis("off")
fig.suptitle("UMS V1 — ST-5: the front blank and the UniHolder adapter", fontsize=12)
fig.tight_layout(rect=[0, 0, 1, 0.95])
fig.savefig("docs/st5_overview.png", dpi=110)
print("wrote docs/st5_overview.png")
