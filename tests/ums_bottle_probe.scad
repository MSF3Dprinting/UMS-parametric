// =====================================================================
//  UMS V1 — tests/ums_bottle_probe.scad                            ST-7
//  Does the bottle holder take a real back part? Intersects it with a
//  rail written out in literal V1 numbers, seated where the holder's own
//  socket seats it. probe must be EMPTY; snap is the detent alone.
// =====================================================================
part = "probe"; // [probe, snap]
seat_z = 82.5;  // holder's seat height: part height minus top_margin
$fa = 2; $fs = 0.4;
use <../ums_bottle_holder.scad>

if (part == "probe") intersection() { bottle_holder(); v1_rail(false); }
else                 intersection() { bottle_holder(); v1_rail(true); }

module v1_rail(with_bump) {
    translate([0, 0, seat_z - 48]) {
        difference() {
            linear_extrude(height = 48)
                polygon([[-13.017, 0.01], [-13.017, 0], [-15.5, -2.483], [-15.5, -4],
                         [ 15.5, -4], [ 15.5, -2.483], [ 13.017, 0], [13.017, 0.01]]);
            translate([0, 0, 48]) rotate([45, 0, 0])
                translate([-60, -60, 0]) cube([120, 120, 120]);
        }
        if (with_bump)
            translate([0, -4, 48 - 4 - 27]) rotate([90, 0, 0])
                rotate_extrude() polygon([[0, 0], [1.65, 0], [0.225, 0.6], [0, 0.6]]);
    }
}
