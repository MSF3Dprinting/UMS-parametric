#!/usr/bin/env python3
"""UMS V1 - tools/check_bolt_pattern.py                               (ST-5)

Does the adapter's bolt pattern line up with a real UniHolder?

Finds the through holes in a UniHolder's back wall and the slots in an adapter,
both by slicing the mesh, and reports whether every holder hole lands inside a
slot with clearance to spare. Nothing is assumed about either file: both sets of
positions are measured off the rendered geometry.

  python3 tools/check_bolt_pattern.py holder.stl adapter.stl
"""
import argparse
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "tests"))
from check_interface import load_stl  # noqa: E402


def loops(tri, axis, c):
    """Closed outlines of the section at axis = c, as point lists."""
    other = [i for i in range(3) if i != axis]
    segs = []
    for t in tri:
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
            segs.append(pts)
    if not segs:
        return []
    segs = np.array(segs)
    used = np.zeros(len(segs), bool)
    out = []
    for i in range(len(segs)):
        if used[i]:
            continue
        used[i] = True
        chain = [segs[i][0], segs[i][1]]
        for _ in range(len(segs)):
            d = np.linalg.norm(segs[:, 0] - chain[-1], axis=1)
            e = np.linalg.norm(segs[:, 1] - chain[-1], axis=1)
            j = int(np.argmin(np.where(used, 1e9, np.minimum(d, e))))
            if used[j] or min(d[j], e[j]) > 1e-3:
                break
            used[j] = True
            chain.append(segs[j][1] if d[j] <= e[j] else segs[j][0])
        out.append(np.array(chain))
    return out


def openings(stl, wall_probe, max_size=30):
    """Hole outlines in a wall: small closed loops in a section just inside it."""
    tri = load_stl(stl)
    v = tri.reshape(-1, 3)
    lo, hi = v.min(axis=0), v.max(axis=0)
    best = []
    for y in (lo[1] + wall_probe, hi[1] - wall_probe):
        found = []
        for p in loops(tri, 1, y):
            b0, b1 = p.min(axis=0), p.max(axis=0)
            if max(b1 - b0) < max_size and len(p) > 6:
                found.append(((b0 + b1) / 2, b1 - b0))
        if len(found) > len(best):
            best = found
    return sorted(best, key=lambda f: f[0][1])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("holder")
    ap.add_argument("adapter")
    ap.add_argument("--probe", type=float, default=0.9)
    args = ap.parse_args()

    holes = openings(args.holder, args.probe)
    slots = openings(args.adapter, args.probe)
    if not holes or not slots:
        print("error: could not find holes in one of the two parts")
        return 2

    # both parts are referenced to their own bottom, which is how they are
    # assembled: the adapter's foot to the holder's foot
    print(f"  {'holder hole (x, z)':>22}   {'nearest slot':>18}   {'travel left':>11}")
    ok = True
    for c, _ in holes:
        best, dist = None, 1e9
        for sc, sz in slots:
            d = abs(sc[1] - c[1]) + abs(sc[0] - c[0])
            if d < dist:
                best, dist = (sc, sz), d
        sc, sz = best
        dz = abs(sc[1] - c[1])
        dx = abs(sc[0] - c[0])
        # what is left is how much further the BOLT's centre can move, which is
        # the slot's length less the bolt's own diameter. The slot's width is
        # that diameter. Measuring to the end of the slot instead overstates the
        # travel by a bolt radius at each end.
        room = (sz[1] - sz[0]) / 2 - dz
        good = dx < 0.6 and room > 0.5
        ok &= good
        print(f"  {c[0]:10.2f} {c[1]:10.2f}   {sc[0]:8.2f} {sc[1]:8.2f}   "
              f"{room:9.2f}  {'ok' if good else 'OUT'}")
    print(f"  -> {'PASS' if ok else 'FAIL'}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
