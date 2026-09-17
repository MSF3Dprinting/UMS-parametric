# UMS V1 — One parametric back part (hook) + a generic front connector

**Design plan v1.0 · September 2026 · for review — no code written yet**

Reference material used: `UMS_Drawing.pdf`, the five back-part STEP files, the three
front-part STEP files, `README.md`, `DATASHEET_TEMPLATE.md`, and `uniholder_st4.zip`
(v0.4, ST-4 complete). All dimensions below were **measured from the STEP B-rep**, not
read off the drawing, and are exact to 0.01 mm unless marked ≈.

---

## 1. Goal

Two OpenSCAD parts that replace the five hand-modelled UMS back parts and connect the
UniHolder to the system:

1. **`ums_hook.scad`** — one fully customisable UMS back part, driven by the diameter of
   the tube it hangs on. It reproduces the V1 male rail exactly, so every existing UMS
   front part fits it.
2. **`ums_front_blank.scad`** — a generic front-part connector: the V1 female socket on a
   blank plate, with an option that bolts it to the UniHolder's back holes (the same
   attachment method planned for the DIN rail clip in UniHolder ST-5).

The UniHolder design is not touched. The adapter is a separate part in the UMS project.

---

## 2. The V1 interface, as measured

This is the contract. Everything else is free; these numbers are not.

### 2.1 Socket (female, on every front part)

| Feature | Value | Source |
|---|---|---|
| Mouth width | **27.00** | all three front parts |
| Floor width | **35.00** | all three front parts |
| Depth (mouth → floor) | **4.00** | all three front parts |
| Flank angle | **45°** | — |
| Top stop | 45° ramp, 4 × 4, closing the groove | ultrasound f110, humidifier f31, oximeter f169 |
| Detent dimple | ≈Ø2.3 × 0.70 deep, flat bottom ≈Ø0.6 | — |
| Dimple position | on the centreline, **26.58 below the top of the socket floor** | identical on all three |
| Socket length | varies by part: 32.2 / 37.8 / 72.5 | not part of the contract |

### 2.2 Rail (male, on every back part — identical on all five)

| Feature | Value |
|---|---|
| Height (root plane → tip face) | **4.00** |
| Root width | **26.04** |
| Tip width | **31.00** |
| Flank | **45°**, 2.48 of run, then **1.52 straight** to the tip |
| Length of full section | **34.00**, plus a 45° lead-in ramp 4 × 4 on top = **38.00** total |
| Detent bump | dome ≈Ø3.3 × **1.00 proud** of the tip face, flat cap ≈Ø0.45 |
| Bump position | on the centreline, **27.00 below the top of the tip face** (7.00 above its bottom) |
| Back plate | **31.00** wide × **3.80** thick, vertical edges chamfered 0.6 |

### 2.3 Cross-section (not to scale)

```
        back plate (3.80)                      front part
   ┌───────────────────────────┐        ┌────────────────────────┐
   │                           │        │                        │
   │        rail root 26.04    │        │   mouth 27.00          │
   │      ╱───────────────╲    │        │  ╱──────────────╲      │
   │     ╱ 45°         45° ╲   │        │ ╱ 45°        45° ╲     │   4.00
   │    │   tip 31.00       │  │        ││   floor 35.00    │    │   deep
   │    └───────●───────────┘  │        │└──────○──────────┘     │
   │        detent bump        │        │    dimple              │
   └───────────────────────────┘        └────────────────────────┘
        ← 4.00 tall rail →                 relief at the corners
```

### 2.4 How the joint actually works

* Every mating face carries a uniform **0.20 clearance**; the male is the female offset
  inwards by 0.20 on all faces. In the CAD assembly the socket floor never touches the
  rail tip and the mouth face never touches the shoulder — **only the two 45° flanks
  locate the part**, in X and in Y.
* Vertical load is carried by the **45° ramp at the top**: the front part slides down the
  rail until its closing ramp seats on the rail's lead-in ramp. It is a hanging joint,
  not a bottoming one.
