# UMS V1 — parametric back parts and front connector

One OpenSCAD file generates any UMS back part; a second generates the front
connector and the UniHolder adapter. Both carry the V1 interface unchanged, so
they interchange with every UMS V1 front part already in the field.

![The shipped set](docs/st6_overview.png)

OpenSCAD 2021.01 or newer, no external libraries. MIT, as V1.

---

## Start here

| I want to | Open |
|---|---|
| Make a hook, plate or pole clip | `ums_hook.scad` |
| Make a front connector or a UniHolder adapter | `ums_front_blank.scad` |
| Make a humidifier bottle holder | `ums_bottle_holder.scad` |
| Print something now | `dist/stl/` |
| Put it on a sharing site with a Customizer | anything in `dist/*.scad` |

`dist/` holds single-file builds with the libraries pasted in, because a
Customizer will not follow an include. They are generated, not edited:
`python3 tools/make_dist.py` rebuilds them and proves each one renders facet for
facet identically to the multi-file source across every variant.

---

## Printing

**Orientation is part of the design.** Hooks and the flat plate lie on their
side, which stands the bore vertical and leaves no unsupported surface. The pole
clip and every front part, bottle holder included, stand up. The STLs come oriented — do not re-orient
them.

PETG, white or another light colour, 0.2 mm layers, 4 perimeters, **no
supports**, brim on hooks and plates. No part needs support anywhere, bar one
8 mm bridge where the strap channel crosses the bed face.

---

## What is in each file

| | |
|---|---|
| `ums_hook.scad` | Back parts: hook for a tube 15–50, second bore, support block with strap, flat plate on two screws, vertical pole clip |
| `ums_front_blank.scad` | Front blank, and the same with a bolt pattern for a UniHolder |
| `ums_bottle_holder.scad` | Humidifier bottle holder: the 49 and 56 as presets, or any diameter |
| `lib/ums_iface.scad` | The V1 interface: rail, socket, detent, sealed cavity. The single source of every dimension that has to match V1 |
| `lib/ums_hook_lib.scad` | Hook, plate, support block, strap, wall shell |
| `lib/ums_pole_lib.scad` | Pole clip |
| `lib/uh_core.scad`, `lib/uh_shapes.scad` | Vendored unchanged from UniHolder v0.4, md5 verified |

The UniHolder project is not modified. The adapter is a separate part that bolts
through the holder's existing back holes.

---

## Checking

Everything is verified by measuring the rendered geometry, never by trusting the
source.

| Tool | Asks |
|---|---|
| `check_interface.py` | Does the rail or socket still match V1, measured off the STL? |
| `check_overhang.py` | Anything past the overhang limit, floating, or non-manifold? `--bridge-span` tells a bridge from a cantilever |
| `check_snap.py` | How far does the detent spring back against an unmodified V1 socket? |
| `check_bolt_pattern.py` | Do the adapter's slots land on a real UniHolder's back holes? |
| `check_dist.py` | Final gate on every shipped STL |
| `render_matrix.py` | Renders a whole variant matrix at several overhang limits |

```
python3 tools/render_matrix.py ums_hook.scad tests/st3_variants.json --limits 60 45 --bridge-span 12
python3 tools/render_matrix.py ums_bottle_holder.scad tests/st7_variants.json --limits 60 45
python3 tools/check_dist.py
```

`--bridge-span` is needed wherever the strap channel is used: its groove in the
bed face is an 8 mm bridge by design, and without the flag the checker rightly
calls it a 90° ceiling.

Current state: every variant in every matrix passes at 60° and 45°, every shipped
STL passes its final gate, the interface measures V1 to 0.006 mm on every part,
and all three probes — hook, front blank, bottle holder — come back empty against
parts written out in V1's own numbers, with the detent interfering 0.137 mm³.

The detent membrane is 0.90, which is two full perimeters on a 0.4 nozzle. Do
not thin it below 0.8: at 0.6 a slicer lays one perimeter and fills the rest,
and the fill marks the face of the rail. See `docs/ST8_report.md`.

One slicer note. A 0.15 mm cavity runs down the middle of the wall for the whole
length of the part — from inside the tip of the hook, round the arc and down the
plate to its foot. It prints as nothing, but it makes the slicer lay perimeters
either side of it, so the wall is solid whatever the infill. Do not narrow it below 0.12: PrusaSlicer fills
cracks under about 0.098 mm — twice its default 0.049 gap closing radius — and
the shell then does nothing at all.

---

## Reading order

`docs/UMS_hook_design_plan.md` first, then the stage reports ST1 to ST8. The
datasheet for the parts themselves is `docs/UMS_V1.1_datasheet.md`.

Material, cleaning and IPC rules follow the UMS V1 datasheet: PETG in a light
colour so soiling shows, surface disinfection only, no autoclave, and no text or
embossing anywhere on a part that has to be cleaned.
