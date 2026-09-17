// =====================================================================
//  UMS V1 — tests/ums_iface_coupon.scad                            ST-1
//  Verification coupon for lib/ums_iface.scad.
//
//  Parts
//    rail      back-part stub: 31 x 3.8 plate carrying the male rail
//    socket    front-part stub: 40 wide block carrying the female socket
//    mate      both, for the preview image
//    cut       both, sectioned on the centreline, so the interlock shows
//    probe     rail without detent  INTERSECT socket   -> must be EMPTY
//    snap      rail with detent     INTERSECT socket   -> the snap
//              interference, small and deliberate
//    v1probe   rail without detent  INTERSECT a front-part block whose
//              groove is written out in literal numbers measured off the
//              V1 STEP models, independent of the library -> must be EMPTY
//    v1snap    same with the detent  -> the snap interference against V1
//    snap_probe  the bump alone, pushed back by `retract`, against the V1
//              block moved to `zoff` -> empty when the bump has retracted far
//              enough to clear. Bisecting on retract at several zoff values
//              gives the retraction curve, i.e. the click.
//
//  Both coupons print standing on the bed exactly as generated.
// =====================================================================

/* [Coupon] */
part = "rail"; // [rail, socket, mate, cut, cutz, cutx, xray, spread, ghost, onbed, probe, snap, v1probe, v1snap, snap_probe, v1block]
// Largest overhang in degrees from vertical
max_overhang = 60; // [40:5:60]
quality = "fine"; // [draft, normal, fine]

/* [Interface] */
// Interface length, V1 is 38
iface_len = 48; // [20:0.5:120]
// Clearance on every mating face, V1 is 0.20
clr = 0.20; // [0:0.05:0.6]
// Snap detent
detent = true;

/* [Detent spring] */
// Cut the bump free on a spring instead of leaving it rigid
spring = true;
// cavity keeps the outer face closed; the tongues cut an open slot
spring_style = "cavity"; // [cavity, tongue, none]
// Membrane over the cavity
memb_t = 0.6; // [0.4:0.05:1.5]
// Cavity depth
cav_d = 1.4; // [0.8:0.1:3]
// Tongue thickness, the part that bends
spring_t = 1.2; // [0.8:0.1:3]
// Free space behind the tongue
spring_travel = 1.4; // [0.4:0.1:3]
// Slot around the tongue
spring_gap = 0.6; // [0.3:0.1:1.5]
// Tongue carried past the bump
spring_tip = 3.0; // [1:0.5:10]
// Which way the tongue runs: z for parts printed on their side (layers stack
// along x), x for parts printed standing (layers stack along z)
spring_axis = "z"; // [z, x]
// Which side an x tongue is rooted on
spring_side = "left"; // [left, right]
// Emit the part in its print orientation, for the overhang check
orient = "use"; // [use, print]
// Bump height above the tip face, also how far the tongue must retract
// (0 = auto: 0.60 sprung, V1's 1.00 rigid)
bump_h = 0; // [0:0.05:1.5]
// snap_probe only: how far the bump is pushed back into the rail
retract = 0; // [0:0.01:1.5]
// snap_probe only: where the front part sits, 0 = the CAD assembly position,
// -0.20 = seated on the ramp, further down = still sliding on
zoff = 0; // [-40:0.01:2]
// Length of the V1 reference block for v1probe / v1snap (0 = same as iface_len)
v1_len = 0; // [0:0.5:120]

/* [Hidden] */
include <../lib/uh_core.scad>
include <../lib/uh_shapes.scad>
include <../lib/ums_iface.scad>

$fa = uh_quality(quality)[0];
$fs = uh_quality(quality)[1];

MO       = max_overhang;
BODY_W   = 40;                                  // front-part stub width
BODY_T   = UMS_DEPTH + 4;                       // front-part stub thickness
BODY_TOP = 3;                                   // material above the seat

ums_iface_selftest();
BUMP_H = ums_bump_h(spring, bump_h, spring_style);
// Printed on the side: x points up, so rotate -90 about y to check overhangs
module emit() { if (orient == "print") rotate([0, -90, 0]) children(); else children(); }
RAILPART = part != "socket";
ums_iface_checks(iface_len, clr, detent, spring && RAILPART, MO, spring_t,
                 spring_travel, BUMP_H, UMS_BUMP_D, spring_axis, spring_gap,
                 spring_style, memb_t, cav_d);