* The detent is **deliberately offset**: bump 27.00 below the rail top, dimple 26.58
  below the socket top. Once seated, the bump sits ≈0.2–0.4 below the dimple centre and
  preloads the front part up into the ramp seat — that is what removes the rattle. The
  bump (1.00 tall, Ø3.3) is also larger than the dimple (0.70, Ø2.3), so it engages the
  dimple edge and clicks rather than nesting.

I will treat this as intentional and reproduce it, with `fit_clr` and `detent_preload`
exposed as parameters. **Please confirm** — if either was an artefact rather than a
decision, now is the moment to say so.

### 2.5 One discrepancy to confirm

The drawing's back part is dimensioned **30.6** wide; every back-part STEP measures
**31.00** (29.80 between the 0.6 chamfers). The drawing shows the wall mount with safety
lock, which was not uploaded. I am taking **31.00** as master. Is the wall mount genuinely
0.4 narrower, or is the drawing stale?

---

## 3. The back parts, as measured

| Part | Tube | Bore r | Outer r | Wall | Notes |
|---|---|---|---|---|---|
| Single hook | Ø25 | 12.50 | 16.30 | 3.80 | bore centre 16.30 in front of the rail root plane, so the tube rests against the back face of the plate; wrap ≈225°, mouth opens down and rearwards |
| Double hook extended | Ø32 + Ø19 | 16.00 / 9.50 | 19.80 / 13.30 | 3.80 | two bores on one plate, second bore ≈45 lower; plate extended to 163 long |
| Hook with support | Ø32 | 16.00 | 19.80 | 3.80 | plus a support block 16.0 deep with a Ø20 notch, and a 1.0 × 8.0 strap channel across the rear face for the zip tie |
| Vertical attachment 20 / 25 | Ø20 / Ø25 | 10.00 / 12.50 | ≈13.5 / 16.0 | ≈3.5 | cradle axis vertical, wrap ≈200° (snap past the equator), spine 8.8 between rail root plane and cradle, two 6 mm tie grooves |

Bores are modelled at **exactly nominal** — no clearance. Print tolerance provides the
fit. I will keep that as the default and expose `tube_clr` anyway.

**Print orientation**, confirmed by overhang analysis of all five parts: they print
standing, in the modelled orientation, as the README states. Residual steep areas in V1
that my version can remove: the top of a horizontal hook bore (≈385 mm² above 60° on the
single hook) and the unsupported 31 × 4 ledge under the rail on parts that lack the 45°
under-ramp. See §5.

---

## 4. Scope

| Area | In | Out |
|---|---|---|
| Back part | One file generating: horizontal tube hook (1 or 2 bores), extended plate, support block + strap channel, vertical pole clip with tie grooves | Wall mount with safety lock (see question Q1) |
| Interface | Male rail, detent, lead-in ramp, from a shared library | Any change to the V1 profile |
| Front side | Generic blank connector carrying the female socket; UniHolder adapter variant of it | Redesign of the four existing device holders |
| Delivery | Customizer files, print-ready STLs, preview images, README, datasheet update | Field testing, advisor sign-off |

---

## 5. Printability rules

Carried over from the UniHolder plan, which already encodes them, plus the UMS-specific
ones from the README and the datasheet.

| Rule | Statement |
|---|---|
| P1 | Print as used: rail axis vertical, plate on the bed, no supports, no re-orientation |
| P2 | No downward surface exceeds `max_overhang` (60° from vertical default, 45° selectable) |
| P3 | Overhanging features get in-built 45° support slopes — including the underside of the rail, which V1 leaves unsupported on some parts |
| P4 | Horizontal holes and bore crowns are teardropped, so a horizontal hook bore is printable without support (optional, see Q3) |
| P5 | Bed edges chamfered 45°, vertical edges chamfered 0.6 as in V1 |
| P6 | Walls ≥ 1.2 |
| IPC1 | **No text, no embossing, no engraved marks anywhere** — identification lives in the documentation and the packaging |
| IPC2 | No blind cavities that trap fluid; the fastener pockets on the adapter are closed by the UniHolder's back wall once assembled |
| M1 | PETG, white/natural/light colour, 0.2 mm layers, 4 perimeters, brim on hooks |

