#!/usr/bin/env python3
"""UMS V1 - tools/check_interface.py                                  (ST-1)

Measures a rendered coupon STL and compares it against the UMS V1 interface
numbers taken off the V1 STEP models. The measurement is geometric: facets are
grouped into planes and the interface features are read back out of them, the
same way the V1 models were measured in the first place.

  python3 check_interface.py out/rail.stl   --part rail
  python3 check_interface.py out/socket.stl --part socket
  python3 check_interface.py out/snap.stl   --volume

Exit code: 0 = every measurement within tolerance, 1 = at least one out, 2 = error.
Requires numpy only.
"""
import argparse
import re
import struct
import sys

import numpy as np

# ---------------------------------------------------------------------------
# V1 reference values, measured from the STEP models (design plan section 2)
# name: (value, tolerance)
# ---------------------------------------------------------------------------
REF_RAIL = {
    "rail height (root plane to tip face)": (4.00, 0.05),
    "rail tip width":                       (31.00, 0.05),
    "rail root width":                      (26.04, 0.05),
    "flank run":                            (2.48, 0.05),
    "flank angle (deg)":                    (45.0, 0.10),
    "full section height":                  (34.00, 0.05),
    "seat ramp height":                     (4.00, 0.05),
    "seat ramp angle (deg)":                (45.0, 0.10),
    "detent bump height":                   (1.00, 0.05),
    "detent bump diameter":                 (3.30, 0.15),
    "bump centre below tip face top":       (27.00, 0.05),
    "flank mirror error":                   (0.00, 0.02),
}
REF_SOCKET = {
    "socket mouth offset from root plane":  (0.20, 0.02),
    "socket depth":                         (4.00, 0.05),
    "socket mouth width":                   (27.00, 0.05),
    "socket floor width":                   (35.00, 0.05),
    "flank angle (deg)":                    (45.0, 0.10),
    "seat ramp height":                     (4.00, 0.05),
    "seat ramp angle (deg)":                (45.0, 0.10),
    "dimple depth":                         (0.70, 0.05),
    "dimple diameter":                      (2.30, 0.15),
    "dimple centre below floor top":        (26.58, 0.05),
    "flank mirror error":                   (0.00, 0.02),
}


def load_stl(path):
    with open(path, "rb") as fh:
        data = fh.read()
    if data[:5] == b"solid" and b"facet" in data[:2000]:
        nums = re.findall(
            rb"vertex\s+(\S+)\s+(\S+)\s+(\S+)", data)
        return np.array(nums, dtype=float).reshape(-1, 3, 3)
    count = struct.unpack("<I", data[80:84])[0]
    dt = np.dtype([("n", "<f4", 3), ("v", "<f4", (3, 3)), ("a", "<u2")])
    return np.frombuffer(data[84:84 + count * 50], dtype=dt)["v"].astype(float)


def normals_areas(tris):
    cross = np.cross(tris[:, 1] - tris[:, 0], tris[:, 2] - tris[:, 0])
    area = np.linalg.norm(cross, axis=1) / 2
    keep = area > 1e-9
    return cross[keep] / (2 * area[keep, None]), area[keep], tris[keep]


def planes(tris, tol=3):
    """Group facets into planes -> list of (normal, offset, area, bbox)."""
    n, a, t = normals_areas(tris)
    off = np.einsum("ij,ij->i", n, t[:, 0])
    keys = [tuple(np.round(nn, tol)) + (round(float(oo), tol),) for nn, oo in zip(n, off)]
    out = {}
    for i, k in enumerate(keys):
        if k not in out:
            out[k] = [0.0, t[i].copy(), t[i].copy()]
        out[k][0] += a[i]
        out[k][1] = np.minimum(out[k][1], t[i].min(axis=0))
        out[k][2] = np.maximum(out[k][2], t[i].max(axis=0))
    return [(np.array(k[:3]), k[3], v[0], np.array([v[1].min(axis=0), v[2].max(axis=0)]))
            for k, v in out.items()]


def flank_mirror_error(flank):
    """How far the two flanks are from being mirror images of each other.

    Returns a large number when one of them is missing, which is what a
    malformed profile looks like: the flank on that side is not at 45 deg
    at all, so it never lands in the group.
    """
    left = [p for p in flank if p[3][1][0] <= 0]
    right = [p for p in flank if p[3][0][0] >= 0]
    if not left or not right:
        return 99.0
    lb = max(left, key=lambda p: p[2])[3]
    rb = max(right, key=lambda p: p[2])[3]
    return float(np.abs(np.array([-lb[1][0], -lb[0][0], lb[0][1], lb[1][1]])
                        - np.array([rb[0][0], rb[1][0], rb[0][1], rb[1][1]])).max())


