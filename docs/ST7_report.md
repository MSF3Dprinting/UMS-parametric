# UMS V1 — ST-7 report: the humidifier bottle holder

**September 2026 · `ums_bottle_holder.scad` · OpenSCAD 2021.01**

The two standard bottles as presets, or any diameter you like, from one file. It
is a UMS front part: the socket is V1 exactly, so it drops onto any back part and
clicks, measured at **0.137 mm³** of detent interference — the same figure every
other front part gives.

---

## 1. V1's own holders, measured

Both STEPs, converted into the part frame:

| | 49 mm | 56 mm |
|---|---|---|
| Bore | 49.00 | 56.00 |
| Wall | 2.00 | 2.00 |
| Part height | 89.80 | 89.81 |
| Bore height | 85.00 | 85.00 |
| Floor under the bottle | 2.80 | 2.80 |
| Back plate width | 42.00 | 44.00 |
| Ring standoff from the mouth plane | 9.52 | 9.81 |
| Socket, seat below the top | 7.27 | 7.27 |
| Socket length | 76.53 | 76.53 |
| Ring to plate fillet | 6.35 | 5.19 |
| Front opening | ~63° from ~20 up | ~63° from ~20 up |

Those are the defaults. The ring sits tangent to the front face of its plate,
which is the same rule the hooks follow with their bores, and the plate width
comes out at 40.7 and 43.8 against V1's 42 and 44.

---

## 2. Two deviations, both deliberate

**A drain in the floor, Ø12.** V1's floor is closed, so anything spilled into it
stays there. In a ward that is a standing-water problem, and standing water is
worse than the recesses the IPC rules already forbid. `drain_d = 0` restores V1's
closed floor in one parameter. Flagged here rather than buried: it is a change to
a part that has been in the field.

**The plate runs to the bed.** V1 starts its plate above the foot of the part and
opens the socket there; that leaves the underside of the plate hanging in the
air. Running it down and letting the socket groove open at the bottom face does
the same job with nothing unsupported.

---

## 3. What it cost to build, and what that taught

The part is four solids that all meet in the same place — plate, floor, ring and
the blend between them — and every early version of it was degenerate. The
failures were worth recording because they are all the same failure:

* **The plate met the ring tangentially.** A plane touching a cylinder along one
  line is an ill conditioned crossing, and it left slivers the whole height of
  the join. The plate is now driven 1 mm in, a proper crossing.
* **The fillet shared its boundary with both.** Building it as `rounded union
  minus plate minus ring` leaves a solid whose surfaces lie exactly on two other
  solids' surfaces. Nudging it 0.02 either way moved the problem without fixing
  it — 373 non-manifold edges at worst.
* **The answer was to stop unioning solids at all.** Plate, floor, ring and blend
  now come out of one outline extruded once. The question of how two surfaces
  meet never arises, because there are no two surfaces.

Three smaller ones, each found by a check rather than by eye: the bore's lead-in
chamfer grew wide enough at the top to bite a sliver out of the plate behind it;
the floor's top chamfer left the foot of the ring standing over thin air, 117
floating minima; and the opening's corner rounds were scallops on a horizontal
axis, which roof themselves over.

**One rule is not met**: the body has no chamfer where it meets the bed. A
chamfer on a non-convex outline needs a taper that OpenSCAD cannot build without
hulling the outline shut, which is what filled the hook solid back in ST-2. The
plate's top is chamfered; the body's foot is square and wants deburring, as the
datasheet already asks for.

---

## 4. Verification

* **22 renders** (11 variants × 60° and 45°), all pass: both presets, custom 40,
  70 and 100, a closed ring, a wide opening, no drain, no shell, a short ring,
  and loose clearances.
* **Socket measures V1** on every line, dimple included.
* **`probe` against a rail written out in V1's own numbers is empty**, and the
  detent interference is 0.137 mm³ — it clicks.
* **Two closed surfaces**: the outside, and the sealed shell in the plate.
* The shell runs down the middle of the material **behind** the socket, not the
  middle of the plate. At the plate's own mid depth it sat 0.75 off the socket
  floor and broke into the dimple.

---

## 5. Parameters worth knowing

| | |
|---|---|
| `bottle` | `49`, `56` or `custom` |
| `custom_d` | any diameter, 20 to 160 |
| `bottle_clr` | clearance in the cradle; V1 uses none |
| `open_angle`, `open_z` | the front opening, and how far up it starts. 0 closes the ring |
| `drain_d` | 12 by default, 0 for V1's closed floor |
| `ring_h`, `floor_t` | cradle height and the floor the bottle stands on |
| `clr` | the one number that moves the whole fit to the back part |