---

## 6. Conventions

`z = 0` is the bed and the bottom of the part. `y = 0` is the **rail root plane** (the
front face of the back plate); the rail runs to −Y, the tube and everything else to +Y.
`x = 0` is the centreline. `0` means auto.

```
ums/
  ums_hook.scad             back part — Customizer
  ums_front_blank.scad      front connector + UniHolder adapter — Customizer
  lib/ums_iface.scad        the V1 interface: rail, socket, detent, clearances
  lib/ums_hook_lib.scad     bores, hooks, clips, support block, strap features
  lib/uh_core.scad          vendored unchanged from UniHolder v0.4
  lib/uh_shapes.scad        vendored unchanged from UniHolder v0.4
  tools/check_overhang.py   vendored unchanged
  tools/render_matrix.py    vendored unchanged
  tools/check_interface.py  new — measures a rendered STL against the V1 numbers
  tests/                    variant JSONs and coupons
  dist/                     single-file Customizer versions
```

Vendoring `uh_core` / `uh_shapes` keeps the UMS deliverable standalone and leaves the
UniHolder untouched. The alternative is a relative include across two folders. **Q4.**

---

## 7. Customizer parameters

Defaults reproduce V1. Values in **bold** are locked by the interface contract and
guarded by asserts.

| Tab | Parameters (default) | ST |
|---|---|---|
| Print | `max_overhang` (60), `quality` (normal), `fit_clr` (**0.20**), `tube_clr` (0) | 1 |
| Attachment | `attach` (hook_h / clip_v), `tube_d` (32), `tube_d2` (0 = none), `tube2_drop` (0 = auto), `wall_t` (3.8), `wrap` (0 = auto: 225 hook, 200 clip), `mouth_angle` (−45), `tip_r` (1.5), `bore_crown` (teardrop / round) | 2–4 |
| Plate | `plate_w` (**31**), `plate_t` (**3.8**), `plate_above` (0), `plate_below` (0), `edge_ch` (0.6) | 2 |
| Rail | `rail_len` (**38**), `rail_z` (0 = auto), `detent` (dome / teardrop / none), `detent_preload` (0.3) | 1–2 |
| Support | `support` (none / notch), `support_depth` (16), `notch_d` (20), `support_len` (36) | 3 |
| Strap | `strap` (none / channel / slot), `strap_w` (6), `strap_t` (1.2), `strap_z` (0 = auto) | 3 |
| Vertical clip | `tie_count` (2), `tie_w` (6), `tie_depth` (2), `spine_t` (8.8) | 4 |
| *(front blank)* Socket | `socket_len` (0 = auto), `body_w` (40), `body_t` (0 = auto), `body_h` (0 = auto) | 5 |
| *(front blank)* Fixing | `fix` (nut_pocket / pilot / through), `bolt_d` (4.5), `nut_af` (7.0 = M4), `cols` (1), `rows` (2), `pitch_x` (0), `pitch_z` (0), `slot_travel` (6) | 5 |

Single hook = `tube_d 25`. Double hook extended = `tube_d 32, tube_d2 19, plate_below 79`.
Hook with support = `tube_d 32, support notch, strap channel`. Vertical attachment =
`attach clip_v, tube_d 20` or `25`.

---

## 8. The UniHolder adapter

Same attachment method as the planned DIN clip: a **separate printed part bolted through
the UniHolder's existing back holes**. Nothing in the UniHolder changes.

* The adapter is the front blank with `fix = nut_pocket`: the screw goes in from inside
  the holder, through the back wall (head already seats flush there), through the
  adapter, into a **captive hex nut** in a pocket on the adapter's mating face. The
  pocket is closed on the socket side and sealed by the holder's back wall once
  assembled — nothing open to clean around.