def facing(pl, vec, tol=0.02):
    return [p for p in pl if np.linalg.norm(p[0] - np.array(vec, float)) < tol]


def detent_box(tris, plane_y, window=1.5, x_max=None):
    """Bounding box of the feature standing proud of (or sunk into) a plane.

    A facet counts when it reaches past the plane in -Y and stays inside the
    window, which keeps the body of the part out of the measurement. The window
    has to be tight on a front part: a bolt hole behind the socket floor is also
    a feature past that plane, and only its depth tells it from the dimple.
    x_max holds the search to a band on the centre line, which is where the
    dimple is and where a holder's own geometry generally is not.
    """
    y = tris[:, :, 1]
    sel = ((y <= plane_y + 1e-6).all(axis=1)
           & (y >= plane_y - window).all(axis=1)
           & (y < plane_y - 1e-6).any(axis=1))
    if x_max is not None:
        sel &= np.abs(tris[:, :, 0].mean(axis=1)) <= x_max
    if not sel.any():
        return None
    v = tris[sel].reshape(-1, 3)
    return np.array([v.min(axis=0), v.max(axis=0)])


def measure_rail(tris):
    pl = planes(tris)
    # The tip face is the furthest -Y plane of any size; on a whole hook the
    # plate's own front face is larger, so area alone would pick the wrong one.
    back = sorted([p for p in facing(pl, [0, -1, 0]) if p[2] > 50],
                  key=lambda p: p[3][0][1])
    tip = back[0]
    flank = [p for p in pl
             if abs(abs(p[0][0]) - 0.7071) < 0.02 and abs(p[0][1] - 0.7071) < 0.02
             and abs(p[0][2]) < 0.02]
    seat = [p for p in pl if abs(p[0][1] + 0.7071) < 0.02 and abs(p[0][2] - 0.7071) < 0.02]
    seat = [max(seat, key=lambda p: p[2])]
    f = max(flank, key=lambda p: p[2])
    fb = f[3]
    root_half = min(abs(fb[0][0]), abs(fb[1][0]))
    tip_half = max(abs(fb[0][0]), abs(fb[1][0]))
    run = fb[1][1] - fb[0][1]
    sb = seat[0][3]
    tipb = tip[3]
    det = detent_box(tris, tipb[0][1])
    m = {
        # the flank runs from the root plane to the straight part of the tip,
        # so its upper y IS the root plane, whatever else the part carries
        "rail height (root plane to tip face)": fb[1][1] - tipb[0][1],
        "rail tip width":                       tipb[1][0] - tipb[0][0],
        "rail root width":                      2 * root_half,
        "flank run":                            run,
        "flank angle (deg)":                    np.degrees(np.arctan2(tip_half - root_half, run)),
        "full section height":                  tipb[1][2] - tipb[0][2],
        "seat ramp height":                     sb[1][2] - sb[0][2],
        "seat ramp angle (deg)":                np.degrees(np.arctan2(sb[1][1] - sb[0][1],
                                                                     sb[1][2] - sb[0][2])),
        "flank mirror error":                   flank_mirror_error(flank),
    }
    if det is not None:
        m["detent bump height"] = tipb[0][1] - det[0][1]
        m["detent bump diameter"] = det[1][2] - det[0][2]
        m["bump centre below tip face top"] = tipb[1][2] - (det[0][2] + det[1][2]) / 2
    return m


