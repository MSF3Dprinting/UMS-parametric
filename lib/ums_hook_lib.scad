// =====================================================================
//  UMS V1 — lib/ums_hook_lib.scad                                  ST-2
//  The back part itself: plate, hook, and the flat screw plate.
//
//  Requires lib/uh_core.scad, lib/uh_shapes.scad and lib/ums_iface.scad.
//
//  FRAME (design plan section 6, unchanged from ST-1)
//    y = 0   front face of the plate, which is the rail's root plane.
//            The rail runs to -Y; the plate and the tube sit at +Y.
//    z = 0   bottom of the rail's full section, +Z up in use.
//    x = 0   the centreline. The part is 31 wide, x = -15.5 .. 15.5.
//
//  PRINT ORIENTATION
//    Hooks lie on their side: +X is up on the bed, so the bore stands
//    vertical and every face of the hook is a vertical wall. The whole
//    plate-and-hook body is therefore one 2D profile in (y, z) extruded
//    along X, with a bed chamfer at each end of that extrusion.
//
//  WALL SHELL (the 0.05 cavity)
//    A hair-thin cavity is laid down the middle of the hook's wall,
//    following the full length of the arc and stopping short of the ends
//    and the two side faces. It is thinner than one extrusion, so it adds
//    no real void; what it does is force the slicer to lay perimeters
//    either side of it, so the hook comes out with solid walls even when
//    somebody slices it at 10% infill. It is a safety net against a
//    slicing mistake, not a structural feature.
// =====================================================================

_ums_hook_requires =
    assert(!is_undef(UMS_IFACE_VERSION), "ums_hook_lib.scad: include lib/ums_iface.scad first")
    assert(!is_undef(UH_SHAPES_VERSION) || true, "") 1;

UMS_HOOK_VERSION = "0.1.0";

UMS_WALL_T      = 3.80;   // hook wall, same as the plate: V1 relies on both
UMS_EDGE_CH     = 0.60;   // chamfer where the part meets the bed
UMS_TIP_R       = 1.50;   // radius on the hook tip
UMS_RAIL_CLEAR  = 30.00;  // gap between the hook and the top of the rail
UMS_PLATE_TAIL  = 4.00;   // plate carried on below the rail
UMS_SHELL_GAP   = 0.15;   // wall shell thickness. PrusaSlicer fills cracks
                          // narrower than twice its slice gap closing radius,
                          // which defaults to 0.049, so anything under about
                          // 0.098 is closed up before perimeters are generated
                          // and the shell has no effect at all
UMS_SHELL_END   = 3.00;   // shell held back from each free end of the run
UMS_SHELL_SIDE  = 2.00;   // shell held back from each side face

// Support block and strap, measured off V1's Hook with support
UMS_SUP_DEPTH   = 17.00;  // block face, from the rail root plane
UMS_SUP_LEN     = 36.00;  // how far it runs down the plate
UMS_SUP_W       = 31.00;  // full plate width, so it lands on the bed with the
                          // plate. V1's is 29, which leaves its underside
                          // floating 1 mm over the bed once the part is on its
                          // side - 438 mm2 of it, and nothing to print it on
UMS_SUP_DROP    = 19.00;  // top of the block, below the bottom of the rail
UMS_NOTCH_D     = 20.00;  // half round groove for the second tube
UMS_STRAP_W     = 8.00;   // strap channel height
UMS_STRAP_T     = 1.00;   // strap channel depth into the front face
UMS_HOOK2_GAP   = 12.00;  // clear air between the two hooks

// ---------------------------------------------------------------------
//  Derived
// ---------------------------------------------------------------------

function ums_bore_r(tube_d, tube_clr = 0) = tube_d / 2 + tube_clr;
function ums_hook_ro(tube_d, tube_clr = 0, wall = UMS_WALL_T) =
    ums_bore_r(tube_d, tube_clr) + wall;

