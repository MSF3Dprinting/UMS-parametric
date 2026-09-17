#!/usr/bin/env python3
"""UMS V1 - tools/make_membrane_figure.py                             (ST-8)

Draws what changed at the detent: a close look at the membrane over the sealed
cavity, before and after, with the extrusions a 0.4 nozzle actually lays into
it. Drawn to scale across the membrane; the cavity itself runs far past the top
and bottom of the view and is given in figures instead.
"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, Circle

W = 0.45
CASES = [("Before: membrane 0.60", 0.60, 20.0, "#c1121f"),
         ("After: membrane 0.90", 0.90, 24.0, "#2a7f88")]

fig, axes = plt.subplots(1, 2, figsize=(12.6, 6.2))
for ax, (title, t, cav_l, colour) in zip(axes, CASES):
    span = (cav_l - 3.3) / 2
    strain = 3 * t * 0.4 / span ** 2 * 100
    ax.add_patch(Rectangle((t, -4.2), 1.4, 8.4, facecolor="white",
                           edgecolor="#1d3557", lw=1.6, zorder=3))
    ax.text(t + 0.7, 3.3, "cavity", ha="center", fontsize=9, zorder=4)
    ax.add_patch(Rectangle((t + 1.4, -4.6), 1.6, 9.2, facecolor="#e9ecef",
                           edgecolor="#1d3557", lw=1.6, zorder=2))
    ax.add_patch(Rectangle((0, -4.6), t, 9.2, facecolor="#e9ecef",
                           edgecolor="#1d3557", lw=1.6, zorder=2))
    ax.add_patch(Rectangle((-0.6, -1.65), 0.6, 3.3, facecolor="#adb5bd",
                           edgecolor="#1d3557", lw=1.4, zorder=4))
    ax.text(-0.9, 0, "detent\nbump", ha="right", va="center", fontsize=9)
    n = int(t / W + 1e-9)
    for i in range(n):
        ax.add_patch(Circle((W / 2 + i * W, 0), W / 2, facecolor=colour,
                            alpha=0.85, edgecolor="none", zorder=5))
    left = t - n * W
    if left > 0.02:
        ax.add_patch(Rectangle((n * W, -W / 2), left, W, facecolor="#f4a261",
                               edgecolor="none", zorder=5))
        ax.annotate(f"{left:.2f} of gap fill —\nthis is what shows",
                    xy=(t - left / 2, -W / 2), xytext=(1.2, -3.4), fontsize=9,
                    color="#a4600f",
                    arrowprops=dict(arrowstyle="->", lw=1.0, color="#a4600f"))
    ax.annotate("", xy=(0, 5.1), xytext=(t, 5.1),
                arrowprops=dict(arrowstyle="<->", lw=1.0, color="#495057"))
    ax.text(t / 2, 5.4, f"{t:.2f}", ha="center", fontsize=10)
    ax.text(t / 2, 6.3, f"{n} perimeter{'s' if n != 1 else ''}"
            + (" + fill" if left > 0.02 else ""), ha="center", fontsize=9.5,
            color=colour, fontweight="bold")
    ax.text(1.5, -5.6, f"cavity {cav_l:.0f} long, membrane spans {span:.2f} either\n"
            f"side of the bump, strain {strain:.2f} % at 0.40 of retraction",
            fontsize=9, ha="center", va="top")
    ax.set_title(title, fontsize=11)
    ax.set_xlim(-2.6, 3.6)
    ax.set_ylim(-7.4, 7.0)
    ax.set_aspect("equal")
    ax.axis("off")
fig.suptitle("UMS V1 — the detent membrane, and what a 0.4 nozzle lays into it",
             fontsize=12.5)
fig.text(0.5, 0.045, "Extrusion width taken as 0.45. At 0.60 a slicer lays one "
         "perimeter and fills the remaining 0.15; that fill is what marks the "
         "face. At 0.90 it lays two full perimeters and nothing else.\n"
         "The cavity was lengthened with it so the membrane spans further and "
         "does not end up stiffer: strain falls slightly, from 1.03 % to 1.01 %.",
         ha="center", fontsize=9.5)
fig.tight_layout(rect=[0, 0.11, 1, 0.94])
fig.savefig("docs/membrane_change.png", dpi=110)
print("wrote docs/membrane_change.png")