def measure_socket(tris):
    pl = planes(tris)
    front = sorted(facing(pl, [0, 1, 0]), key=lambda p: -p[3][0][1])
    mouth, floor = front[0], front[1]
    flank = [p for p in pl
             if abs(abs(p[0][0]) - 0.7071) < 0.02 and abs(p[0][1] + 0.7071) < 0.02
             and abs(p[0][2]) < 0.02]
    seat = [p for p in pl if abs(p[0][1] - 0.7071) < 0.02 and abs(p[0][2] + 0.7071) < 0.02]
    seat = [max(seat, key=lambda p: p[2])]
    f = max(flank, key=lambda p: p[2])
    fb = f[3]
    mouth_half = min(abs(fb[0][0]), abs(fb[1][0]))
    floor_half = max(abs(fb[0][0]), abs(fb[1][0]))
    depth = fb[1][1] - fb[0][1]
    sb = seat[0][3]
    fl_y = floor[3][0][1]
    # the dimple is 2.3 across on the centre line, so the search is held to a
    # band there: a front part has other things behind its socket floor
    det = detent_box(tris, fl_y, window=1.0, x_max=4.0)
    m = {
        "socket mouth offset from root plane": -mouth[3][0][1],
        "socket depth":                        depth,
        "socket mouth width":                  2 * mouth_half,
        "socket floor width":                  2 * floor_half,
        "flank angle (deg)":                   np.degrees(np.arctan2(floor_half - mouth_half, depth)),
        "seat ramp height":                    sb[1][2] - sb[0][2],
        "seat ramp angle (deg)":               np.degrees(np.arctan2(sb[1][1] - sb[0][1],
                                                                    sb[1][2] - sb[0][2])),
        "flank mirror error":                  flank_mirror_error(flank),
    }
    if det is not None:
        m["dimple depth"] = fl_y - det[0][1]
        m["dimple diameter"] = det[1][2] - det[0][2]
        m["dimple centre below floor top"] = floor[3][1][2] - (det[0][2] + det[1][2]) / 2
    return m


def shells(tris, tol=1e-4):
    """Number of separate closed surfaces in the mesh.

    A part with a sealed internal cavity has two: the outside of the part and
    the inside of the cavity. If the cavity broke through to the surface the
    two would merge into one, so this is a direct test of "sealed".
    """
    key = {}
    parent = []

    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i

    def union(i, j):
        a, b = find(i), find(j)
        if a != b:
            parent[b] = a

    ids = []
    for tri in tris:
        row = []
        for v in tri:
            k = (round(float(v[0]) / tol), round(float(v[1]) / tol), round(float(v[2]) / tol))
            if k not in key:
                key[k] = len(parent)
                parent.append(len(parent))
            row.append(key[k])
        ids.append(row)
    for a, b, c in ids:
        union(a, b)
        union(b, c)
    return len({find(i) for i in range(len(parent))})


def volume(tris):
    a, b, c = tris[:, 0], tris[:, 1], tris[:, 2]
    return float(np.einsum("ij,ij->i", a, np.cross(b, c)).sum() / 6)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("stl")
    ap.add_argument("--part", choices=["rail", "socket"])
    ap.add_argument("--volume", action="store_true")
    ap.add_argument("--shells", action="store_true")
    ap.add_argument("--len", type=float, default=38.0, dest="ilen",
                    help="interface length the part was rendered with")
    ap.add_argument("--bump-h", type=float, default=1.00,
                    help="expected bump height: 1.00 rigid (V1), 0.60 sprung")
    args = ap.parse_args()

    try:
        tris = load_stl(args.stl)
    except Exception as exc:                                   # noqa: BLE001
        print(f"error: cannot read {args.stl}: {exc}")
        return 2
    if len(tris) == 0:
        print(f"{args.stl}: empty (0 facets)")
        return 0

    if args.shells:
        n = shells(tris)
        print(f"{args.stl}: {n} closed surface(s) - "
              f"{'sealed internal cavity' if n > 1 else 'no sealed cavity'}")
        return 0
    if args.volume:
        print(f"{args.stl}: {len(tris)} facets, volume {volume(tris):.3f} mm3")
        return 0

    try:
        measured = measure_rail(tris) if args.part == "rail" else measure_socket(tris)
    except (IndexError, ValueError) as exc:
        print(f"error: could not find the interface features in {args.stl}: {exc}")
        return 2
    ref = dict(REF_RAIL if args.part == "rail" else REF_SOCKET)
    if args.part == "rail":
        ref["detent bump height"] = (args.bump_h, 0.05)
        ref["full section height"] = (args.ilen - 4.0, 0.05)

    print(f"{args.stl}  ({args.part})")
    print(f"  {'measurement':38s} {'measured':>9s} {'V1':>9s} {'delta':>8s} {'tol':>6s}")
    bad = 0
    for name, (want, tol) in ref.items():
        if name not in measured:
            print(f"  {name:38s} {'MISSING':>9s}")
            bad += 1
            continue
        got = measured[name]
        d = got - want
        ok = abs(d) <= tol
        bad += 0 if ok else 1
        print(f"  {name:38s} {got:9.3f} {want:9.2f} {d:+8.3f} {tol:6.2f}  {'ok' if ok else 'FAIL'}")
    print(f"  -> {'PASS' if bad == 0 else str(bad) + ' MEASUREMENT(S) OUT OF TOLERANCE'}")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