---

## 6. The opening, rebuilt on a footing that can hold a chamfer

Two rounds of this were wrong, and the reason both times was the same: I was
cutting the opening in a frame where its edges could not be chamfered exactly.

A **slot of fixed width** crosses the curved wall at a different place at every
height and at every point round the arc, so a chamfer aimed at one place misses
at the next — that is what left the vertical edges sharp, and what made the
bottom a hybrid of shapes that did not meet.

The opening is now cut as an **angle**, not a width. In any horizontal section
the material is then an annular sector: its two ends are radial planes, and
taking the corner off at 45° is exact arithmetic, the same at every height.

| | |
|---|---|
| Opening | `open_angle`, 55° — about 26 across at the bore, matching V1 |
| From | `open_bottom`, 19 above the bed |
| Four vertical edges | 45° chamfer, `open_ch` 1.2, at both surfaces, **full size from the bottom of the opening upward** |
| Bottom of the opening | 45° chamfer against the bore and against the outside, stopping just inside each end of the arc so it cannot reach solid wall |
| Wall to floor | 45° chamfer, `foot_ch` 2.0 — a chamfer, not a round |

The vertical chamfers taper away to nothing in the 1.2 mm **below** the opening,
cutting a small mitre into the wall under it. That is deliberate: taper them
upward instead and the chamfer grows in over the first millimetre and leaves a
ledge exactly where the edge starts.

### Verified, edge by edge, before committing

Every one of the four vertical edges probed at eight heights from 22.0 (two
tenths above the foot of the opening) to 86.0, at both surfaces: **0.4 mm into
the corner is void and 1.6 mm into it is solid at all thirty-two points**, which
is what a 1.2 mm chamfer on a 2 mm wall must give. Sections on three planes and
renders from six angles besides.

Things that check caught on the way: the bottom chamfer's flat top leaving a
ledge where it reached past the opening into solid wall; a sliver where the
tapered part of a vertical chamfer met the straight part on a shared plane; and,
on the Ø100, two floating minima from the same cause.

**13 variants pass at 60° and 45°** — both presets, custom 40, 70 and 100, a
closed ring, a 110° opening, a low opening, no drain, no shell, no chamfers at
all, a short ring and loose clearances. Socket measures V1, probe empty, detent
0.137 mm³, two closed surfaces.

---

## 7. Earlier revision: the opening rebuilt from V1, and the foot chamfered

Two faults reported from looking at the part, and the first one was mine for not
reading V1 properly before changing it.

### What V1 actually does, measured

The opening is **not a wedge**. Measured off V1's own mesh, with the ring axis
taken from the STEP at (0, 3.50):

| height above the bottom | opening |
|---|---|
| up to 18 | closed |
| 20 | 18 mm across |
| 24 to 35 | 25 to 26 mm |
| 55 | 30 mm |
| 85 | 34 mm |

That is **a slot about 26 wide with a rounded bottom whose lowest point is 19 up**,
its sides leaning out a few degrees as they rise. A wedge was the wrong shape
entirely, and it is what produced the corner: a wedge leaves a horizontal floor
with a corner at each end of it, and no amount of chamfering makes that look
right. A slot has no corner anywhere — straight sides, a half-circle bottom.

It is now cut as a slot, `open_w` wide from `open_bottom` up, defaulting to
0.46 × bore, which gives 25.8 at the 56 and 22.5 at the 49.

### The foot is a chamfer, not a round

`foot_ch`, 2.0, at 45°. Measured in section: the wall leaves the floor at
z = 4.8 and meets it at 2.8, two millimetres out — a straight 45° cut, nothing
curved about it.

### The edges of the slot

Chamfered at 45° where they cross **both** surfaces. This needed care: the wall
is curved, so at the slot's sides the two surfaces sit nearly 3 mm further back
than the front of the ring. The first attempt aimed the chamfer at the front of
the ring and **missed the edge completely** — the section showed a dead straight,
dead sharp edge. The cutters are now aimed where the edges actually are, with a
second pair aimed at the front of the ring for the rounded bottom, and each is
bounded to a narrow band in y so it can only break the edge it is meant for.

### Verified before committing, not after

