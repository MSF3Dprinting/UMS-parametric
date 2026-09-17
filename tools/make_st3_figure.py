#!/usr/bin/env python3
"""UMS V1 - tools/make_st3_figure.py   (ST-3)"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from PIL import Image

def crop(path):
    im = Image.open(path).convert("RGB")
    bb = im.point(lambda v: 0 if v > 243 else 255).convert("L").getbbox()
    m = 15
    return im.crop((max(0, bb[0]-m), max(0, bb[1]-m),
                    min(im.width, bb[2]+m), min(im.height, bb[3]+m)))

PANELS = [("v_double", "Double hook: \u00d832 over \u00d819, plate reaching both"),
          ("v_support_back", "Support block, from behind: \u00d820 groove"),
          ("v_support_front", "The same part, front: strap channel"),
          ("v_strap_wrap", "The channel turns the corner onto the side face")]
fig, axes = plt.subplots(1, 4, figsize=(15.5, 6.0))
for ax, (name, title) in zip(axes, PANELS):
    ax.imshow(crop(f"docs/{name}.png"))
    ax.set_title(title, fontsize=10)
    ax.axis("off")
axes[1].annotate("groove takes a second tube,\n7 of block left behind it",
                 xy=(0.52, 0.13), xytext=(0.02, 0.30), xycoords="axes fraction",
                 textcoords="axes fraction", fontsize=8.5,
                 arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
axes[2].annotate("strap channel:\n1.0 deep, 8 tall, full width,\n45\u00b0 lead-in top and bottom",
                 xy=(0.45, 0.17), xytext=(0.02, 0.36), xycoords="axes fraction",
                 textcoords="axes fraction", fontsize=8.5,
                 arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
axes[3].annotate("front and both sides, so the tie\nis held all the way round",
                 xy=(0.62, 0.62), xytext=(0.03, 0.10), xycoords="axes fraction",
                 textcoords="axes fraction", fontsize=8.5,
                 arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
fig.suptitle("UMS V1 — ST-3: second bore, support block, strap channel", fontsize=12)
fig.tight_layout(rect=[0, 0, 1, 0.95])
fig.savefig("docs/st3_overview.png", dpi=110)
print("wrote docs/st3_overview.png")
