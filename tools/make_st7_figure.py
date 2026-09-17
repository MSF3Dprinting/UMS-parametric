#!/usr/bin/env python3
"""UMS V1 - tools/make_st7_figure.py   (ST-7)"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from PIL import Image

PANELS = [("bottle_holder_49", "\u00d849 preset"),
          ("bottle_holder_56", "\u00d856 preset"),
          ("bottle_front", "\u00d856 from the front"),
          ("v_bottle_edges", "where the opening starts")]

fig, axes = plt.subplots(1, 4, figsize=(13.5, 6.4))
for ax, (name, title) in zip(axes, PANELS):
    path = (f"docs/{name}.png" if name.startswith("v_")
            else f"docs/previews/{name}.png")
    im = Image.open(path).convert("RGB")
    bb = im.point(lambda v: 0 if v > 243 else 255).convert("L").getbbox()
    m = 10
    ax.imshow(im.crop((max(0, bb[0] - m), max(0, bb[1] - m),
                       min(im.width, bb[2] + m), min(im.height, bb[3] + m))))
    ax.set_title(title, fontsize=10.5)
    ax.axis("off")
axes[0].annotate("V1 socket, dimple and all:\nit clicks onto any back part",
                 xy=(0.42, 0.45), xytext=(0.01, 0.06), xycoords="axes fraction",
                 textcoords="axes fraction", fontsize=8.5,
                 arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
axes[2].annotate("drain in the floor, \u00d812:\nV1's is closed",
                 xy=(0.50, 0.17), xytext=(0.02, 0.05), xycoords="axes fraction",
                 textcoords="axes fraction", fontsize=8.5,
                 arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
axes[3].annotate("both edges of the floor chamfered,\nand the edge of the arm with them",
                 xy=(0.40, 0.44), xytext=(0.02, 0.06), xycoords="axes fraction",
                 textcoords="axes fraction", fontsize=8.5,
                 arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
fig.suptitle("UMS V1 — ST-7: the humidifier bottle holder, two presets or any diameter",
             fontsize=12)
fig.tight_layout(rect=[0, 0, 1, 0.95])
fig.savefig("docs/st7_overview.png", dpi=110)
print("wrote docs/st7_overview.png")