// Tube centre: the bore is tangent to the back face of the plate, which is
// what puts the hook's own back face on the rail root plane.
function ums_hook_yc(tube_d, tube_clr = 0, plate_t = UMS_PLATE_T) =
    plate_t + ums_bore_r(tube_d, tube_clr);
function ums_hook_zc(rail_len = UMS_LEN, tube_d = 32, tube_clr = 0,
                     wall = UMS_WALL_T, clear = UMS_RAIL_CLEAR) =
    rail_len + clear + ums_hook_ro(tube_d, tube_clr, wall);

// The plate is carried half a millimetre past the tube centre so that it
// overlaps the hook instead of meeting it tangentially, which would leave a
// degenerate edge in the union. At that height the hook's own wall is within
// 0.01 of the plate's faces, so nothing shows.
function ums_plate_top(rail_len, tube_d, tube_clr, wall, clear, attach,
                      head_d = 10) =
    attach == "hook" ? ums_hook_zc(rail_len, tube_d, tube_clr, wall, clear) + 0.5
                     : rail_len + ums_screw_margin(head_d);
// Drop from the first bore centre to the second
function ums_hook2_drop(tube_d, tube_d2, tube_clr = 0, wall = UMS_WALL_T,
                        gap = UMS_HOOK2_GAP) =
    ums_hook_ro(tube_d, tube_clr, wall) + ums_hook_ro(tube_d2, tube_clr, wall) + gap;

function ums_sup_top(drop = UMS_SUP_DROP) = -drop;
function ums_sup_bot(drop = UMS_SUP_DROP, len = UMS_SUP_LEN) = -drop - len;

// The plate has to reach whatever hangs off it: the tail, a second hook, or
// the support block, whichever goes lowest.
function ums_plate_bot(tail = UMS_PLATE_TAIL, attach = "hook", head_d = 10,
                       zc2 = 0, sup = false, drop = UMS_SUP_DROP,
                       sup_len = UMS_SUP_LEN) =
    attach != "hook" ? -ums_screw_margin(head_d)
                     : min(-tail,
                           zc2 != 0 ? zc2 - 2 : -tail,
                           sup ? ums_sup_bot(drop, sup_len) : -tail);

// The screws sit clear of the rail, above and below it, for two reasons: the
// rail's tip skin is the detent membrane and a screw head would break into the
// sealed cavity behind it, and spreading them the length of the plate is what
// carries the moment of a device hanging off the front.
function ums_screw_margin(head_d = 10) = head_d + 4;
function ums_screw_pitch(rail_len, head_d = 10) = rail_len + ums_screw_margin(head_d);

// ---------------------------------------------------------------------
//  2D, in the (y, z) plane
// ---------------------------------------------------------------------

// Sector from angle s to e, measured from +Y towards +Z
module _ums_wedge2d(s, e, r) {
    n = max(3, ceil((e - s) / 6));
    polygon(concat([[0, 0]],
                   [for (i = [0:n]) let(a = s + (e - s) * i / n) [r * cos(a), r * sin(a)]]));
}

// Rectangle across the wall, chamfered at both ends of the width, drawn in
// the (radial, axial) plane of the revolve
module _ums_wall_rect2d(r_i, r_o, w, ch) {
    t = r_o - r_i;
    c = min(ch, t / 2, w / 2);
    translate([r_i, 0])
        polygon([[0, c], [c, 0], [t - c, 0], [t, c],
                 [t, w - c], [t - c, w], [c, w], [0, w - c]]);
}

// Section of the wall shell: a hair-wide slot brought to a point at each end
// of the width, so that even this void roofs itself when the part is on its
// side. Nothing here is ever bridged - the gap is thinner than one extrusion.
module _ums_shell_sect2d(gap, w) {
    c = gap / 2;
    polygon([[0, c], [c, 0], [gap, c], [gap, w - c], [c, w], [0, w - c]]);
}

