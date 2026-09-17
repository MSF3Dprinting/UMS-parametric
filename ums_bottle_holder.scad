// =====================================================================
//  UMS V1 — ums_bottle_holder.scad                                 ST-7
//  The humidifier bottle holder, parametric: the two standard bottles
//  as presets, or any diameter you like.
//
//  It is a UMS front part. The socket is V1 exactly - mouth 27, floor
//  35, depth 4 at 45 deg, dimple 26.58 below the top of the floor - so
//  it drops onto any UMS back part and clicks, the same as every other
//  front part. Nothing about the interface is ours to change.
//
//  Built to the same rules as the back parts: prints standing with no
//  supports, bed edges chamfered, nothing that traps fluid, no text or
//  embossing, and a hair-thin cavity down the middle of the plate to
//  make the slicer lay perimeters rather than infill.
//
//  V1's own holders, measured: bore 49 and 56, wall 2.0, ring 85 tall on
//  a 2.8 floor, part 89.8, back plate 42 and 44 wide, ring tangent to
//  the front face of the plate, seat 7.27 below the top, socket 76.53.
//  Those are the defaults here.
// =====================================================================

/* [Bottle] */
// The two standard bottles, or any diameter you like
bottle = "49"; // [49, 56, custom]
// Used when bottle is custom
custom_d = 52; // [20:0.5:160]
// Clearance in the cradle. V1 uses none and lets print tolerance do it
bottle_clr = 0; // [0:0.1:2]

/* [Print] */
max_overhang = 60; // [45:5:60]
quality = "fine"; // [draft, normal, fine]

/* [Fit] */
// Clearance between front and back part, on every mating face
clr = 0.20; // [0:0.05:0.6]
// Dimple for the back part's detent: this is what makes it click
detent = true;

/* [Cradle] */
// Wall of the ring
wall = 2.0; // [1.2:0.1:6]
// Height of the bore, measured off the floor
ring_h = 85; // [20:1:200]
// Floor the bottle stands on
floor_t = 2.8; // [1.2:0.1:10]
// Opening at the front: a slot, straight sides and a half round at the bottom.
// 0 closes the ring. Width 0 = auto, which lands on V1's 26 at the 56
open_w = 0; // [0:0.5:120]
// Lowest point of the slot, above the bed
open_bottom = 19; // [0:0.5:120]
// How much wider the slot is at the rim than in its straight part, total.
// 0 keeps the sides parallel all the way up
open_flare = 8; // [0:0.5:60]
// Radius the sides curve out on as they flare, and the round left on the two
// corners at the top rim
open_flare_r = 14; // [2:0.5:60]
// Lead-in chamfer at the top of the bore, so the bottle drops in
lead_in = 2; // [0:0.5:8]
// Round on the vertical edges of the opening. Kept light: it is taken in the
// horizontal section, where rounding a corner is exact, and the section is
// eroded by this much and put back, so it must stay under half the wall
open_fillet = 0.5; // [0:0.1:2]
// Chamfer where the wall meets the floor inside the cradle
foot_ch = 2.0; // [0:0.1:8]
// Drain in the floor. V1 has none; a closed floor holds whatever is
// spilled into it, which is worth a decision rather than a default
drain_d = 12; // [0:1:60]
// Chamfer round both ends of the drain
drain_ch = 1.2; // [0:0.1:4]

/* [Body] */
// Back plate width. 0 = auto: as wide as the ring is where the plate meets it,
// which lands on V1's own 42 and 44 at the two standard bottles
plate_w = 0; // [0:0.5:160]
// Plate depth, from the socket mouth plane to the front face the ring sits on
plate_d = 9.5; // [5:0.1:40]
// Material above the seat
top_margin = 7.3; // [3:0.1:20]
// Plate carried above the top of the ring
plate_over = 2; // [0:0.5:20]
// Blend between ring and plate
fillet = 5; // [0:0.5:20]
// Chamfer where the part meets the bed
edge_ch = 0.6; // [0:0.1:2]

