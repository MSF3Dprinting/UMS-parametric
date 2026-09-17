# 3D printed product technical specification datasheet

## General Information

| Field | Value |
|---|---|
| Internal Ref. | N/A |
| Name | Universal Mounting System — parametric back parts and front connector |
| Product stage | Product in development |

## FORM

### Product picture

![The shipped set: hooks, double hook, hook with support, flat plate, pole clip, front blank, UniHolder adapter](st6_overview.png)

### Version / Category / Subcategory / Critical item / Dangerous goods / Short description

- Version: 1.1
- Category: Medical
- Subcategory: Biomed
- Critical item: Yes
- Dangerous goods: No
- Short description: One parametric file generates any UMS back part — a hook for
  a tube from 15 to 50 mm, a double hook, a hook with a support block and strap,
  a flat plate on two screws, or a vertical pole clip — and a second generates
  the front connector and the UniHolder adapter. Every one carries the V1 rail
  unchanged, so they interchange with every UMS V1 front part already in the
  field. The detent is now sprung on a sealed internal cavity rather than forced
  through interference.

### Dimensions / Use / Solution type

- Overall dimensions: set by the tube; a Ø32 hook is 121.6 × 44.2 × 31
- Single/Multiple use: Multiple use item
- Permanent/Temporary solution: Context dependent

### License

- License: MIT

### Readiness

- Field readiness: 3 (geometry verified, not yet printed and trialled)
- Maker readiness: 5
- User readiness: 4
- Technology readiness: 4
- Risk level: 3

### Justification of using 3D printed item

Unchanged from V1. In low-resource hospital settings, limited access to standard
accessories makes it difficult to arrange and attach medical devices, causing
damage, shortened lifespan, improper use and IPC issues. Local printing puts a
fitting mount on whatever tube, pole or wall is actually there.

### Approval required by

- Biomed advisor, IPC advisor

## FIT

### Compatibility

#### Primary compatibility

Back parts, all from `ums_hook.scad`:

- Hook: any round horizontal tube from 15 to 50 mm. V1's Single hook is Ø25,
  Double hook extended is Ø32 with Ø19, Hook with support is Ø32
- Flat plate: any wall surface, two screws Ø3–8, countersunk on the front
- Pole clip: any round vertical pole from 15 to 50 mm

Front parts, from `ums_front_blank.scad`:

- Front blank: the V1 socket on a bare body, to build a holder on
- UniHolder adapter: bolts to a UniHolder's existing back holes. No change to the
  UniHolder itself

Humidifier bottle holder, from `ums_bottle_holder.scad`:

- Presets for the two standard bottles, 49 and 56, matching V1's own holders
- The opening is a slot with a rounded foot that widens toward the rim, with the
  two corners at the rim rounded
- Any other diameter from 20 to 160, set directly
- The floor carries a Ø12 drain, which V1's does not: a closed floor keeps
  whatever is spilled into it. `drain_d = 0` restores the closed floor

#### Compatible accessories

- Flat plate: M5 bolts or screws 4–5 mm
- Hook with support, pole clip: 5 mm zip tie
- Bottle holder: none; the bottle drops in from above. Every edge the bottle or a
  hand meets is broken: the opening's edges and corners are chamfered, the wall
  meets the floor in a cove rather than a sharp internal corner, and the drain is
  chamfered at both ends
- UniHolder adapter: M4 bolts with nuts, or self-tapping screws

#### Interchange with V1

The rail and socket are V1 to the last 0.01 mm: rail 4.00 high, 26.03 at the
root, 31.00 at the tip, 45° flanks, 4.00 seat ramp, detent 27.00 below the top of
the tip face. Verified by measuring the rendered geometry back and by
intersecting every part with a front part written out in V1's own numbers.

### Manufacturing Instructions

#### 3D printing optimization

- **Print orientation is part of the design.** Hooks and the flat plate lie on
  their side, which puts the bore vertical and leaves no unsupported surface at
  all. The pole clip and the front parts stand up. Files are supplied oriented;
  do not re-orient
- No supports anywhere. Every overhang is designed at or under the limit, except
  one 8 mm bridge in the strap channel where it crosses the bed face
- Bottom edges chamfered 0.6; horizontal holes and channels are peaked or
  teardropped
