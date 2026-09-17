// =====================================================================
//  UMS V1 — tests/ums_front_probe.scad                             ST-5
//  Does the front blank take a real back part? Intersects the blank with
//  a rail written in literal V1 numbers, at V1's own 38 and at 48.
//  probe must be EMPTY; snap is the detent alone.
// =====================================================================
part = "probe"; // [probe, snap]
rail_len = 48;
// Where the blank seats the rail: its own height less top_margin. Keep this in
// step with ums_front_blank.scad - 83.65 tall, 3 of margin, so 80.65.
seat_z = 80.65;
$fa = 2; $fs = 0.4;
use <../ums_front_blank.scad>
include <../lib/uh_core.scad>
include <../lib/uh_shapes.scad>
include <../lib/ums_iface.scad>

if (part == "probe") intersection() { front_part(); v1_rail(false); }
else                 intersection() { front_part(); v1_rail(true); }

// A back part's rail, in V1's own numbers, seated at the top of the blank
module v1_rail(with_bump) {
    translate([0, 0, seat_z - rail_len]) {
        difference() {
            linear_extrude(height = rail_len)
                polygon([[-13.017, 0.01], [-13.017, 0], [-15.5, -2.483], [-15.5, -4],
                         [ 15.5, -4], [ 15.5, -2.483], [ 13.017, 0], [13.017, 0.01]]);
            translate([0, 0, rail_len]) rotate([45, 0, 0])
                translate([-200, -200, 0]) cube([400, 400, 400]);
        }
        if (with_bump)
            translate([0, -4, rail_len - 4 - 27]) rotate([90, 0, 0])
                rotate_extrude() polygon([[0, 0], [1.65, 0], [0.225, 0.6], [0, 0.6]]);
    }
}