/* [Wall shell] */
// Hair-thin cavity down the middle of the plate. It prints as nothing; it
// makes the slicer lay perimeters either side of it, so the plate is solid
// whatever the infill. Below about 0.12 a slicer closes it up again
shell = true;
shell_gap = 0.15; // [0.05:0.01:0.5]
shell_end = 3; // [1:0.5:10]
shell_side = 2; // [1:0.5:6]

/* [Hidden] */
include <lib/uh_core.scad>
include <lib/uh_shapes.scad>
include <lib/ums_iface.scad>
include <lib/ums_hook_lib.scad>

$fa = uh_quality(quality)[0];
$fs = uh_quality(quality)[1];

MO      = max_overhang;
// How far the plate is driven into the ring. A plate that merely touches the
// ring meets it tangentially, and a tangential meeting of a plane and a
// cylinder is what leaves slivers all the way up the join. A millimetre in is
// a proper crossing. The bore's lead-in then has to stay clear of it, which is
// what limits LEAD below.
OVERLAP = min(1.0, wall / 2);
// The plate runs to the bed and the socket groove opens at the bottom face, so
// the rail can enter. V1 instead starts the plate above the foot of the part,
// which leaves its underside hanging in the air.
PLATE_BOT = 0;
LEAD    = min(lead_in, wall - OVERLAP - 0.5);
BORE_D  = bottle == "custom" ? custom_d : (bottle == "56" ? 56 : 49);
R_I     = BORE_D / 2 + bottle_clr;
R_O     = R_I + wall;
PW      = uh_auto(plate_w, max(UMS_PLATE_W + 6,
                               2 * sqrt(max(0, R_O * R_O - pow(R_O - plate_d, 2)))));
PART_H  = floor_t + ring_h + plate_over;
PLATE_Z = PART_H - top_margin - (UMS_LEN_STD - UMS_RAMP) - UMS_RAMP + 0.0;
SEAT_Z  = PART_H - top_margin;                     // where the rail's seat lands
Y_FACE  = -clr - plate_d;                          // front face of the plate
YC      = Y_FACE - R_O;                            // ring centre, tangent to it
OPEN_F  = min(open_fillet, wall / 2 - 0.25);       // round on the opening's edges
OPEN_W  = uh_auto(open_w, 0.46 * BORE_D);          // V1: 26 at a bore of 56
OPEN_R  = OPEN_W / 2;                              // the half round at its foot
OPEN_Z  = open_bottom + OPEN_R;                    // where the straight part starts
OPEN_TOP = floor_t + ring_h;                       // top of the ring

ums_iface_selftest();
checks();
bottle_holder();

module bottle_holder() {
    difference() {
        body();
        translate([0, 0, PLATE_BOT])
            ums_socket_cutter(SEAT_Z - PLATE_BOT, clr, detent, below = 2);
        bore();
        slot_foot();
        slot_flare();
        if (drain_d > 0) drain();
        if (shell)
            translate([0, Y_FACE, 0])
                ums_plate_shell(plate_d - UMS_DEPTH - clr,
                                PLATE_BOT + shell_end, PART_H - shell_end,
                                shell_gap, shell_side, PW, "z");
    }
}

// Floor, then ring, then the plate's top, each extruded from its own outline.
//
// The bore is defined ONCE, as a circle in the section, and every level that
// has it uses the same circle. Cutting it as a 3D cylinder over part of the
// height and as a 2D circle over the rest leaves two differently faceted
// surfaces meeting on a plane, which is where the slivers came from.
module body() {
    linear_extrude(height = floor_t) body2d();
    if (OPEN_W > 0) {
        translate([0, 0, floor_t])
            linear_extrude(height = OPEN_Z - floor_t) ring2d();
        translate([0, 0, OPEN_Z])
            linear_extrude(height = floor_t + ring_h - OPEN_Z) open2d();
    } else {
        translate([0, 0, floor_t]) linear_extrude(height = ring_h) ring2d();
    }
    translate([0, 0, floor_t + ring_h - 0.5])
        uh_chamfered_extrude(PART_H - floor_t - ring_h + 0.5, 0, edge_ch, MO)
            uh_round_convex(OPEN_F) plate2d();
    foot();
}