// The plate outline, in (y, z)
module ums_plate2d(plate_t, z0, z1) { translate([0, z0]) square([plate_t, z1 - z0]); }

// ---------------------------------------------------------------------
//  3D
// ---------------------------------------------------------------------

// Extrude a CONVEX (y, z) outline across the width, chamfered at both side
// faces because one of them is the bed. Convex only: uh_chamfered_extrude
// hulls between levels, which would fill the C of a hook.
module ums_across_x(w = UMS_PLATE_W, ch = UMS_EDGE_CH, mo = 60) {
    translate([-w / 2, 0, 0]) rotate([90, 0, 90])
        uh_chamfered_extrude(w, ch, ch, mo) children();
}

// The hook: a revolve about the tube axis. The chamfer at each side face
// then falls straight out of the section, and the C is never hulled shut.
// `over` carries the arc a few degrees past the plate so the two solids
// overlap instead of ending flush, which otherwise leaves sliver facets along
// the join. Three degrees puts the end 13 microns inside the plate.
module ums_hook3d(r_i, r_o, a_tip = -45, w = UMS_PLATE_W, ch = UMS_EDGE_CH,
                  over = 0) {
    translate([-w / 2, 0, 0]) rotate([0, 90, 0]) rotate([0, 0, a_tip + 90])
        rotate_extrude(angle = 180 + over - a_tip) _ums_wall_rect2d(r_i, r_o, w, ch);
}

// Rounded cap on the free end of the hook
module ums_hook_tip3d(r_i, r_o, a_tip, w = UMS_PLATE_W, ch = UMS_EDGE_CH, mo = 60) {
    r_m = (r_i + r_o) / 2;
    // seated a degree inside the end of the arc so the two solids overlap
    // rather than meeting tangentially, which leaves a degenerate edge
    a   = a_tip + 1;
    translate([-w / 2, r_m * cos(a), r_m * sin(a)]) rotate([0, 90, 0])
        uh_chamfered_extrude(w, ch, ch, mo) circle(r = (r_o - r_i) / 2);
}

// Plate, hook and tip, positioned in the part frame
module ums_back_body(attach = "hook", tube_d = 32, tube_clr = 0,
                     wall = UMS_WALL_T, plate_t = UMS_PLATE_T,
                     rail_len = UMS_LEN, clear = UMS_RAIL_CLEAR,
                     tail = UMS_PLATE_TAIL, a_tip = -45, tip_r = UMS_TIP_R,
                     w = UMS_PLATE_W, ch = UMS_EDGE_CH, mo = 60, head_d = 10,
                     tube_d2 = 0, drop2 = 0, support = false,
                     sup_depth = UMS_SUP_DEPTH, sup_len = UMS_SUP_LEN,
                     sup_drop = UMS_SUP_DROP, sup_w = UMS_SUP_W,
                     notch_d = UMS_NOTCH_D) {
    r_i = ums_bore_r(tube_d, tube_clr);
    r_o = ums_hook_ro(tube_d, tube_clr, wall);
    yc  = ums_hook_yc(tube_d, tube_clr, plate_t);
    zc  = ums_hook_zc(rail_len, tube_d, tube_clr, wall, clear);
    two = attach == "hook" && tube_d2 > 0;
    dr  = two ? uh_auto(drop2, ums_hook2_drop(tube_d, tube_d2, tube_clr, wall)) : 0;
    zc2 = two ? zc - dr : 0;
    union() {
        ums_across_x(w, ch, mo)
            ums_plate2d(plate_t,
                        ums_plate_bot(tail, attach, head_d, zc2, support,
                                      sup_drop, sup_len),
                        ums_plate_top(rail_len, tube_d, tube_clr, wall, clear,
                                      attach, head_d));
        if (attach == "hook") {
            translate([0, yc, zc]) ums_hook3d(r_i, r_o, a_tip, w, ch);
            if (tip_r > 0)
                translate([0, yc, zc]) ums_hook_tip3d(r_i, r_o, a_tip, w, ch, mo);
            if (two) {
                r_i2 = ums_bore_r(tube_d2, tube_clr);
                r_o2 = ums_hook_ro(tube_d2, tube_clr, wall);
                yc2  = ums_hook_yc(tube_d2, tube_clr, plate_t);
                translate([0, yc2, zc2]) ums_hook3d(r_i2, r_o2, a_tip, w, ch, 3);
                if (tip_r > 0)
                    translate([0, yc2, zc2])
                        ums_hook_tip3d(r_i2, r_o2, a_tip, w, ch, mo);
            }
            if (support)
                ums_support_block(sup_depth, sup_len, sup_drop, sup_w, notch_d,
                                  ch, mo);
        }
    }
}

