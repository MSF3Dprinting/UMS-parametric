// =====================================================================
//  UMS V1 — tests/ums_hook_probe.scad                              ST-2
//  Does the generated hook still fit a real V1 front part?
//
//  Intersects the hook with a front-part block whose socket and dimple are
//  written out in the literal numbers measured off the V1 STEP models.
//  probe must come out EMPTY; snap is the detent interference alone.
// =====================================================================

part = "probe"; // [probe, snap, block]
rail_len = 48;  // must match the hook
v1_len = 38;    // a real V1 front part

use <../ums_hook.scad>
$fa = 2; $fs = 0.4;

BODY_W = 40;
BODY_T = 8;

if (part == "probe")      intersection() { hook_no_detent(); v1_front_block(); }
else if (part == "snap")  intersection() { hook_with_detent(); v1_front_block(); }
else                      v1_front_block();

module hook_with_detent() { back_part(); }
module hook_no_detent()   { difference() { back_part(); bump_box(); } }

// Everything the bump could occupy, so the probe tests the rail alone
module bump_box() {
    translate([-3, -6.2, rail_len - 4 - 27 - 3]) cube([6, 2.4, 6]);
}

// The front part, in V1's own numbers, hung from the rail's seat
module v1_front_block() {
    translate([0, 0, rail_len - v1_len]) difference() {
        translate([-BODY_W / 2, -0.20 - BODY_T, 0])
            cube([BODY_W, BODY_T, v1_len + 3]);
        difference() {
            translate([0, 0, -2]) linear_extrude(height = v1_len + 2)
                polygon([[-13.50, 10.00], [-13.50, -0.20], [-17.50, -4.20],
                         [ 17.50, -4.20], [ 13.50, -0.20], [ 13.50, 10.00]]);
            translate([0, 0, v1_len + 0.20]) rotate([45, 0, 0])
                translate([-200, -200, 0]) cube([400, 400, 400]);
        }
        translate([0, -4.20, v1_len - 4 - 26.58]) rotate([90, 0, 0])
            rotate_extrude() polygon([[0, 0], [1.15, 0], [0.30, 0.70], [0, 0.70]]);
    }
}
