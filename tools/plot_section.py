#!/usr/bin/env python3
"""UMS V1 - tools/plot_section.py   (ST-1)

Plots real cross-sections through the rendered coupon STLs: the rail sitting in
the socket at mid height, and the centreline section through the seat and the
detent. Nothing here is drawn by hand - every line is sliced out of the STL that
OpenSCAD produced.
"""
import sys, os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_interface import load_stl


def segments(tris, axis, c):
    other = [i for i in range(3) if i != axis]
    out = []
    for t in tris:
        d = t[:, axis] - c
        if not (np.any(d > 0) and np.any(d < 0)):
            continue
        pts = []
        for i in range(3):
            j = (i + 1) % 3
            if (d[i] > 0) != (d[j] > 0):
                f = d[i] / (d[i] - d[j])
                p = t[i] + f * (t[j] - t[i])
                pts.append([p[other[0]], p[other[1]]])
        if len(pts) == 2:
            out.append(pts)
    return np.array(out)


def draw(ax, segs, color, lw=1.6, label=None):
    for k, s in enumerate(segs):
        ax.plot(s[:, 0], s[:, 1], color=color, lw=lw,
                label=label if k == 0 else None, solid_capstyle="round")


rail = load_stl("out/rail.stl")
sock = load_stl("out/socket.stl")

fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(14.0, 4.8),
                                    gridspec_kw={"width_ratios": [2.3, 0.8, 1.5]})

# --- cross-section at mid height ---------------------------------------
draw(ax1, segments(sock, 2, 30.0), "#8d99ae", 1.4, "front part (socket)")
draw(ax1, segments(rail, 2, 30.0), "#1d3557", 1.8, "back part (rail)")
ax1.set_title("Section at z = 30: only the 45\u00b0 flanks touch. The seat ramp at the top "
              "carries the load", fontsize=10)
ax1.set_xlabel("x [mm]"); ax1.set_ylabel("y [mm]")
ax1.set_xlim(-21, 21); ax1.set_ylim(-9.5, 5)
ax1.annotate("0.20 clearance\non both flanks", xy=(-14.6, -1.4), xytext=(-19.5, 2.6),
             fontsize=8, arrowprops=dict(arrowstyle="->", lw=0.8))
ax1.annotate("0.20 at the floor,\nso the rail never bottoms out", xy=(4, -4.1),
             xytext=(-6.5, -7.9), fontsize=8,
             arrowprops=dict(arrowstyle="->", lw=0.8))

# --- centreline section -------------------------------------------------
draw(ax2, segments(sock, 0, 0.0), "#8d99ae", 1.4, "front part (socket)")
draw(ax2, segments(rail, 0, 0.0), "#1d3557", 1.8, "back part (rail)")
ax2.set_title("Section at x = 0:\nseat and detent", fontsize=10)
ax2.set_xlabel("y [mm]"); ax2.set_ylabel("z [mm]")
ax2.set_xlim(-9.5, 5); ax2.set_ylim(-2, 53)
ax2.annotate("45\u00b0 seat", xy=(-2.0, 46.0), xytext=(-8.8, 50.0), fontsize=8,
             arrowprops=dict(arrowstyle="->", lw=0.8))
ax2.annotate("bump \u00d83.3 \u00d7 0.6,\ninto a \u00d82.3 \u00d7 0.7 dimple",
             xy=(-4.4, 17.0), xytext=(-9.2, 26.0), fontsize=8,
             arrowprops=dict(arrowstyle="->", lw=0.8))
ax2.annotate("membrane 0.6,\nsealed cavity behind it", xy=(-2.9, 22.0),
             xytext=(-9.2, 36.0), fontsize=8,
             arrowprops=dict(arrowstyle="->", lw=0.8))

# --- spring tongue, sectioned through its thickness ---------------------
draw(ax3, segments(rail, 1, -2.7), "#1d3557", 1.6)
ax3.set_title("Section at y = \u22122.7:\nthe sealed cavity behind the membrane", fontsize=10)
ax3.set_xlabel("x [mm]"); ax3.set_ylabel("z [mm]")
ax3.set_xlim(-17, 17); ax3.set_ylim(-1, 49)
ax3.annotate("cavity: wider across the rail than\nit is long, so the membrane bends\nabout x and the stress stays in the\nlayer plane",
             xy=(-8.0, 22.0), xytext=(-16.5, 34), fontsize=8,
             arrowprops=dict(arrowstyle="->", lw=0.8))
ax3.annotate("bump sits here,\non the outside", xy=(0, 17.0), xytext=(4.0, 6),
             fontsize=8, arrowprops=dict(arrowstyle="->", lw=0.8))

for ax in (ax1, ax2, ax3):
    ax.set_aspect("equal")
    ax.grid(True, lw=0.3, alpha=0.4)
    for sp in ax.spines.values():
        sp.set_linewidth(0.6)

h, l = ax1.get_legend_handles_labels()
fig.legend(h, l, fontsize=9, ncol=2, loc="lower center", frameon=False,
           bbox_to_anchor=(0.5, -0.01))
fig.suptitle("UMS V1 interface, measured off the ST-1 coupons", fontsize=11)
fig.tight_layout(rect=[0, 0.05, 1, 1])
fig.savefig("docs/st1_sections.png", dpi=150)
print("wrote docs/st1_sections.png")