// The wall shell: the same revolve, a hair thick, held back from both ends of
// the arc and from both side faces.
module ums_wall_shell(tube_d = 32, tube_clr = 0, wall = UMS_WALL_T,
                      plate_t = UMS_PLATE_T, rail_len = UMS_LEN,
                      clear = UMS_RAIL_CLEAR, a_tip = -45,
                      gap = UMS_SHELL_GAP, end_margin = UMS_SHELL_END,
                      side = UMS_SHELL_SIDE, w = UMS_PLATE_W, drop = 0) {
    ums_wall_shell_at(ums_bore_r(tube_d, tube_clr),
                      ums_hook_ro(tube_d, tube_clr, wall),
                      ums_hook_yc(tube_d, tube_clr, plate_t),
                      ums_hook_zc(rail_len, tube_d, tube_clr, wall, clear) - drop,
                      a_tip, gap, end_margin, side, w);
}

// The shell on a hook whose bore is given directly, so a second hook on the
// same plate gets one as well.
//
// It is held back from the free tip, but carried a couple of degrees PAST the
// plate, because the plate is the same wall continuing straight: at the tube
// centre the hook's wall spans exactly the plate's own faces, so the two runs
// meet there and the shell is continuous from the tip of the hook to the foot
// of the plate.
module ums_wall_shell_at(r_i, r_o, yc, zc, a_tip = -45, gap = UMS_SHELL_GAP,
                         end_margin = UMS_SHELL_END, side = UMS_SHELL_SIDE,
                         w = UMS_PLATE_W, over = 4) {
    r_m = (r_i + r_o) / 2;
    ws  = w - 2 * side;
    da  = end_margin / r_m * 180 / PI;
    translate([0, yc, zc]) translate([-ws / 2, 0, 0]) rotate([0, 90, 0])
        rotate([0, 0, a_tip + da + 90])
            rotate_extrude(angle = 180 + over - a_tip - da)
                translate([r_m - gap / 2, 0]) _ums_shell_sect2d(gap, ws);
}