// The ring: the body's outline less the bore
module ring2d() {
    difference() { body2d(); translate([0, YC]) circle(r = R_I); }
}

// The straight part of the slot, taken out of the section so its four vertical
// corners can be rounded exactly: in section the slot's sides are straight and
// the two surfaces are circles, and rounding those corners is the same
// arithmetic at every height. Rounding the solid afterwards means chasing an
// edge that curves as it climbs, which is what kept leaving it sharp.
//
// uh_round_convex erodes by the radius and dilates back, so the radius must
// stay under half the wall or the wall is erased and the ring comes back in
// pieces. Hence a light round, and the clamp on OPEN_F.
module open2d() {
    uh_round_convex(OPEN_F) difference() {
        ring2d();
        translate([-OPEN_R, YC - R_O - 2]) square([OPEN_W, R_O + 2]);
    }
}

// The outline everything is built from: plate and ring blended into one shape.
// Built as separate solids and unioned instead, the plate meets the ring
// tangentially and the blend shares its boundary with both, and both of those
// leave degenerate edges however carefully they are nudged.
module body2d() { uh_round_concave(fillet) union() { plate2d(); disc2d(); } }
module disc2d()  { translate([0, YC]) circle(r = R_O); }

// The plate is driven OVERLAP into the ring rather than left tangent to it: a
// plane meeting a cylinder tangentially is an ill conditioned crossing, and the
// bore's lead-in has to stay clear of the overlap, which is what limits LEAD.
module plate2d() {
    translate([0, Y_FACE - OVERLAP / 2 + plate_d / 2])
        offset(r = 2) square([PW - 4, plate_d + OVERLAP - 4], center = true);
}

// The only thing left for the bore to do in 3D: a lead-in on the top rim, so
// the bottle drops in. The bore itself is in the section.
// Everything the slot takes out below its straight part, and everything it
// takes out above: the half round at its foot, and the flare toward the top.
//
// Both are boolean cuts with a shape drawn in the front view and pushed through
// the wall, which is what keeps them simple. The flare is an arc tangent to the
// straight side, so the sides open out gradually rather than stepping, and the
// same arc is what leaves the two corners at the top rim rounded instead of
// square.
module slot_foot() {
    if (OPEN_W > 0)
        translate([0, YC, OPEN_Z]) rotate([90, 0, 0])
            cylinder(h = R_O + 2, r = OPEN_R);
}

module slot_flare() {
    if (OPEN_W > 0 && open_flare > 0) {
        f  = open_flare / 2;                 // each side opens out by this
        rf = max(open_flare_r, f + 0.5);
        // the arc runs from where it leaves the straight side up to the rim
        rise = sqrt(max(0.01, rf * rf - (rf - f) * (rf - f)));
        z0 = OPEN_TOP - rise;
        // rotate([90,0,0]) keeps the profile in the x-z plane - the front view -
        // and pushes it back along y through the wall. rotate([90,0,90]) puts it
        // in y-z and sweeps it across x, which cuts the top rim instead.
        translate([0, YC, 0]) rotate([90, 0, 0])
            linear_extrude(height = R_O + 2)
                _ums_flare2d(OPEN_R, f, rf, z0, rise);
    }
}

// Front view of the flare: for each side, the ground between the straight slot
// edge and an arc of radius rf tangent to it, swept out to the rim and on up.
module _ums_flare2d(r0, f, rf, z0, rise) {
    for (sg = [-1, 1])
        scale([sg, 1]) difference() {
            translate([r0, z0]) square([f + 2, rise + 20]);
            translate([r0 + rf, z0]) circle(r = rf);
        }
}

module bore() {
    // the lead-in stops growing at the top of the ring and carries on straight
    // up: let it keep widening and it reaches back far enough to bite a sliver
    // out of the plate behind
    translate([0, YC, floor_t + ring_h - LEAD]) {
        cylinder(h = LEAD, r1 = R_I - 0.01, r2 = R_I + LEAD);
        translate([0, 0, LEAD - 0.01]) cylinder(h = 0.8, r = R_I + LEAD);
    }
}