* `fix = pilot` gives a self-tapping blind hole instead, for a thinner part;
  `fix = through` puts the nut on the socket side of a thin plate (not recommended).
* Hole pattern: `cols` × `rows` at `pitch_x` / `pitch_z`, defaulting to the UniHolder
  default of 1 × 2. Because the UniHolder spreads its holes automatically when pitch is
  0, the adapter's holes are **vertical slots** with `slot_travel` of play, and the README
  will say: set explicit `back_hole_pitch_x/z` in the UniHolder Customizer and enter the
  same numbers here. **Q5 — is a slot acceptable, or do you want exact holes only?**
* Thickness stack: 4.0 socket depth + nut pocket (3.2 for M4) + 1.2 skin ≈ **8.4** total,
  so the holder stands ≈8.4 off the rail root plane. A pilot-hole version is ≈6.0.
* The blank prints standing exactly like the existing front parts: the groove is a
  vertical slot, its 45° closing ramp at the top is the only overhang, and the dimple is
  a shallow recess in a vertical wall.

---

## 9. Sub-tasks

Each sized to one working session, each ending in a checked artefact.

| ST | Deliverable | Done when |
|---|---|---|
| **ST-0** | This plan | You confirm §2 and the questions in §10 |
| **ST-1** | `lib/ums_iface.scad`, `tools/check_interface.py`, mating coupon | The coupon's rail and socket, measured back off the rendered STL, match every number in §2.1–2.2 within 0.05; coupon passes the overhang check at 60° and 45° |
| **ST-2** | `ums_hook.scad` v0.2: plate, rail, single horizontal hook | Ø19 / 25 / 32 and two edge sizes render, pass at 60° and 45°, and a virtual mate with the real V1 front-part STEPs shows no intersection and ≤0.3 play |
| **ST-3** | Second bore, extended plate, support block, strap channel and slot | Double-hook-extended and hook-with-support equivalents render and pass; strap channel clears a 6 mm tie |
| **ST-4** | Vertical pole clip: cradle, snap arms, tie grooves | Ø20 / 25 / 32 clips render, pass at 60° and 45°, arms wrap past the equator and flex without a floating lowest point |
| **ST-5** | `ums_front_blank.scad` + UniHolder adapter variant | Blank mates the ST-2 rail; adapter's bolt pattern matches a UniHolder rendered at default and at two other sizes; nut pocket closes against the back wall |
| **ST-6** | README, print-ready STLs, previews, datasheet V1.1 rows, `dist/` single-file versions | Single file renders identically to the multi-file version; datasheet updated with the new part and its compatibility table |

Working method per sub-task, as with the UniHolder: write, render a variant matrix at 60°
and 45° in one run, at most three fix rounds, one preview image, cumulative zip.

---

## 10. Questions before I start

1. **Q1 — scope of "all back parts".** The plan covers the hooks and the vertical pole
   clip in one file. The **wall mount with safety lock** is the fifth back part; its STEP
   was not uploaded and it has a latch feature the others do not. Add it as a third
   `attach` mode (`plate_flat`, screw holes, optional latch), or leave it out of V1?
2. **Q2 — detent.** Reproduce V1's oversized bump and offset dimple exactly (§2.4), or
   take the opportunity to make the bump and dimple concentric and matched?
3. **Q3 — horizontal bore crown.** V1's hook bore has a plain circular crown, which is
   the one place the part needs a bridge. A teardrop crown prints clean at 45° and does
   not change where the tube contacts. Default it on?
4. **Q4 — library reuse.** Vendor `uh_core.scad` and `uh_shapes.scad` into the UMS
   project unchanged, or include them across folders from the UniHolder?
5. **Q5 — adapter bolt pattern.** Slots with play, or exact holes and a documented
   requirement to set explicit pitches in the UniHolder?
6. **Q6 — rail length.** Keep 38 fixed, or allow shorter? The detent has to stay 27.00
   below the top, so anything under ≈32 loses it.

Once you confirm, I'll start with ST-1 and stop again at its verification output.
