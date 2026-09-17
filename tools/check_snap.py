#!/usr/bin/env python3
"""UMS V1 - tools/check_snap.py                                        (ST-1)

Measures the click.

The back part's bump has to retract to let a front part slide over it, and it
springs back when it reaches the dimple. How far it springs back is the click.
Nothing here touches the front part: the probe intersects the bump alone with a
block whose socket and dimple are written out in the literal numbers measured
off the V1 STEP models.

For a series of front-part positions it bisects on the retraction until the
intersection is empty, which is the smallest retraction that clears V1.

  python3 tools/check_snap.py tests/ums_iface_coupon.scad

Exit code 0 when the click is at least --min-click. Requires OpenSCAD.
"""
import argparse
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_interface import load_stl, volume  # noqa: E402

# CGAL returns a zero-volume shell rather than "empty" when two surfaces merely
# touch, so clearance is judged on the interference volume, not on emptiness.
TOUCH = 1e-3  # mm3


def interference(scad, retract, zoff, extra):
    """Volume of bump still inside the V1 socket at this retraction, in mm3."""
    stl = "/tmp/ums_snap_probe.stl"
    if os.path.exists(stl):
        os.remove(stl)
    cmd = ["openscad", "-o", stl, "-D", 'part="snap_probe"',
           "-D", f"retract={retract}", "-D", f"zoff={zoff}"] + extra + [scad]
    subprocess.run(cmd, capture_output=True, text=True)
    if not os.path.exists(stl):
        return 0.0
    tris = load_stl(stl)
    return 0.0 if len(tris) == 0 else abs(volume(tris))


def clears(scad, retract, zoff, extra):
    return interference(scad, retract, zoff, extra) <= TOUCH


def min_retraction(scad, zoff, extra, hi=1.5, tol=0.005):
    if clears(scad, 0.0, zoff, extra):
        return 0.0
    lo = 0.0
    while hi - lo > tol:
        mid = (lo + hi) / 2
        if clears(scad, mid, zoff, extra):
            hi = mid
        else:
            lo = mid
    return hi


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("scad")
    ap.add_argument("-D", dest="extra", action="append", default=[],
                    help="extra OpenSCAD parameter, repeatable")
    ap.add_argument("--min-click", type=float, default=0.15)
    args = ap.parse_args()
    extra = [a for d in args.extra for a in ("-D", d)]

    # zoff = 0 is the CAD assembly position, -0.20 is seated on the seat ramp.
    # More negative means the front part has not slid all the way down yet.
    stages = [(-8.00, "sliding on, bump on the plain socket floor"),
              (-2.00, "still on the floor, approaching the dimple"),
              (-0.80, "bump entering the dimple"),
              (-0.40, "nearly seated"),
              (-0.20, "SEATED on the seat ramp"),
              (0.00,  "CAD assembly position")]

    print(f"{args.scad}: retraction the bump needs to clear an unmodified V1 socket")
    print(f"  {'front part position':46s} {'retraction':>10s}")
    results = {}
    for z, label in stages:
        r = min_retraction(args.scad, z, extra)
        results[z] = r
        print(f"  z {z:+6.2f}  {label:36s} {r:10.3f}")

    riding = max(results[-8.0], results[-2.0])
    seated = results[-0.20]
    click = riding - seated
    print(f"\n  rides at            {riding:.3f}")
    print(f"  relaxes to          {seated:.3f}  (residual preload into the seat)")
    print(f"  CLICK, spring back  {click:.3f} mm")
    ok = click >= args.min_click
    print(f"  -> {'PASS' if ok else 'FAIL'} (needs at least {args.min_click})")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
