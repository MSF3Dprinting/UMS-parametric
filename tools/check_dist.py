#!/usr/bin/env python3
"""UMS V1 - tools/check_dist.py                                       (ST-6)

Final gate on everything in dist/stl: each part is checked for the interface it
carries, for printability in its own orientation, and for the sealed cavities it
should have. Hooks and plates lie on their side, the pole clip and the front
parts stand, so each is rotated to how it prints before the overhang check.

The shipped files are built at the 60 degree default, and that is the limit they
are held to here: a part built for 60 has 60 degree features by design. The
variant matrices are what prove the sources also come out clean at 45.
"""
import os
import subprocess
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_interface import load_stl, shells, measure_rail, measure_socket, planes  # noqa: E402

# part: (which way is up in the print, which interface it carries, shells wanted)
PARTS = {
    "hook_tube19":       ("x", "rail",   3),
    "hook_tube25":       ("x", "rail",   3),
    "hook_tube32":       ("x", "rail",   3),
    "hook_double_32_19": ("x", "rail",   3),
    "hook_support_32":   ("x", "rail",   3),
    "plate_2screw":      ("x", "rail",   2),
    "pole_clip_25":      ("z", "rail",   2),
    "pole_clip_32":      ("z", "rail",   2),
    "front_blank":       ("z", "socket", 1),
    "front_adapter_h80": ("z", "socket", 1),
    "bottle_holder_49":  ("z", "socket", 2),   # outer, and the plate's shell
    "bottle_holder_56":  ("z", "socket", 2),
}
REF = {"rail": [("rail height (root plane to tip face)", 4.00),
                ("rail tip width", 31.00), ("rail root width", 26.04),
                ("flank angle (deg)", 45.0), ("seat ramp height", 4.00),
                ("bump centre below tip face top", 27.00),
                ("flank mirror error", 0.00)],
       "socket": [("socket depth", 4.00), ("socket mouth width", 27.00),
                  ("socket floor width", 35.00), ("flank angle (deg)", 45.0),
                  ("seat ramp height", 4.00),
                  ("dimple centre below floor top", 26.58),
                  ("flank mirror error", 0.00)]}


def rotate_for_print(src, up, dest):
    tri = load_stl(src)
    if up == "x":                       # lay it on its side: -90 about y
        tri = tri @ np.array([[0, 0, -1], [0, 1, 0], [1, 0, 0]], float).T
    header = "solid ums\n"
    lines = [header]
    for t in tri:
        lines.append("facet normal 0 0 0\n outer loop\n")
        for v in t:
            lines.append(f"  vertex {v[0]:.5f} {v[1]:.5f} {v[2]:.5f}\n")
        lines.append(" endloop\nendfacet\n")
    lines.append("endsolid ums\n")
    open(dest, "w").writelines(lines)


def main():
    bad = 0
    print(f"{'part':>20} {'interface':>10} {'shells':>7} {'60 deg':>7}")
    for name, (up, iface, want_shells) in PARTS.items():
        src = f"dist/stl/{name}.stl"
        tri = load_stl(src)
        m = measure_rail(tri) if iface == "rail" else measure_socket(tri)
        worst = max(abs(m[k] - v) for k, v in REF[iface] if k in m)
        sh = shells(tri)
        rotate_for_print(src, up, "/tmp/dist_print.stl")
        verdicts = []
        for mo in (60,):
            r = subprocess.run([sys.executable, "tools/check_overhang.py",
                                "/tmp/dist_print.stl", "--max-overhang", str(mo),
                                "--bridge-span", "12"],
                               capture_output=True, text=True)
            verdicts.append("pass" if r.returncode == 0 else "FAIL")
        ok = worst <= 0.05 and sh == want_shells and verdicts == ["pass"]
        bad += 0 if ok else 1
        print(f"{name:>20} {worst:9.3f} {sh:7d} {verdicts[0]:>7}"
              f"  {'' if ok else '  <-- CHECK'}")
    print("->", "PASS" if bad == 0 else f"{bad} PART(S) OUT")
    return 0 if bad == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