// The same shell carried down the plate, on the middle of its thickness. Its
// section comes to a point at each side face for the same reason the hook's
// does: laid on its side, that is the print's vertical.
// `up` is which way the part stands on the bed, and it decides which end of
// the slab has to come to a point: the end that faces up is a ceiling, however
// thin it is. x is a hook or plate on its side, z is a part standing up.
module ums_plate_shell(plate_t = UMS_PLATE_T, z0 = 0, z1 = 100,
                       gap = UMS_SHELL_GAP, side = UMS_SHELL_SIDE,
                       w = UMS_PLATE_W, up = "x") {
    ws = w - 2 * side;
    c  = gap / 2;
    y0 = plate_t / 2 - gap / 2;
    if (up == "z")
        translate([-ws / 2, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = ws)
            polygon([[y0, z0], [y0 + gap, z0], [y0 + gap, z1 - c],
                     [y0 + gap / 2, z1], [y0, z1 - c]]);
    else
        translate([0, 0, z0]) linear_extrude(height = z1 - z0)
            polygon([[-ws / 2, y0 + c], [-ws / 2 + c, y0], [ws / 2 - c, y0],
                     [ws / 2, y0 + c], [ws / 2 - c, y0 + gap], [-ws / 2 + c, y0 + gap]]);
}

// Support block: a prism across the width with a half round groove in its
// face for a second tube, held by a strap. Printed on its side every surface
// of it is a vertical wall, bar the groove, which is teardropped.
module ums_support_block(depth = UMS_SUP_DEPTH, len = UMS_SUP_LEN,
                         drop = UMS_SUP_DROP, w = UMS_SUP_W,
                         notch_d = UMS_NOTCH_D, ch = UMS_EDGE_CH, mo = 60) {
    difference() {
        ums_across_x(w, ch, mo)
            translate([0, ums_sup_bot(drop, len)]) square([depth, len]);
        if (notch_d > 0)
            translate([0, depth, ums_sup_bot(drop, len) - 1])
                linear_extrude(height = len + 2)
                    rotate(-90) uh_teardrop2d(notch_d, mo, false);
    }
}

// Strap channel: across the front face, and optionally down both side faces
// and across the back, so a tie is held all the way round the section instead
// of only on the front. Every run has a 45 deg lead-in top and bottom so the
// tie drops in. Cut after everything else.
//
// Printed on its side, the groove in the upper face is open and the groove in
// the bed face is a bridge, spanning the width of the channel. That is
// deliberate and accepted; check_overhang --bridge-span reports it as a bridge
// rather than as an overhang, as long as it stays short.
module ums_strap_channel(z0, w = UMS_STRAP_W, t = UMS_STRAP_T,
                         plate_w = UMS_PLATE_W, sides = true, back = false,
                         depth = 0) {
    d = uh_auto(depth, UMS_PLATE_T + 1);
    // front face
    translate([-plate_w / 2 - 1, 0, 0]) rotate([90, 0, 90])
        linear_extrude(height = plate_w + 2)
            _ums_strap_sect2d(z0, w, t, -1);
    // both side faces, run from in front of the part to the far side of it
    if (sides)
        for (sgn = [-1, 1])
            translate([0, d, 0]) rotate([90, 0, 0]) linear_extrude(height = d + 1)
                translate([sgn * plate_w / 2, 0]) scale([-sgn, 1])
                    _ums_strap_sect2d(z0, w, t, -1);
    // back face, for a tie that wraps a plate rather than a tube
    if (back)
        translate([-plate_w / 2 - 1, 0, 0]) rotate([90, 0, 90])
            linear_extrude(height = plate_w + 2)
                translate([d, 0]) scale([-1, 1])
                    _ums_strap_sect2d(z0, w, t, -1);
}

// Channel section: t deep, w wide, opening toward -a, lead-ins at 45 deg
module _ums_strap_sect2d(z0, w, t, out = -1) {
    polygon([[out, z0 - t], [t, z0], [t, z0 + w], [out, z0 + w + t]]);
}

// Two screws in a vertical column, for the flat plate. Countersunk on the
// front face so nothing stands proud where a front part slides.
module ums_plate_screws(d = 5, n = 2, pitch = 0, rail_len = UMS_LEN,
                        plate_t = UMS_PLATE_T, style = "countersink",
                        head_d = 0, mo = 60) {
    hd = uh_auto(head_d, 2 * d);
    p  = uh_auto(pitch, ums_screw_pitch(rail_len, hd) / max(1, n - 1));
    z0 = rail_len / 2 - (n - 1) * p / 2;
    // uh_screw_hole puts the head at the far end of its own frame, so the
    // cutter enters at the back of the plate and the head lands on the front.
    // The rotate turns the teardrop's apex to +X, which is up on the bed.
    for (i = [0:n - 1])
        translate([0, plate_t, z0 + i * p]) rotate([0, 90, 0])
            uh_screw_hole(d, plate_t, style, head_d, 3, 90, 0, 0, mo);
}
