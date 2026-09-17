// =====================================================================
//  UMS V1 — tests/ums_front_assembly.scad                          ST-5
//  Preview only. Shows how the adapter bolts to a UniHolder: the
//  holder's back wall, the screws through it, the captive nuts, the
//  adapter, and a back part's rail engaged in the socket.
//
//  Nothing here is a deliverable - the screws, nuts and holder wall are
//  drawn only so the stack can be read.
// =====================================================================

view = "exploded"; // [exploded, assembled, section, only_adapter, only_rail, only_wall, only_screws, only_nuts]

/* [Matching the adapter] */
clr = 0.20;
holder_h = 80;      // holder this adapter was set for
pitch_z = 0;        // 0 = derived, as in the adapter
bolt_d = 4.5;
nut_af = 7.0;
nut_t = 3.2;
bolt_tail = 1.5;
skin = 1.2;
top_margin = 3;
body_w = 40;

$fa = 2; $fs = 0.4;

use <../ums_front_blank.scad>
include <../lib/uh_core.scad>
include <../lib/uh_shapes.scad>
include <../lib/ums_iface.scad>

UH_LO   = 9.67;     // holder's lower back hole, up from its foot
UH_HI   = 6.02;     // upper hole, down from its top
PZ      = pitch_z > 0 ? pitch_z : holder_h - UH_LO - UH_HI;
BT      = UMS_DEPTH + nut_t + bolt_tail + skin;          // 9.9
BH      = max(UMS_LEN_STD + top_margin, PZ + 2 * UH_LO);
Y_FRONT = -clr - BT;                                      // face against the holder
WALL_T  = 3.45;                                           // holder's back wall
SPREAD  = view == "exploded" ? 1 : 0;

if (view == "only_adapter")     front_part();
else if (view == "only_rail")   rail_stub(0);
else if (view == "only_wall")   translate([0, Y_FRONT - WALL_T, 0]) holder_wall();
else if (view == "only_screws") for (j = [0, 1])
        translate([0, Y_FRONT - WALL_T, BH / 2 + (j - 0.5) * PZ]) screw();
else if (view == "only_nuts")   for (j = [0, 1])
        translate([0, Y_FRONT + nut_t / 2, BH / 2 + (j - 0.5) * PZ])
            rotate([90, 0, 0]) rotate([0, 0, 30])
                cylinder(h = nut_t, d = nut_af / cos(30), center = true, $fn = 6);
else if (view == "section") {
    difference() { assembly(); translate([0, -60, -20]) cube([40, 120, 140]); }
} else {
    assembly();
}

module assembly() {
    // the adapter itself
    color("#2a7f88") front_part();
    // a back part's rail, slid into the socket from above
    color("#8d99ae") translate([0, 0, 0]) rail_stub(SPREAD * 26);
    // holder back wall, screws and nuts
    for (j = [0, 1]) {
        z = BH / 2 + (j - 0.5) * PZ;
        color("#c1121f") translate([0, Y_FRONT + nut_t / 2 - SPREAD * 16, z])
            rotate([90, 0, 0]) rotate([0, 0, 30])
                cylinder(h = nut_t, d = nut_af / cos(30), center = true, $fn = 6);
        color("#495057") translate([0, Y_FRONT - WALL_T - SPREAD * 30, z]) screw();
    }
    color("#adb5bd") translate([0, Y_FRONT - WALL_T - SPREAD * 22, 0])
        holder_wall();
}

// A slice of the holder's back wall, with its countersunk holes
module holder_wall() {
    difference() {
        translate([-body_w / 2 - 4, 0, -6]) cube([body_w + 8, WALL_T, BH + 12]);
        for (j = [0, 1]) {
            z = BH / 2 + (j - 0.5) * PZ;
            translate([0, -0.1, z]) rotate([-90, 0, 0]) cylinder(h = WALL_T + 0.2, d = bolt_d);
            translate([0, -0.01, z]) rotate([-90, 0, 0])
                cylinder(h = 2.0, d1 = bolt_d + 4, d2 = bolt_d);
        }
    }
}

// M4-ish countersunk screw, pointing +Y, head at y = 0
module screw() {
    rotate([-90, 0, 0]) {
        cylinder(h = 2.0, d1 = bolt_d + 3.5, d2 = bolt_d - 0.5);
        translate([0, 0, 2.0]) cylinder(h = WALL_T + nut_t + bolt_tail - 1.2, d = bolt_d - 0.5);
    }
}

// The mating rail, in V1's own numbers, seated at the top of the socket
module rail_stub(lift = 0) {
    translate([0, 0, BH - top_margin - UMS_LEN_STD + lift]) difference() {
        linear_extrude(height = UMS_LEN_STD)
            polygon([[-13.017, 0.01], [-13.017, 0], [-15.5, -2.483], [-15.5, -4],
                     [ 15.5, -4], [ 15.5, -2.483], [ 13.017, 0], [13.017, 0.01]]);
        translate([0, 0, UMS_LEN_STD]) rotate([45, 0, 0])
            translate([-30, -30, 0]) cube([60, 60, 60]);
    }
}
