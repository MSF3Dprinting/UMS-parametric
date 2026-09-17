// =====================================================================
//  UMS V1 — lib/ums_pole_lib.scad                                  ST-4
//  The vertical pole clip: the one back part that prints standing.
//
//  Requires uh_core, uh_shapes, ums_iface and ums_hook_lib.
//
//  WHY STANDING
//    Its cradle axis is already vertical in use, so standing puts every
//    face of the clip on a vertical wall and the bore becomes a vertical
//    hole. Measured on V1's Vertical attachment 25: 434 mm2 unsupported
//    standing, 713 flat, 999 on its side. The hooks are the other way
//    round, which is why the two share a rail and nothing else.
//
//    Standing means layers stack along z, so the detent membrane has to
//    bend about a horizontal axis in x: ums_rail_cutters(up = "z") turns
//    the sealed cavity a quarter turn to suit.
//
//  FRAME as everywhere else: y = 0 is the rail root plane, the pole sits
//  at +Y, z = 0 is the bottom of the rail's full section.
// =====================================================================

_ums_pole_requires =
    assert(!is_undef(UMS_HOOK_VERSION), "ums_pole_lib.scad: include lib/ums_hook_lib.scad first") 1;

UMS_POLE_VERSION = "0.1.0";

UMS_POLE_WALL     = 3.50;   // V1's clip wall, thinner than a hook's
UMS_POLE_STANDOFF = 8.80;   // rail root plane to the near side of the bore
UMS_POLE_WRAP     = 200.0;  // degrees of material: the arms pass the equator
UMS_TIE_N         = 2;      // tie grooves up the clip
UMS_TIE_W         = 6.00;   // groove height
UMS_TIE_T         = 2.00;   // groove depth into the arms
UMS_TIE_SLOT_T    = 3.00;   // slot through the spine, so a tie can cross it

function ums_pole_ri(pole_d, clr = 0) = pole_d / 2 + clr;
function ums_pole_ro(pole_d, clr = 0, wall = UMS_POLE_WALL) =
    ums_pole_ri(pole_d, clr) + wall;
function ums_pole_yc(pole_d, clr = 0, standoff = UMS_POLE_STANDOFF) =
    standoff + ums_pole_ri(pole_d, clr);

// Spine width where it meets the arms, at the plane the bore is tangent to
function ums_pole_spine_w(pole_d, clr = 0, wall = UMS_POLE_WALL) =
    let(ri = ums_pole_ri(pole_d, clr), ro = ums_pole_ro(pole_d, clr, wall))
    2 * sqrt(ro * ro - ri * ri);

// Grooves have to clear each other: the cutter is w + 2t tall plus a
// millimetre of overshoot at each end, and touching cutters leave degenerate
// edges rather than a clean part.
function ums_tie_pitch_min(w = UMS_TIE_W, t = UMS_TIE_T) = w + 2 * t + 2.5;
function ums_tie_n_fits(len, n = UMS_TIE_N, w = UMS_TIE_W, t = UMS_TIE_T) =
    min(n, max(0, floor(len / ums_tie_pitch_min(w, t)) - 1));

// How far the arms have to spread to take the pole: the mouth is narrower
// than the pole by this much, which is the snap
function ums_pole_snap(pole_d, clr = 0, wrap = UMS_POLE_WRAP) =
    let(ri = ums_pole_ri(pole_d, clr))
    2 * ri * (1 - cos(wrap / 2 - 90));

// Section across the arm wall, chamfered top and bottom for the bed
module _ums_pole_sect2d(ri, ro, z0, z1, ch) {
    c = min(ch, (ro - ri) / 2, (z1 - z0) / 2);
    translate([ri, z0])
        polygon([[0, c], [c, 0], [ro - ri - c, 0], [ro - ri, c],
                 [ro - ri, z1 - z0 - c], [ro - ri - c, z1 - z0],
                 [c, z1 - z0], [0, z1 - z0 - c]]);
}