- A 0.15 mm cavity runs down the middle of the wall for the whole length of the
  part: from 3 mm inside the tip of the hook, round the arc, and down the plate
  to 3 mm above its foot, held 2 mm clear of both side faces so it stays sealed. It is far thinner
  than one extrusion, so it prints as nothing; it is there to make the slicer
  lay perimeters either side of it, so the wall comes out solid even if the part
  is sliced at low infill by mistake. **Do not narrow it below 0.12**:
  PrusaSlicer fills cracks under about 0.098 mm before perimeters are generated,
  which is twice its default slice gap closing radius of 0.049, and at 0.05 the
  shell disappears without trace

#### Material and color

- PETG White, Natural or Light Color so it is clearly visible if the item needs
  cleaning or has any surface imperfections

#### List of other materials

- M4 nut for the UniHolder adapter, or a self-tapping screw instead

#### 3D Printer

- 3D Printer: Any FDM 3D printer

#### Slicer settings

- General settings: 0.2 mm layer height, 4 perimeters, no supports
- Brim recommended on hooks and on the flat plate

#### Post processing instructions

- Remove the brim if printed with brim
- Clean the surface from stringing and other imperfections
- Use deburring tool to clean the sharp edges
- Push the nut into the adapter's side channel before fitting it to the holder

#### Assembly instructions

- After installation of the back part, slide the appropriate front part down
  until the detent clicks
- Clean using the recommended cleaning methods before use

#### QC procedures

- Visual inspection: surface free of printing artifacts, stringing and misaligned
  layer lines
- Dimensional validation: the front part must slide on and **click**. Check the
  device fits its holder before installation
- Tolerance inspection: the back and front part should slide easily but hold
  firmly. If the fit is tight or loose, adjust `clr` — one number moves the whole
  fit
- Safety validation: Validate with respective advisors before use
- Regular product check frequency and responsibility: Weekly check after
  installation. Focus on cracks, surface cleanliness, and that the detent still
  springs back

## FUNCTION

### Detailed description

The back part carries the V1 male rail; the front part carries the V1 female
socket. The front part hangs on a 45° seat at the top of the rail and is held
down by a detent. In V1 that detent was a rigid bump forced through 0.8 mm of
interference. Here it sits on a membrane over a **sealed internal cavity**, so it
retracts elastically and springs back 0.31 mm into the dimple of any V1 front
part. Nothing about the front part's inner geometry is changed.

### Additional notes

- The detent membrane is 0.90, two full perimeters on a 0.4 nozzle. Do not thin
  it below 0.8: at 0.6 a slicer lays one perimeter and fills the rest, and the
  fill marks the face of the rail where the front part slides over it
- The rail is 48 long by default against V1's 38. The extra length is what gives
  the sealed cavity room to sit centred on the bump. A 48 rail mates any V1 front
  part; a 38 rail still works but drops the spring

### Cleaning and disinfection / sterilization procedures

- Use Surfanios, Bleach 1:10 or IPA to clean the surface, follow relevant IPC
  guidelines
- Do not use autoclave
- The outer surfaces are unbroken: the detent spring and the wall shell are both
  fully enclosed, with nothing to clean behind or inside

### Packaging and storing instructions

- After production pack in a sealable zip lock bags
- Store in room temperature, do not expose to direct sunlight or humidity

### Related links, standards, safety considerations

- Do not put any text or embossed symbols due to surface cleaning
- Two sealed voids are present by design: the detent cavity in every back part
  and the wall shell in every hook. Nothing can enter either. To be raised
  explicitly at IPC sign-off, since V1 has no cavities at all

### Spaulding Classification (IPC)

- To be added

## ATTACHMENTS

- `dist/ums_hook.scad`, `dist/ums_front_blank.scad` — single file, Customizer ready
- `dist/stl/` — ten print-ready parts
- `docs/` — design plan and the report for each stage

| Role | Name | Date |
|---|---|---|
| Designed by | Silvestr Tkac | Date: |
| Product approved by |  | Date: |
| Product tested by |  | Date: |

## VERSION HISTORY

| Version | Date modified | Modified by | Changes |
|---|---|---|---|
| 1.0 | 11/05/2026 | Silvestr Tkac | Initial documentation |
| 1.1 | 09/2026 | Silvestr Tkac | Parametric rebuild. Detent membrane 0.90 and cavity 24 long, so a 0.4 nozzle lays two full perimeters over it. Humidifier bottle holder added, two presets and any custom diameter, with a drain in the floor. One file for every back part, tube 15–50. Sprung detent on a sealed cavity, replacing V1's interference fit. Rail lengthened to 48 to suit it. Print orientation fixed and stated. Wall shell added to force solid hook walls. Support block widened to full plate width so it lands on the bed. Strap channel carried onto the side faces. Front connector and UniHolder adapter added |
