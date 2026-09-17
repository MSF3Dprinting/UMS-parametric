#!/usr/bin/env python3
"""UMS V1 - tools/make_bolt_figure.py   (ST-5)

Sections the bolted assembly on the bolt line and draws it, each part in its own
colour, with the stack dimensioned. Every outline is sliced out of the rendered
geometry, so what is drawn is what the files produce.
"""
import os
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, "/home/claude/work")
from check_interface import load_stl          # noqa: E402
from slicer import slice_tris                 # noqa: E402

PARTS = [("as_wall",    "#6c757d", 2.2, "UniHolder back wall"),
         ("as_screws",  "#343a40", 2.2, "screw"),
         ("as_nuts",    "#c1121f", 2.2, "nut, captive"),
         ("as_adapter", "#1d3557", 2.4, "adapter"),
         ("as_rail",    "#8d99ae", 2.2, "back part rail")]

fig, (ax, ax2) = plt.subplots(1, 2, figsize=(13.2, 6.8),
                              gridspec_kw={"width_ratios": [0.85, 1.3]})
for name, colour, lw, label in PARTS:
    tri = load_stl(f"out/{name}.stl")
    segs = slice_tris(tri, 0, 0.35)   # just off the bolt axis: a chord, not the symmetry plane
    for k, s in enumerate(segs):
        for a in (ax, ax2):
            a.plot([s[0][0], s[1][0]], [s[0][1], s[1][1]], color=colour, lw=lw,
                   solid_capstyle="round",
                   label=label if (k == 0 and a is ax) else None)

ax.set_title("Sectioned on the bolt line", fontsize=10.5)
ax.set_xlabel("y [mm]"); ax.set_ylabel("z [mm]")
ax.set_xlim(-21, 6); ax.set_ylim(-8, 92)
ax.annotate("socket, and the rail in it", xy=(-2, 45), xytext=(-20, 52), fontsize=8.5,
            arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
ax.annotate("two bolts, 64.3 apart:\nthat is where the holder's\nown back holes are",
            xy=(-8, 74), xytext=(-19, 80), fontsize=8.5,
            arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))

ax2.set_title("Around the lower bolt: the stack, front to back", fontsize=10.5)
ax2.set_xlabel("y [mm]"); ax2.set_ylabel("z [mm]")
ax2.set_xlim(-18.5, 1.5); ax2.set_ylim(0.6, 19.5)

# dimension chain along the stack
BANDS = [(-14.75, -11.30, "holder\nwall 3.45"),
         (-11.30, -10.10, "skin 1.2"),
         (-10.10, -6.90,  "nut 3.2"),
         (-6.90,  -5.40,  "tail 1.5"),
         (-5.40,  -4.20,  "skin 1.2"),
         (-4.20,  -0.20,  "socket 4.0")]
y0 = 2.9
for a, b, text in BANDS:
    ax2.annotate("", xy=(a, y0), xytext=(b, y0),
                 arrowprops=dict(arrowstyle="<->", lw=0.9, color="#495057"))
    ax2.text((a + b) / 2, y0 - 1.0, text, fontsize=7.8, ha="center", va="top",
             color="#495057")
for x in (-14.75, -11.30, -10.10, -6.90, -5.40, -4.20, -0.20):
    ax2.axvline(x, color="#adb5bd", lw=0.6, ls=":", zorder=0)

ax2.annotate("screw goes in from inside the holder,\nthrough its own back wall",
             xy=(-12.0, 13.0), xytext=(-17.0, 17.5), fontsize=8.5,
             arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
ax2.annotate("into a nut pushed in from the side edge\nafter printing, held captive by this part",
             xy=(-8.5, 12.0), xytext=(-9.5, 17.0), fontsize=8.5,
             arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))
ax2.annotate("the bolt stops here: that floor\nis what the rail mates",
             xy=(-4.2, 7.5), xytext=(-8.5, 4.6), fontsize=8.5,
             arrowprops=dict(arrowstyle="->", lw=0.9, color="#1d3557"))

for a in (ax, ax2):
    a.set_aspect("equal")
    a.grid(True, lw=0.3, alpha=0.35)
h, l = ax.get_legend_handles_labels()
fig.legend(h, l, fontsize=9, ncol=5, loc="lower center", frameon=False,
           bbox_to_anchor=(0.5, -0.01))
fig.suptitle("UMS V1 — how the adapter bolts to a UniHolder", fontsize=12)
fig.tight_layout(rect=[0, 0.06, 1, 0.96])
fig.savefig("docs/st5_bolts.png", dpi=110)
print("wrote docs/st5_bolts.png")