// The cradle: a revolve about the pole axis, so the C is never hulled shut
// and the bed chamfer falls out of the section.
module ums_pole_cradle(pole_d, clr = 0, wall = UMS_POLE_WALL,
                       wrap = UMS_POLE_WRAP, z0 = 0, z1 = UMS_LEN,
                       ch = UMS_EDGE_CH) {
    rotate([0, 0, 270 - wrap / 2]) rotate_extrude(angle = wrap)
        _ums_pole_sect2d(ums_pole_ri(pole_d, clr), ums_pole_ro(pole_d, clr, wall),
                         z0, z1, ch);
}

// Tie grooves round the outside of the arms, and a slot through the spine at
// the same height so a tie can cross from one arm to the other behind the
// pole. Printed standing the slot is a horizontal hole, so it is peaked.
module ums_pole_ties(pole_d, clr = 0, wall = UMS_POLE_WALL, wrap = UMS_POLE_WRAP,
                     z0 = 0, z1 = UMS_LEN, n = UMS_TIE_N, w = UMS_TIE_W,
                     t = UMS_TIE_T, slot_t = UMS_TIE_SLOT_T,
                     standoff = UMS_POLE_STANDOFF, plate_t = UMS_PLATE_T,
                     mo = 60) {
    ro = ums_pole_ro(pole_d, clr, wall);
    yc = ums_pole_yc(pole_d, clr, standoff);
    nn = ums_tie_n_fits(z1 - z0, n, w, t);
    for (i = [0:nn - 1]) {
        zc = z0 + (z1 - z0) * (i + 1) / (nn + 1) - w / 2;
        // groove round the outside of the arms, 45 deg lead-in top and bottom
        translate([0, yc, 0]) rotate([0, 0, 270 - wrap / 2 - 4])
            rotate_extrude(angle = wrap + 8)
                polygon([[ro + 1, zc - t - 1], [ro - t, zc], [ro - t, zc + w],
                         [ro + 1, zc + w + t + 1]]);
        // No separate tie slot is needed: the groove is a full revolve, so
        // where it passes the back of the clip it cuts through the spine as
        // well, and the channel is continuous all the way round. The spine is
        // still joined above and below the groove.
    }
}

// Plate, spine, cradle and ties. Kept separate from ums_back_body because the
// clip is prismatic in z, not in x: it is extruded up the way it prints.
// Plate and spine are extruded separately because each on its own is convex
// and their union is not - uh_chamfered_extrude hulls between levels.
module ums_pole_clip(pole_d = 25, clr = 0, wall = UMS_POLE_WALL,
                     wrap = UMS_POLE_WRAP, standoff = UMS_POLE_STANDOFF,
                     rail_len = UMS_LEN, plate_t = UMS_PLATE_T,
                     w = UMS_PLATE_W, ch = UMS_EDGE_CH, mo = 60,
                     ties = UMS_TIE_N, tie_w = UMS_TIE_W, tie_t = UMS_TIE_T,
                     slot_t = UMS_TIE_SLOT_T) {
    sw = ums_pole_spine_w(pole_d, clr, wall);
    yc = ums_pole_yc(pole_d, clr, standoff);
    difference() {
        union() {
            uh_chamfered_extrude(rail_len, ch, ch, mo)
                translate([-w / 2, 0]) square([w, plate_t]);
            uh_chamfered_extrude(rail_len, ch, ch, mo)
                translate([-sw / 2, 0]) square([sw, standoff + 0.5]);
            translate([0, yc, 0])
                ums_pole_cradle(pole_d, clr, wall, wrap, 0, rail_len, ch);
        }
        if (ums_tie_n_fits(rail_len, ties, tie_w, tie_t) > 0)
            ums_pole_ties(pole_d, clr, wall, wrap, 0, rail_len, ties, tie_w,
                          tie_t, slot_t, standoff, plate_t, mo);
    }
}
