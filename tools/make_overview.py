#!/usr/bin/env python3
"""UMS V1 - tools/make_overview.py   (ST-1)

Composes the rendered views into one labelled overview. Every panel is a real
render: the first is V1's own Single hook mesh laid on the bed the way it
prints, the rest are the ST-1 coupon the checkers measure.
"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

PANELS = [
    ("v_rail",  "Outer face: nothing but the bump breaks the surface"),
    ("v_xray",  "The same part, transparent: the cavity is entirely internal"),
    ("v_onbed", "V1's own hook as it prints: on its side, bore axis vertical"),
    ("v_ghost", "A front part slid on, drawn transparent"),
]
ARROWS = {
    "v_rail":  [("seat ramp", (0.46, 0.90), (0.70, 0.96)),
                ("the bump, and nothing else:\nno slot, nothing to clean behind",
                 (0.45, 0.47), (0.01, 0.26))],
    "v_xray":  [("sealed cavity, 26 \u00d7 20 \u00d7 1.4", (0.58, 0.46), (0.42, 0.93)),
                ("membrane 0.6 in front of it\ncarries the bump and is the spring",
                 (0.46, 0.40), (0.01, 0.14))],
    "v_onbed": [("bore prints as a vertical hole,\nnothing to bridge",
                 (0.33, 0.66), (0.02, 0.90))],
    "v_ghost": [("front part", (0.15, 0.73), (0.01, 0.93)),
                ("bump, in the dimple", (0.37, 0.52), (0.02, 0.16))],
}

fig, axes = plt.subplots(2, 2, figsize=(13.5, 10.5))
for ax, (name, title) in zip(axes.ravel(), PANELS):
    ax.imshow(mpimg.imread(f"docs/{name}.png"))
    ax.set_title(title, fontsize=10.5)
    ax.axis("off")
    for text, xy, xytext in ARROWS.get(name, []):
        ax.annotate(text, xy=xy, xytext=xytext, xycoords="axes fraction",
                    textcoords="axes fraction", fontsize=8.5, ha="left",
                    va="center", arrowprops=dict(arrowstyle="->", lw=0.9,
                                                 color="#1d3557"))
axes.ravel()[2].annotate("layers stack\nthis way", xy=(0.88, 0.55), xytext=(0.88, 0.16),
                         xycoords="axes fraction", textcoords="axes fraction",
                         fontsize=9, ha="center", va="center",
                         arrowprops=dict(arrowstyle="->", lw=1.4, color="#c1121f"))
fig.suptitle("UMS V1 back part: the spring is a sealed internal cavity",
             fontsize=12)
fig.tight_layout(rect=[0, 0, 1, 0.97])
fig.savefig("docs/st1_overview.png", dpi=110)
print("wrote docs/st1_overview.png")
