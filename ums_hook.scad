// =====================================================================
//  UMS V1 — ums_hook.scad                                          ST-2
//  One parametric UMS back part: a hook for any tube from 15 to 50, or a
//  flat plate on two screws. Carries the V1 rail, so every UMS front part
//  fits it.
//
//  Prints on its side, no supports, no re-orientation. Lay it on either
//  31 mm face. PETG, white or another light colour, 0.2 mm layers,
//  4 perimeters, brim.
// =====================================================================

/* [Part] */
// What the back part hangs on
attach = "hook"; // [hook, plate, pole]
// Diameter of the tube it hangs on
tube_d = 32; // [15:0.5:50]
// Extra clearance in the bore. V1 uses none and lets print tolerance do it
tube_clr = 0; // [0:0.05:0.6]

/* [Print] */
// Largest overhang, in degrees from vertical
max_overhang = 60; // [45:5:60]
quality = "fine"; // [draft, normal, fine]
// Emit in the print orientation, for the overhang checker
orient = "use"; // [use, print]

/* [Fit] */
// Clearance between front and back part, on every mating face
clr = 0.20; // [0:0.05:0.6]
// Snap detent on a sealed internal cavity
spring = true;
// Membrane over the cavity, and the main lever on snap force. Two perimeters is
// the floor: at 0.6 a 0.4 nozzle lays one perimeter and fills the rest, which
// shows on the face
memb_t = 0.9; // [0.4:0.05:2]
// Cavity depth
cav_d = 1.4; // [0.8:0.1:3]
// Bump height, 0 = auto
bump_h = 0; // [0:0.05:1.5]

/* [Pole clip] */
// Diameter of the vertical pole the clip snaps onto
pole_d = 25; // [15:0.5:50]
pole_clr = 0; // [0:0.05:0.6]
// Clip wall. V1 uses 3.5 here, thinner than a hook's
pole_wall = 3.5; // [2:0.1:8]
// Degrees of material. Over 180 the arms pass the equator and it snaps on
pole_wrap = 200; // [150:5:260]
// Rail root plane to the near side of the bore
pole_standoff = 8.8; // [4:0.1:30]
// Tie grooves up the clip
tie_n = 2; // [0:1:5]
tie_w = 6; // [3:0.5:14]
tie_t = 2; // [0.5:0.1:5]

/* [Second hook] */
// A second, smaller bore below the first. 0 = none. V1's double hook is 32 + 19
tube_d2 = 0; // [0:0.5:50]
// Centre to centre. 0 = auto, which leaves 12 of air between the two hooks
hook2_drop = 0; // [0:0.5:120]

/* [Support block] */
// A block below the rail with a half round groove for a second tube, held by
// a strap. V1 uses it to steady a hook on a bed backrest
support = false;
// Groove diameter
notch_d = 20; // [0:0.5:40]
// Block face, measured from the rail root plane
sup_depth = 17; // [6:0.5:40]
sup_len = 36; // [10:1:80]
// Top of the block, below the bottom of the rail
sup_drop = 19; // [0:1:60]
// Block width. Full width lands it on the bed with the plate; anything
// narrower leaves its underside floating and needs support
sup_w = 31; // [10:0.5:31]

/* [Strap] */
// Channel across the front face for a zip tie
strap = false;
// Tie width the channel has to clear
strap_tie_w = 5; // [2:0.5:12]
strap_w = 8; // [3:0.5:20]
strap_t = 1.0; // [0.4:0.1:3]
// Carry the channel down both side faces as well, so the tie is held all the
// way round. The groove in the bed face prints as a short bridge
strap_sides = true;
// Carry it across the back face too, for a tie that wraps a bare plate
strap_back = false;
// 0 = auto, centred on the support block
strap_z = 0; // [-200:1:200]

/* [Hook] */
// Wall of the hook. Matches the plate, which is what lands the hook's back
// face exactly on the rail root plane
wall_t = 3.8; // [2:0.1:8]
// Angle of the hook tip, measured up from straight ahead. -45 wraps 225 deg
tip_angle = -45; // [-80:5:0]
// Radius on the tip
tip_r = 1.5; // [0:0.1:4]
// Gap between the hook and the top of the rail
rail_clear = 30; // [10:1:80]
// Plate carried on below the rail
plate_tail = 4; // [0:0.5:40]

/* [Wall shell] */
// Hair-thin cavity down the middle of the hook wall. It is thinner than one
// extrusion, so it prints as nothing; what it does is force the slicer to
// lay perimeters either side of it, so the hook has solid walls even if it
// is sliced at low infill by mistake
shell = true;
// PrusaSlicer closes cracks narrower than twice its slice gap closing radius,
// 0.049 by default, so anything under about 0.098 is filled before perimeters
// are generated and the shell does nothing. 0.15 clears that with margin
shell_gap = 0.15; // [0.05:0.01:0.5]
// Held back from each end of the arc
shell_end = 3; // [1:0.5:10]
// Held back from each side face
shell_side = 2; // [1:0.5:6]