Sections on three planes and renders from four angles against V1, side by side,
before anything was rebuilt. The sections are what caught the missed chamfer, a
0.3 mm step where the two chamfer families overlapped, and a ledge where the
rounded-bottom cutter stopped short on the smaller bottles.

**13 variants pass at 60° and 45°** — both presets, custom 40, 70 and 100, a
closed ring, a wide slot, a low slot, no drain, no shell, no chamfers at all, a
short ring, and loose clearances. Socket still measures V1, probe still empty,
detent still 0.137 mm³.

---

## 7. Earlier revision: the edges



Reported from looking at the part: the opening left sharp edges and sharp
corners where it starts, the wall met the floor in a sharp internal corner, and
the drain was sharp at both ends. All three are now broken.

| | |
|---|---|
| Opening, both vertical edges and all four corners | chamfered, `open_ch` 1.0, clamped to half the wall |
| Opening floor, the edge against the bore and the edge against the outside | chamfered at 45° |
| Wall to floor, inside the cradle | coved, `cove` 2.0 |
| Drain, both ends | chamfered, `drain_ch` 1.2 |

Measured by probing the geometry: solid 0.3 in and 0.3 up from the inside
corner where a sharp corner would be void, void 1.0 in and 0.5 up; the drain
void at 6.8 out just under the floor and at 6.8 out just above the bed, solid at
7.5 and at 9.

### What it took, and one thing worth remembering

**`uh_round_convex` cannot be used on a thin wall.** It erodes the profile by the
round radius and then puts it back, so on a 2 mm ring wall a 1 mm round erases
the wall completely — the ring came back in fragments, which is exactly what the
morphological opening is for. The corners are taken off one at a time instead,
which touches nothing else. The clamp is now `wall / 2`.

Three more, each caught by a check:

* The opening was being cut by a wedge **centred on the origin rather than on
  the ring's axis**, so it was never a radial cut at all.
* The floor chamfer ran the full angular width of the opening, which left the
  chamfered tips of the arms **standing over floor that had been cut from under
  them** — 92 floating minima. It is now held back from each end by more than
  the corner chamfer.
* The two halves of the body overlap by 0.01 where they meet, and the chamfer cut
  beneath that overlap, leaving **a hair-thin ring of material hanging in the
  air**. The chamfer cutters now run a millimetre above the floor as well.

After all of it: 22 renders pass at 60° and 45°, the socket still measures V1,
the probe is still empty, and the detent still clicks at 0.137 mm³.

---

## 8. The opening flares, and its top corners are rounded

Added after the slot was in: the opening **widens as it climbs**, and the two
corners where it meets the top rim are **rounded rather than square** — both the
way V1's does, and both cut with the same boolean technique as the slot itself.

| | |
|---|---|
| `open_flare` | 8 — how much wider the slot is at the rim than at its straight part, total. 0 keeps the sides parallel |
| `open_flare_r` | 14 — the radius the sides curve out on, which is also the round left on the two top corners |

The flare is an **arc tangent to the straight side**, drawn in the front view and
pushed back through the wall along y. The first attempt pushed it across x
instead — `rotate([90,0,90])` puts the profile in the y-z plane rather than x-z —
which cut a bite out of the top rim and left the opening the same width. Measured
after the fix, the opening runs 26.0 wide through the straight part and opens to
32.5 at the rim. Tangency is what matters: the sides open out gradually
with no step where the flare begins, and the same arc carries through the rim, so
the corners there are a curve rather than a corner. The arc's rise sets where it
starts — a large radius begins low and opens gently, a small one begins near the
rim and turns quickly.

**Nothing else moved.** The half round at the foot, the fillets on the vertical
edges below the flare, the chamfer where the wall meets the floor, and the drain
are all untouched, and measured again after the change: the four vertical corners
still read rounded at every height below the flare.

### The foot chamfer ran short across the front

It was laid only over the arc where the ring has a wall, stepping round the
slot's angular span — which is wrong, because the slot's foot sits 29 above the
floor and the wall down there is whole. The result was a **gap in the chamfer
right across the front**, where it is most visible.

It now runs the full circle, and only steps round the slot if the slot is brought
low enough to reach the floor (`open_bottom` within a chamfer of it), which is
the only case where there is no wall to chamfer. Probed at twelve angles round
the bore, a chamfer's depth in from the wall and half a chamfer up from the
floor: material at every one of them, front included.

Ten combinations pass at 60°, including no flare at all, a large flare on a large
radius, a tight flare on a small one, and flares on the Ø49 and Ø100.