// The chamfer where the wall meets the floor. This corner is concave, so the
// chamfer is material put into it rather than material taken out, and it is
// laid only round the arc where there is a wall to meet.
module foot() {
    ch = min(foot_ch, floor_t, R_I - 2);
    // The chamfer is laid round the whole circle, because at floor level the
    // wall is whole: the slot's foot sits well above it. Only if the slot were
    // brought down into the floor would the chamfer have to step round it, and
    // then only over the arc the slot actually takes there.
    reaches = OPEN_W > 0 && open_bottom < floor_t + ch + 0.5;
    aa = reaches ? 2 * asin(min(1, OPEN_R / R_I)) : 0;
    if (ch > 0)
        translate([0, YC, 0])
            rotate([0, 0, 270 + aa / 2])
                rotate_extrude(angle = 360 - aa)
                    polygon([[R_I - ch, floor_t], [R_I + 0.5, floor_t],
                             [R_I + 0.5, floor_t + ch], [R_I, floor_t + ch]]);
}

// Drain, chamfered at both ends: sharp at the bed and sharp inside the cradle
// are both edges someone has to clean round
module drain() {
    ch = min(drain_ch, floor_t / 2 - 0.2);
    translate([0, YC, 0]) {
        translate([0, 0, -1]) cylinder(h = floor_t + 2, d = drain_d);
        if (ch > 0) {
            // inside the cradle, opening upward
            translate([0, 0, floor_t - ch])
                cylinder(h = ch + 0.01, d1 = drain_d, d2 = drain_d + 2 * ch);
            // at the bed, 45 deg and self supporting
            translate([0, 0, -0.01])
                cylinder(h = ch + 0.01, d1 = drain_d + 2 * ch, d2 = drain_d);
        }
    }
}

module checks() {
    assert(wall >= 1.2, "ring wall below 1.2");
    assert(PW >= UMS_PLATE_W, "plate is narrower than the rail");
    uh_warn(SEAT_Z - PLATE_BOT >= UMS_LEN_STD,
        str("socket ", SEAT_Z - PLATE_BOT, " long engages less than a full ",
            UMS_LEN_STD, " rail; raise ring_h"));
    uh_warn(OPEN_W <= BORE_D - 8, str("slot ", OPEN_W, " wide leaves little arm"));
    uh_warn(OPEN_W == 0 || OPEN_W + open_flare <= BORE_D - 8,
        str("slot opens out to ", OPEN_W + open_flare, " at the rim, little arm left"));
    uh_warn(OPEN_W == 0 || open_bottom >= floor_t + 1,
        str("slot starts at ", open_bottom, ", which is into the floor"));
    uh_warn(open_fillet <= wall / 2 - 0.25,
        str("round of ", open_fillet, " clamped: it has to stay under half the ",
            wall, " wall or the section is eroded away"));
    uh_warn(drain_d == 0 || drain_d <= BORE_D - 2 * wall - 8,
        str("drain \u00d8", drain_d, " leaves little floor for the bottle to stand on"));
    uh_warn(!shell || (plate_d - UMS_DEPTH - clr) / 2 - shell_gap / 2 >= UMS_DIMPLE_H + 0.8,
        str("only ", (plate_d - UMS_DEPTH - clr) / 2 - shell_gap / 2,
            " between the shell and the socket floor; the dimple alone is ",
            UMS_DIMPLE_H));
    uh_warn(!shell || shell_gap >= 0.12,
        str("wall shell gap ", shell_gap,
            " is at or below what a slicer closes on its own, about 0.098"));
    uh_info(str("bottle holder \u00d8", BORE_D, ": ring ", 2 * R_O, " outside, ",
                ring_h, " tall on a ", floor_t, " floor,",
                " wide from ", open_bottom, " up, plate ", PW, " x ", plate_d,
                ", socket ", SEAT_Z - PLATE_BOT, " long seating ", top_margin,
                " below the top, part ", PART_H, " tall"));
}