/* [Rail] */
// Interface length. 48 is the standard: it is what the sealed detent cavity
// needs to sit centred on the bump. V1's own rail is 38 and still mates
rail_len = 48; // [30:0.5:120]

/* [Plate mode] */
screw_d = 5; // [3:0.5:8]
screw_n = 2; // [1:1:4]
// 0 = auto
screw_pitch = 0; // [0:1:80]
screw_style = "countersink"; // [plain, countersink, counterbore]

/* [Hidden] */
include <lib/uh_core.scad>
include <lib/uh_shapes.scad>
include <lib/ums_iface.scad>
include <lib/ums_hook_lib.scad>
include <lib/ums_pole_lib.scad>

$fa = uh_quality(quality)[0];
$fs = uh_quality(quality)[1];

MO     = max_overhang;
BUMP_H = ums_bump_h(spring, bump_h, "cavity");
// Hooks and plates lie on their side, the pole clip stands up
UP     = attach == "pole" ? "z" : "x";

ums_iface_selftest();
ums_iface_checks(rail_len, clr, true, spring, MO, UMS_SPRING_T, UMS_SPRING_TRAVEL,
                 BUMP_H, UMS_BUMP_D, "z", UMS_SPRING_GAP, "cavity", memb_t, cav_d);
checks();

emit() back_part();

// A hook or a plate lies on its side, so +X is up on the bed and the model has
// to be turned for the checker. The pole clip already stands the way it prints.
module emit() {
    if (orient == "print" && UP == "x") rotate([0, -90, 0]) children();
    else children();
}

module back_part() {
    difference() {
        union() {
            if (attach == "pole")
                ums_pole_clip(pole_d, pole_clr, pole_wall, pole_wrap, pole_standoff,
                              rail_len, UMS_PLATE_T, UMS_PLATE_W, UMS_EDGE_CH, MO,
                              tie_n, tie_w, tie_t);
            if (attach != "pole")
            ums_back_body(attach, tube_d, tube_clr, wall_t, UMS_PLATE_T, rail_len,
                          rail_clear, plate_tail, tip_angle, tip_r, UMS_PLATE_W,
                          UMS_EDGE_CH, MO, 2 * screw_d, tube_d2, hook2_drop,
                          support, sup_depth, sup_len, sup_drop, sup_w, notch_d);
            ums_rail(rail_len, clr, true, UH_EPS, BUMP_H);
        }
        ums_rail_cutters(rail_len, clr, spring, MO, UMS_SPRING_T, UMS_SPRING_TRAVEL,
                         UMS_SPRING_GAP, UMS_SPRING_TIP, UMS_BUMP_D, "left", "z",
                         "cavity", memb_t, cav_d, BUMP_H, UP);
        if (shell && attach == "hook") {
            // down the plate, from just above its foot to the top hook's centre
            ums_plate_shell(UMS_PLATE_T,
                            ums_plate_bot(plate_tail, attach, 2 * screw_d,
                                          tube_d2 > 0
                                          ? ums_hook_zc(rail_len, tube_d, tube_clr,
                                                        wall_t, rail_clear)
                                            - uh_auto(hook2_drop,
                                                      ums_hook2_drop(tube_d, tube_d2,
                                                                     tube_clr, wall_t))
                                          : 0,
                                          support, sup_drop, sup_len) + shell_end,
                            ums_hook_zc(rail_len, tube_d, tube_clr, wall_t, rail_clear),
                            shell_gap, shell_side, UMS_PLATE_W);
            ums_wall_shell(tube_d, tube_clr, wall_t, UMS_PLATE_T, rail_len,
                           rail_clear, tip_angle, shell_gap, shell_end, shell_side,
                           UMS_PLATE_W);
            // the second hook gets one too, on its own bore
            if (tube_d2 > 0)
                ums_wall_shell_at(ums_bore_r(tube_d2, tube_clr),
                                  ums_hook_ro(tube_d2, tube_clr, wall_t),
                                  ums_hook_yc(tube_d2, tube_clr, UMS_PLATE_T),
                                  ums_hook_zc(rail_len, tube_d, tube_clr, wall_t,
                                              rail_clear)
                                  - uh_auto(hook2_drop,
                                            ums_hook2_drop(tube_d, tube_d2, tube_clr,
                                                           wall_t)),
                                  tip_angle, shell_gap, shell_end, shell_side,
                                  UMS_PLATE_W);
        }
        if (strap && attach == "hook")
            ums_strap_channel(uh_auto(strap_z, -sup_drop - sup_len / 2 - strap_w / 2),
                              strap_w, strap_t, UMS_PLATE_W, strap_sides,
                              strap_back, (support ? sup_depth : UMS_PLATE_T) + 1);
        if (attach == "plate")
            ums_plate_screws(screw_d, screw_n, screw_pitch, rail_len, UMS_PLATE_T,
                             screw_style, 0, MO);
    }
}

