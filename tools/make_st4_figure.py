#!/usr/bin/env python3
"""UMS V1 - tools/make_st4_figure.py   (ST-4)"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

fig = plt.figure(figsize=(13.0, 6.6))
gs = fig.add_gridspec(1, 2, width_ratios=[1.0, 1.35], wspace=0.03)
ax = fig.add_subplot(gs[0])
ax.imshow(mpimg.imread("docs/v_clip.png"))
ax.set_title("Pole clip: plate, spine, cradle, two tie grooves", fontsize=10.5)
ax.axis("off")
ax.annotate("grooves cut the spine as well as the arms,\nso the tie channel goes all the way round",
            xy=(0.62, 0.45), xytext=(0.02, 0.08), xycoords="axes fraction",
            textcoords="axes fraction", fontsize=8.5,
            arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
ax2 = fig.add_subplot(gs[1])
ax2.imshow(mpimg.imread("docs/v_clip_family.png"))
ax2.set_title("From above, \u00d815 / \u00d825 / \u00d850: the arms pass the equator, "
              "so it snaps on", fontsize=10.5)
ax2.axis("off")
fig.suptitle("UMS V1 — ST-4: the vertical pole clip, the one part that prints standing",
             fontsize=12)
fig.tight_layout(rect=[0, 0, 1, 0.94])
fig.savefig("docs/st4_overview.png", dpi=110)
print("wrote docs/st4_overview.png")
