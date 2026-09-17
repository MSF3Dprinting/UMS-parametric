#!/usr/bin/env python3
"""UMS V1 - tools/make_st6_figure.py   (ST-6)

The shipped set, one panel per file in dist/stl. Run tools/make_previews.sh
first, or any time the parts change.
"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from PIL import Image

NAMES = [("hook_tube25", "Hook \u00d825"), ("hook_tube32", "Hook \u00d832"),
         ("hook_double_32_19", "Double \u00d832+\u00d819"),
         ("hook_support_32", "Hook with support"), ("plate_2screw", "Flat plate"),
         ("pole_clip_25", "Pole clip \u00d825"), ("front_blank", "Front blank"),
         ("front_adapter_h80", "UniHolder adapter"),
         ("bottle_holder_49", "Bottle holder \u00d849"),
         ("bottle_holder_56", "Bottle holder \u00d856")]

fig, axes = plt.subplots(2, 5, figsize=(16, 8.2))
for ax, (name, title) in zip(axes.ravel(), NAMES):
    im = Image.open(f"docs/previews/{name}.png").convert("RGB")
    bb = im.point(lambda v: 0 if v > 243 else 255).convert("L").getbbox()
    m = 10
    ax.imshow(im.crop((max(0, bb[0] - m), max(0, bb[1] - m),
                       min(im.width, bb[2] + m), min(im.height, bb[3] + m))))
    ax.set_title(title, fontsize=10)
    ax.axis("off")
fig.suptitle("UMS V1 — the shipped set, every one checked before it was written",
             fontsize=12)
fig.tight_layout(rect=[0, 0, 1, 0.96])
fig.savefig("docs/st6_overview.png", dpi=110)
print("wrote docs/st6_overview.png")