if      (part == "rail")    emit() coupon_rail(detent);
else if (part == "socket")  emit() coupon_socket(detent);
else if (part == "mate")  { coupon_rail(detent); coupon_socket(detent); }
else if (part == "cut")     difference() {
                                union() { coupon_rail(detent); coupon_socket(detent); }
                                translate([0, -60, -10]) cube([60, 120, 120]);
                            }
else if (part == "probe")   intersection() { coupon_rail(false);   coupon_socket(detent); }
else if (part == "snap")    intersection() { coupon_rail(detent);  coupon_socket(detent); }
else if (part == "v1probe") intersection() { coupon_rail(false);   v1_front_block(); }
else if (part == "v1snap")  intersection() { coupon_rail(detent);  v1_front_block(); }
else if (part == "v1block") v1_front_block();
else if (part == "xray")  { %coupon_rail(detent);
                            ums_rail_cutters(iface_len, clr, spring, MO, spring_t,
                                spring_travel, spring_gap, spring_tip, UMS_BUMP_D,
                                spring_side, spring_axis, spring_style, memb_t,
                                cav_d, BUMP_H); }
else if (part == "cutx")    difference() {
                                coupon_rail(detent);
                                translate([0, -60, -10]) cube([60, 120, 200]);
                            }
else if (part == "ghost")  { coupon_rail(detent); %coupon_socket(detent); }
else if (part == "onbed")  { rotate([0, -90, 0]) coupon_rail(detent);
                             %translate([-40, -45, -UMS_TIP_W / 2 - 0.7])
                                 cube([80, 90, 0.7]); }
else if (part == "spread") { coupon_rail(detent);
                             translate([0, -16, 26]) coupon_socket(detent); }
else if (part == "cutz")    difference() {
                                coupon_rail(detent);
                                translate([-60, -60, 7.2]) cube([120, 120, 120]);
                            }
else if (part == "snap_probe")
    intersection() {
        translate([0, retract, 0]) ums_bump(iface_len, BUMP_H);
        translate([0, 0, zoff]) v1_front_block();
    }

// ---- coupons ---------------------------------------------------------

// Back-part stub: the V1 back plate section with the rail on it.
module coupon_rail(with_detent = true) {
    difference() {
        union() {
            translate([-UMS_PLATE_W / 2, 0, 0])
                cube([UMS_PLATE_W, UMS_PLATE_T, iface_len]);
            ums_rail(iface_len, clr, with_detent, UH_EPS, BUMP_H);
        }
        if (with_detent)
            ums_rail_cutters(iface_len, clr, spring, MO, spring_t, spring_travel,
                             spring_gap, spring_tip, UMS_BUMP_D, spring_side,
                             spring_axis, spring_style, memb_t, cav_d, BUMP_H);
    }
}

// Front-part stub: a blank block with the socket cut into its rear face.
module coupon_socket(with_detent = true) {
    difference() {
        translate([-BODY_W / 2, -clr - BODY_T, 0])
            cube([BODY_W, BODY_T, iface_len + BODY_TOP]);
        ums_socket_cutter(iface_len, clr, with_detent, below = 2);
    }
}

// ---- independent V1 reference ----------------------------------------
// The same front-part stub, but its groove is written out in the numbers
// measured off the V1 STEP models rather than derived by the library.
// If anything in ums_iface.scad drifts, v1probe stops being empty.
// The front part always hangs from the seat, so the reference block is placed
// with its seat on the rail's seat, whatever the two lengths are.
module v1_front_block() {
    vl = v1_len == 0 ? iface_len : v1_len;
    translate([0, 0, iface_len - vl]) difference() {
        translate([-BODY_W / 2, -0.20 - BODY_T, 0])
            cube([BODY_W, BODY_T, vl + BODY_TOP]);
        difference() {
            translate([0, 0, -2])
                linear_extrude(height = vl + 2)
                    polygon([[-13.50,  10.00], [-13.50, -0.20], [-17.50, -4.20],
                             [ 17.50, -4.20], [ 13.50, -0.20], [ 13.50, 10.00]]);
            // seat: in the V1 assembly the front part's ramp is the plane
            // z_assy = y_assy + 62, i.e. z = y + 38.20 in this frame
            translate([0, 0, vl + 0.20]) rotate([45, 0, 0])
                translate([-200, -200, 0]) cube([400, 400, 400]);
        }
        // dimple: 26.58 below the top of the socket floor, 2.30 x 0.70
        translate([0, -4.20, vl - UMS_RAMP - 26.58])
            rotate([90, 0, 0])
                rotate_extrude()
                    polygon([[0, 0], [1.15, 0], [0.30, 0.70], [0, 0.70]]);
    }
}
