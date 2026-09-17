#!/usr/bin/env python3
"""UMS V1 - tools/check_slot_edges.py                                 (ST-7)

Are the slot's four vertical corners actually rounded, and by how much?

Sections the part at several heights and measures the distance from where a
sharp corner would be to the nearest material, then compares it with what the
round should give at THAT corner. How far a round of radius f sets a corner
back depends on the angle of the corner: f * (1/sin(theta/2) - 1), which runs
from 0.41 f at a right angle to almost nothing at a very obtuse one. The slot's
sides cut the two cylinders at different angles, and the wider the slot the
more obtuse the bore-side corners become, so a single expected figure would
call a perfectly good corner sharp. Nothing here is taken on trust from the
source.

  python3 tools/check_slot_edges.py part.stl --bore 56 --slot 25.76 --wall 2
"""
import argparse
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, "/home/claude/work")
from check_interface import load_stl        # noqa: E402
from slicer import slice_tris, chain        # noqa: E402


def outline(tri, z):
    pts = []
    for p in chain(slice_tris(tri, 2, float(z))):
        if len(p) > 3:
            pts.extend(p)
    return np.array(pts) if pts else None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("stl")
    ap.add_argument("--bore", type=float, required=True)
    ap.add_argument("--slot", type=float, required=True)
    ap.add_argument("--wall", type=float, default=2.0)
    ap.add_argument("--plate-d", type=float, default=9.5)
    ap.add_argument("--clr", type=float, default=0.2)
    ap.add_argument("--fillet", type=float, default=0.5)
    ap.add_argument("--heights", type=float, nargs="+", required=True)
    ap.add_argument("--bottom", type=float, default=19.0,
                    help="lowest point of the slot; the straight part starts "
                         "half a slot width above it, and below that the corner "
                         "being measured does not exist yet")
    a = ap.parse_args()

    tri = load_stl(a.stl)
    r_i = a.bore / 2
    r_o = r_i + a.wall
    yc = -a.clr - a.plate_d - r_o
    f = max(0.0, min(a.fillet, a.wall / 2 - 0.25))
    z_straight = a.bottom + a.slot / 2

    def expected(r, half_w):
        """Setback a round of f gives on the corner where the slot's side
        crosses the cylinder of radius r."""
        if f <= 0 or half_w >= r:
            return 0.0
        lean = np.degrees(np.arcsin(half_w / r))
        theta = (90.0 + lean) if r < (a.bore / 2 + a.wall / 2) else (90.0 - lean)
        return f * (1.0 / np.sin(np.radians(theta / 2)) - 1.0)
    e_bore, e_out = expected(r_i, a.slot / 2), expected(r_o, a.slot / 2)
    print(f"  slot {a.slot} wide, bore {a.bore}, wall {a.wall}, round {f:.2f}; "
          f"straight part starts at z={z_straight:.1f}")
    print(f"  expected setback: {e_bore:.3f} at the bore, {e_out:.3f} outside")
    print(f"  {'z':>7} {'L outer':>9} {'L bore':>9} {'R bore':>9} {'R outer':>9}")
    ok = True
    for z in a.heights:
        P = outline(tri, z)
        if P is None:
            print(f"  {z:7.1f}   no section")
            ok = False
            continue
        if z < z_straight + 0.5:
            print(f"  {z:7.1f}   below the straight part, nothing to measure here")
            continue
        row, vals = f"  {z:7.1f}", []
        for sg in (-1, 1):
            for r in (r_o, r_i) if sg < 0 else (r_i, r_o):
                x = sg * a.slot / 2
                if abs(x) > r:
                    vals.append(float("nan"))
                    continue
                cx, cy = x, yc - np.sqrt(max(0.0, r * r - x * x))
                vals.append(float(np.hypot(P[:, 0] - cx, P[:, 1] - cy).min()))
        for v, want in zip(vals, (e_out, e_bore, e_bore, e_out)):
            row += f" {v:9.3f}"
            # within a quarter of what that corner should give, or sharp if no
            # round was asked for
            ok &= (not np.isnan(v)) and (abs(v - want) <= max(0.25 * want, 0.03)
                                         if f > 0 else v < 0.05)
        print(row)
    print("  ->", ("ROUNDED AT EVERY CORNER" if f > 0 else "SHARP, AS ASKED")
          if ok else ("A CORNER IS SHARP" if f > 0 else "A CORNER IS ROUNDED"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