module checks() {
    assert(tube_d >= 15 && tube_d <= 50, "tube_d is outside the 15-50 range");
    assert(attach != "pole" || (pole_d >= 15 && pole_d <= 50),
        "pole_d is outside the 15-50 range");
    uh_warn(attach != "pole" || pole_wrap > 180,
        str("pole wrap ", pole_wrap, " does not pass the equator, nothing holds it on"));
    uh_warn(attach != "pole" || ums_tie_n_fits(rail_len, tie_n, tie_w, tie_t) == tie_n,
        str("only ", ums_tie_n_fits(rail_len, tie_n, tie_w, tie_t), " tie grooves fit in ",
            rail_len, " at this size; the rest are dropped"));
    uh_warn(attach != "pole" || ums_cav_fits(rail_len, clr, BUMP_H, cav_d, "z"),
        str("standing, the cavity needs about ", ums_cav_room_needed("z"),
            " of rail either side of the bump"));
    assert(wall_t >= 1.2, "hook wall below 1.2");
    uh_warn(uh_approx(wall_t, UMS_PLATE_T, 0.001),
        str("hook wall ", wall_t, " differs from the plate thickness ", UMS_PLATE_T,
            "; the hook's back face no longer lands on the rail root plane"));
    uh_warn(!spring || memb_t >= 0.8,
        str("membrane ", memb_t,
            " is under two perimeters on a 0.4 nozzle and will show on the face"));
    uh_warn(!shell || shell_gap >= 0.12,
        str("wall shell gap ", shell_gap,
            " is at or below what a slicer closes on its own, about 0.098"));
    uh_warn(!shell || shell_gap <= 0.3,
        str("wall shell gap ", shell_gap, " is wide enough to slice as a real void"));
    uh_warn(!shell || shell_side >= 1.5,
        "wall shell runs close to the side faces");
    uh_warn(!strap || strap_w >= strap_tie_w + 1,
        str("strap channel ", strap_w, " is tight for a ", strap_tie_w, " tie"));
    uh_warn(!support || sup_w >= UMS_PLATE_W - 0.001,
        str("support block ", sup_w, " wide is narrower than the ", UMS_PLATE_W,
            " plate, so its underside floats over the bed and needs support"));
    uh_warn(!support || notch_d == 0 || sup_depth - notch_d / 2 >= 3,
        str("support block leaves only ", sup_depth - notch_d / 2,
            " behind the groove"));
    uh_warn(tube_d2 == 0 || tube_d2 <= tube_d,
        "the second bore is larger than the first, which is the wrong way up");
    if (tube_d2 > 0)
        uh_info(str("second hook for tube ", tube_d2, ", centres ",
                    uh_auto(hook2_drop, ums_hook2_drop(tube_d, tube_d2, tube_clr,
                                                       wall_t)), " apart"));
    if (support)
        uh_info(str("support block ", sup_w, " x ", sup_depth, " x ", sup_len,
                    ", groove \u00d8", notch_d, ", ",
                    sup_depth - notch_d / 2, " of block behind it"));
    if (attach == "pole")
        uh_info(str("pole clip for \u00d8", pole_d, ": bore ",
                    2 * ums_pole_ri(pole_d, pole_clr), ", outside ",
                    2 * ums_pole_ro(pole_d, pole_clr, pole_wall), ", wrap ", pole_wrap,
                    " deg, arms spread ", ums_pole_snap(pole_d, pole_clr, pole_wrap),
                    " to take the pole, ", tie_n, " tie grooves"));
    if (attach == "plate")
        uh_info(str("flat plate: ", screw_n, " screws \u00d8", screw_d,
                    " at ", ums_screw_pitch(rail_len, 2 * screw_d) / max(1, screw_n - 1),
                    " pitch, clear of the rail and of the detent cavity"));
    if (attach == "hook")
        uh_info(str("hook for tube ", tube_d, ": bore ", 2 * ums_bore_r(tube_d, tube_clr),
                    ", outside ", 2 * ums_hook_ro(tube_d, tube_clr, wall_t),
                    ", wrap ", 180 - tip_angle, " deg, part ",
                    ums_hook_zc(rail_len, tube_d, tube_clr, wall_t, rail_clear)
                    + ums_hook_ro(tube_d, tube_clr, wall_t) + plate_tail, " tall"));
}
