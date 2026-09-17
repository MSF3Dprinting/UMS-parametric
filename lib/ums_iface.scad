// =====================================================================
//  UMS V1 — lib/ums_iface.scad                                     ST-1
//  The Universal Mounting System V1 slide interface: the male rail that
//  every back part carries, the female socket that every front part
//  carries, and the snap detent between them.
//
//  Requires lib/uh_core.scad to be included first.
//  OpenSCAD 2021.01 language subset, no libraries.
//
//  MASTER DIMENSIONS
//    Every number in the "V1 master" block was measured off the V1 STEP
//    models (Single hook, Double hook extended, Hook with support,
//    Vertical attachment 20/25, Humidifier bottle holder 49, Pulse
//    oximeter holder, Ultrasound transducer holder). They are identical
//    on all eight parts. Changing them breaks compatibility with every
//    UMS front part in the field - don't.
//
//  FRAME (design plan section 6)
//    y = 0   the rail root plane, i.e. the front face of the back plate.
//            The rail runs to -Y; the back plate and the tube sit at +Y.
//    z = 0   the bottom of the rail's full section; +Z is up in use and
//            on the print bed.
//    x = 0   the centreline.
//    The socket is expressed in the SAME frame, so a front part mated to
//    a back part is a plain overlay with no offset: the socket's mouth
//    plane sits at y = -clr, its floor at y = -clr - UMS_DEPTH. The fit
//    clearance is therefore built into the socket, once, here.
//
//  HOW THE JOINT WORKS
//    * Only the two 45 deg flanks locate the front part. Tip face against
//      floor and shoulder against mouth face both carry clearance.
//    * Vertical load goes through the 45 deg seat ramp at the top of the
//      rail: the front part hangs on it, it does not bottom out.
//    * The detent is deliberately offset by UMS_DETENT_OFF: once the seat
//      is closed the bump sits UMS_DETENT_OFF - clr below the dimple
//      centre and preloads the front part up into the seat. That is what
//      takes the rattle out.
//
//  Public API
//    Masters    UMS_MOUTH_W  UMS_FLOOR_W  UMS_DEPTH  UMS_FLANK  UMS_TIP_W
//               UMS_SEAT  UMS_RAMP  UMS_LEN  UMS_CLR  UMS_PLATE_W
//               UMS_PLATE_T  UMS_DETENT_TOP  UMS_DETENT_OFF  UMS_BUMP_*
//               UMS_DIMPLE_*
//    Functions  ums_socket_half  ums_rail_root_w  ums_rail_flank_h
//               ums_rail_full_h  ums_detent_z  ums_dimple_z
//               ums_socket_body_min_t  ums_detent_fits
//    2D         ums_rail_profile2d  ums_socket_profile2d
//    Spring     ums_spring_root_x  ums_spring_len  ums_spring_travel_needed
//               ums_spring_strain  ums_spring_top_z  ums_spring_fits
//    3D         ums_rail  ums_socket_cutter  ums_rail_cutters  ums_bump
//    Checks     ums_iface_checks  ums_iface_selftest
// =====================================================================

_ums_iface_requires_core =
    assert(!is_undef(UH_CORE_VERSION), "ums_iface.scad: include lib/uh_core.scad first") 1;

UMS_IFACE_VERSION = "0.4.0";

// ---------------------------------------------------------------------
//  V1 master dimensions - measured, not negotiable
// ---------------------------------------------------------------------

UMS_MOUTH_W    = 27.00;   // socket width at the mouth plane
UMS_FLOOR_W    = 35.00;   // socket width at the floor
UMS_DEPTH      = 4.00;    // socket depth = rail height
UMS_FLANK      = 45;      // flank angle, from the depth direction
UMS_TIP_W      = 31.00;   // rail width at the tip face
UMS_SEAT       = 45;      // angle of the seat ramp that carries the load
UMS_RAMP       = 4.00;    // height of that ramp
UMS_LEN        = 38.00;   // V1's own interface length, full section + ramp
UMS_LEN_STD    = 48.00;   // standard length for new parts: what the sealed
                          // detent cavity needs to sit centred on the bump
UMS_CLR        = 0.20;    // clearance on every mating face

UMS_PLATE_W    = 31.00;   // back plate width the rail belongs on
UMS_PLATE_T    = 3.80;    // back plate thickness

UMS_DETENT_TOP = 27.00;   // bump centre below the top of the tip face
UMS_DETENT_OFF = 0.42;    // dimple centre above the bump centre (preload)
UMS_BUMP_D     = 3.30;    // bump diameter at the tip face
UMS_BUMP_H     = 1.00;    // bump height above the tip face
UMS_BUMP_CAP   = 0.45;    // flat on top of the bump
UMS_DIMPLE_D   = 2.30;    // dimple diameter at the socket floor
UMS_DIMPLE_H   = 0.70;    // dimple depth
UMS_DIMPLE_CAP = 0.60;    // flat at the bottom of the dimple

// ---------------------------------------------------------------------
//  Spring detent (v0.2) - not part of V1
//
//  V1's bump is rigid: it stands 1.0 proud of a solid rail, the socket
//  floor clears the rail by clr, so sliding a front part on forces
//  1.0 - clr of interference through the front part's walls. It grips,
//  but the force is whatever the two parts happen to flex.
//
//  Here the bump sits on a tongue cut out of the rail's tip skin, with a
//  pocket behind it, so the bump retracts instead. Printed standing, the
//  tongue's axis lies along X, in the layer plane, and it flexes along Y,
//  parallel to the bed: bending stress runs along the extruded strands and
//  no layer bond is ever loaded in tension. The tongue's underside is a
//  ramp rising at beta from the bottom of the rail, so it is built up off
//  the bed layer by layer - nothing is bridged and nothing is supported.
//  The tongue is deepest at the root and shallowest at the tip, which is
//  the constant-stress cantilever shape, so the strain figure reported by
//  ums_iface_checks is conservative.
// ---------------------------------------------------------------------

UMS_SPRING_T      = 1.20;   // tongue thickness, the part that bends
UMS_SPRING_TRAVEL = 1.40;   // free space behind the tongue
UMS_SPRING_GAP    = 0.60;   // slot above and around the tongue
UMS_SPRING_TIP    = 3.00;   // tongue carried past the bump centre
UMS_SPRING_TOP    = 0.80;   // material above the bump on the tongue
UMS_SPRING_BUMP_C = 0.30;   // clearance between the underside ramp and the bump
UMS_STRAIN_MAX    = 0.012;  // strain PETG takes repeatedly in a snap arm
UMS_BUMP_H_SPRUNG = 0.60;   // bump height for the sealed-cavity spring
UMS_MEMB_T        = 0.90;   // membrane over the cavity: two full perimeters on
                            // a 0.4 nozzle. At 0.6 a slicer lays one perimeter
                            // and fills the rest, which shows on the face
UMS_CAV_D         = 1.40;   // cavity depth, must exceed the retraction
UMS_CAV_EDGE_X    = 2.50;   // rail left either side of the cavity
UMS_CAV_EDGE_Z    = 2.50;   // rail left above and below it
UMS_CAV_L         = 24.00;  // target cavity length along the rail. Lengthened
                            // with the membrane: a thicker membrane over the
                            // same span would be stiffer and strain harder
UMS_CAV_R         = 3.00;   // corner radius, no sharp clamped corners
UMS_SPRING_ROOT_MAX = 11.5; // furthest an X tongue's root can sit from the bump
UMS_SPRING_SIDE   = 1.00;   // material beside the bump on a Z tongue
UMS_SPRING_EDGE   = 2.00;   // rail material left outside the pocket
UMS_SPRING_HEAD   = 2.00;   // rail left above the root of a Z tongue

// ---------------------------------------------------------------------
//  Derived geometry
// ---------------------------------------------------------------------

// Half width of the socket groove at distance s from the rail root plane.
// The mouth plane is at s = clr, the floor at s = clr + UMS_DEPTH.
function ums_socket_half(s, clr = UMS_CLR) =
    UMS_MOUTH_W / 2 + (s - clr) * tan(UMS_FLANK);

// Rail width where it leaves the back plate. The rail is the socket offset
// inwards by clr on every face: clr / cos(flank) across the flank plus
// clr * tan(flank) for the shifted reference plane.
function ums_rail_root_w(clr = UMS_CLR) =
    UMS_MOUTH_W - 2 * clr * (tan(UMS_FLANK) + 1 / cos(UMS_FLANK));

// Depth over which the rail flank runs at UMS_FLANK before it goes straight
function ums_rail_flank_h(clr = UMS_CLR) =
    (UMS_TIP_W - ums_rail_root_w(clr)) / (2 * tan(UMS_FLANK));

// Top of the tip face, i.e. where the seat ramp starts
function ums_rail_full_h(len = UMS_LEN) = len - UMS_RAMP;

// Detent positions
function ums_detent_z(len = UMS_LEN) = ums_rail_full_h(len) - UMS_DETENT_TOP;
function ums_dimple_z(len = UMS_LEN) = ums_detent_z(len) + UMS_DETENT_OFF;

// Bump height in use. V1's 1.00 is the default either way: a Z tongue has
// enough length to retract that far well inside the strain budget.
function ums_bump_h(spring = true, bump_h = 0, style = "cavity") =
    bump_h != 0 ? bump_h
                : (spring && style == "cavity" ? UMS_BUMP_H_SPRUNG : UMS_BUMP_H);

// The detent only exists if the bump lands on the rail with material around it
function ums_detent_fits(len = UMS_LEN) =
    ums_detent_z(len) >= UMS_BUMP_D / 2 + 1;

// Minimum material a front part needs behind the socket floor: the dimple
// plus a printable skin
function ums_socket_body_min_t(skin = 1.2) = UMS_DIMPLE_H + skin;

// ---------------------------------------------------------------------
//  2D profiles, in the (x, y) plane of the frame above
// ---------------------------------------------------------------------

// Cross-section of the rail. `over` buries the root edge in the back plate.
module ums_rail_profile2d(clr = UMS_CLR, over = UH_EPS) {
    rw = ums_rail_root_w(clr) / 2;
    tw = UMS_TIP_W / 2;
    fh = ums_rail_flank_h(clr);
    polygon([[-rw,  over], [-rw, 0], [-tw, -fh], [-tw, -UMS_DEPTH],
             [ tw, -UMS_DEPTH], [ tw, -fh], [ rw, 0], [ rw,  over]]);
}

// Cross-section of the socket cutter. `over` runs the cutter out through
// the rear face of the front part so the groove always breaks through.
module ums_socket_profile2d(clr = UMS_CLR, over = 10) {
    mw = UMS_MOUTH_W / 2;
    fw = ums_socket_half(clr + UMS_DEPTH, clr);
    polygon([[-mw,  over], [-mw, -clr], [-fw, -clr - UMS_DEPTH],
             [ fw, -clr - UMS_DEPTH], [ mw, -clr], [ mw,  over]]);
}

// ---------------------------------------------------------------------
//  3D
// ---------------------------------------------------------------------

// Male rail, to be unioned onto a back part. Sits on z = 0, runs to z = len.
module ums_rail(len = UMS_LEN, clr = UMS_CLR, detent = true, over = UH_EPS,
                bump_h = UMS_BUMP_H, bump_d = UMS_BUMP_D) {
    union() {
        difference() {
            linear_extrude(height = len) ums_rail_profile2d(clr, over);
            _ums_seat_cut(len, 0);
        }
        if (detent && ums_detent_fits(len))
            translate([0, -UMS_DEPTH, ums_detent_z(len)])
                _ums_detent_solid(bump_d, bump_h, UMS_BUMP_CAP);
    }
}

// Female socket, to be differenced out of a front part. The groove runs
// from z = -below (open, so the part can slide on) up to the seat at z = len.
module ums_socket_cutter(len = UMS_LEN, clr = UMS_CLR, detent = true,
                         below = 1, over = 10) {
    union() {
        difference() {
            translate([0, 0, -below])
                linear_extrude(height = len + below) ums_socket_profile2d(clr, over);
            _ums_seat_cut(len, clr);
        }
        // the dimple is lifted a hair into the groove so the two overlap
        // rather than meeting on a plane, which otherwise leaves it as a
        // separate closed shell instead of an opening in the floor
        if (detent && ums_detent_fits(len))
            translate([0, -clr - UMS_DEPTH + UH_EPS, ums_dimple_z(len)])
                _ums_detent_solid(UMS_DIMPLE_D, UMS_DIMPLE_H + UH_EPS, UMS_DIMPLE_CAP);
    }
}

// Everything above the seat plane z = y + len + off, i.e. the 45 deg lead-in
// on the rail (off = 0) and the closed top of the socket (off = clr).
module _ums_seat_cut(len, off = 0, big = 400) {
    translate([0, 0, len + off]) rotate([UMS_SEAT, 0, 0])
        translate([-big / 2, -big / 2, 0]) cube([big, big, big]);
}

// Detent body: truncated cone on the -Y axis, base on the plane of the
// caller. Used additively for the bump and as part of the cutter for the
// dimple. The cone flank is ~35 deg from vertical at the bottom of the
// revolution, so both features print without support.
module _ums_detent_solid(d, h, cap) {
    rotate([90, 0, 0])
        rotate_extrude()
            polygon([[0, 0], [d / 2, 0], [cap / 2, h], [0, h]]);
}

// ---------------------------------------------------------------------
//  Spring tongue geometry
// ---------------------------------------------------------------------

// ---- Sealed cavity (default) -------------------------------------------
// The outer face of the rail stays closed: no slot, nothing to clean behind.
// The bump sits on a membrane over an internal cavity, and the membrane is
// the spring.
//
// The cavity is wider across the rail (X) than it is long (Z), so the
// membrane carries its load across the SHORT span - it bends about the X
// axis, which puts the stress along Z, inside the layer plane, once the part
// is printed on its side. The stress at the short edges, which is the
// component that would cross a layer bond, is roughly half of that.
//
// It costs rail length: the cavity has to sit centred on the bump, and the
// bump is fixed at 27 below the seat, so the rail has to run about 10 mm
// further below the bump than V1's 38 does. That is free - a longer rail
// still mates any V1 front part, it simply protrudes below it.

function ums_cav_w() = UMS_TIP_W - 2 * UMS_CAV_EDGE_X;

function ums_cav_l(len = UMS_LEN) =
    min(UMS_CAV_L,
        2 * (min(ums_detent_z(len), ums_rail_full_h(len) - ums_detent_z(len))
             - UMS_CAV_EDGE_Z));

// Shortest rail that gives the cavity its full length
function ums_rail_min_len_cavity() =
    UMS_RAMP + UMS_DETENT_TOP + UMS_CAV_L / 2 + UMS_CAV_EDGE_Z;

// Free span of membrane either side of the bump, and the strain in it at full
// retraction. Guided-end strip with a rigid patch under the bump: the stiffest
// reading of the plate, so the figure is conservative.
function ums_memb_span(len = UMS_LEN, bump_d = UMS_BUMP_D) =
    (ums_cav_l(len) - bump_d) / 2;

function ums_memb_strain(len = UMS_LEN, clr = UMS_CLR, t_m = UMS_MEMB_T,
                         bump_h = UMS_BUMP_H_SPRUNG, bump_d = UMS_BUMP_D) =
    let(w = ums_memb_span(len, bump_d))
    w <= 1 ? 99 : 3 * t_m * ums_spring_travel_needed(clr, bump_h) / (w * w);

// Standing, the cavity's long side runs up the rail, so the rail needs room
// for that rather than for the short side
function ums_cav_room_needed(up = "x") = up == "z" ? ums_cav_w() : UMS_CAV_L;

function ums_cav_fits(len = UMS_LEN, clr = UMS_CLR, bump_h = UMS_BUMP_H_SPRUNG,
                      d = UMS_CAV_D, up = "x") =
    (up != "z" || 2 * (ums_detent_z(len) - UMS_CAV_EDGE_Z) >= ums_cav_w()) &&
    ums_detent_fits(len) && ums_memb_span(len) >= 5
    && d > ums_spring_travel_needed(clr, bump_h) + 0.3;

// ---- Z tongue: an open slot, kept for parts where that is acceptable ----
// Layers stack along X, so the tongue runs along Z and flexes along Y, both
// of which lie in the layer plane. Nothing the spring does is ever carried
// by a layer bond. The taper that makes it self-supporting runs across the
// width in X, which is the print's vertical axis.

function ums_spring_tip_w(bump_d = UMS_BUMP_D) = bump_d + 2 * UMS_SPRING_SIDE;

// Length root to bump: as long as the width budget and the rail above the
// bump allow, since longer is always gentler on the material.
function ums_spring_len_z(len = UMS_LEN, mo = 60, bump_d = UMS_BUMP_D,
                          gap = UMS_SPRING_GAP) =
    let(w_avail = UMS_TIP_W - 2 * (gap + UMS_SPRING_EDGE),
        by_width  = (w_avail - ums_spring_tip_w(bump_d)) / (2 * tan(uh_beta(mo))),
        by_height = ums_rail_full_h(len) - UMS_SPRING_HEAD - ums_detent_z(len))
    min(by_width, by_height);

function ums_spring_fits_z(len = UMS_LEN, mo = 60, bump_d = UMS_BUMP_D,
                           gap = UMS_SPRING_GAP) =
    ums_detent_fits(len) && ums_spring_len_z(len, mo, bump_d, gap) >= 5
    && ums_detent_z(len) - bump_d / 2 - UMS_SPRING_SIDE - gap > 0.5;

// ---- X tongue: for parts printed standing, e.g. the vertical pole clip --
// Root of the tongue in x. The underside ramp starts on the bottom of the
// rail and rises at beta; the root sits as far from the bump as that ramp
// can run while staying clear of the bump by UMS_SPRING_BUMP_C.
function ums_spring_root_x(len = UMS_LEN, mo = 60, bump_d = UMS_BUMP_D) =
    let(m = tan(uh_beta(mo)),
        clearance = (bump_d / 2 + UMS_SPRING_BUMP_C) * sqrt(m * m + 1),
        rise = ums_detent_z(len) - clearance)
    -min(rise / m, UMS_SPRING_ROOT_MAX);

// Floor of the pocket, which is where the underside ramp starts. It is the
// bottom of the rail when the ramp has room to run that far, and a step
// further up when the bump sits high on a long rail.
function ums_spring_floor_z(len = UMS_LEN, mo = 60, bump_d = UMS_BUMP_D) =
    let(m = tan(uh_beta(mo)))
    ums_detent_z(len) - (bump_d / 2 + UMS_SPRING_BUMP_C) * sqrt(m * m + 1)
        - ums_spring_len(len, mo, bump_d) * m;

// Free length of the cantilever, root to bump
function ums_spring_len(len = UMS_LEN, mo = 60, bump_d = UMS_BUMP_D) =
    -ums_spring_root_x(len, mo, bump_d);

// How far the bump has to retract for a front part to slide over it
function ums_spring_travel_needed(clr = UMS_CLR, bump_h = UMS_BUMP_H) = bump_h - clr;

// Surface strain at the root at full retraction, prismatic-beam estimate
function ums_spring_strain(len = UMS_LEN, clr = UMS_CLR, t = UMS_SPRING_T,
                           mo = 60, bump_h = UMS_BUMP_H, bump_d = UMS_BUMP_D,
                           axis = "z", gap = UMS_SPRING_GAP) =
    let(L = axis == "z" ? ums_spring_len_z(len, mo, bump_d, gap)
                        : ums_spring_len(len, mo, bump_d))
    L <= 0 ? 99 : 3 * t * ums_spring_travel_needed(clr, bump_h) / (2 * L * L);

function ums_spring_ok(len = UMS_LEN, mo = 60, bump_d = UMS_BUMP_D,
                       axis = "z", gap = UMS_SPRING_GAP) =
    axis == "z" ? ums_spring_fits_z(len, mo, bump_d, gap)
                : ums_spring_fits(len, mo, bump_d);

// Top of the tongue
function ums_spring_top_z(len = UMS_LEN, bump_d = UMS_BUMP_D) =
    ums_detent_z(len) + bump_d / 2 + UMS_SPRING_TOP;

function ums_spring_fits(len = UMS_LEN, mo = 60, bump_d = UMS_BUMP_D) =
    ums_detent_fits(len) && ums_spring_len(len, mo, bump_d) >= 4;

// The bump on its own, on the tip face at the detent height. Used by the
// snap probe to measure how far it has to retract at each stage of sliding
// a front part on.
module ums_bump(len = UMS_LEN, bump_h = UMS_BUMP_H, bump_d = UMS_BUMP_D) {
    translate([0, -UMS_DEPTH, ums_detent_z(len)])
        _ums_detent_solid(bump_d, bump_h, UMS_BUMP_CAP);
}

// Everything the back part has to subtract AFTER the rail is unioned onto
// the plate: the pocket that frees the spring tongue. Call it last.
// `up` says which way the part stands on the bed: x for parts laid on their
// side, z for parts printed standing. The cavity has to bend about the print's
// horizontal axis either way, so for a standing part the same cavity is simply
// turned a quarter turn about y, which swaps its width and its length and
// carries the self-roofing ridge round to the top with it.
module ums_rail_cutters(len = UMS_LEN, clr = UMS_CLR, spring = true, mo = 60,
                        t = UMS_SPRING_T, travel = UMS_SPRING_TRAVEL,
                        gap = UMS_SPRING_GAP, tip = UMS_SPRING_TIP,
                        bump_d = UMS_BUMP_D, side = "left", axis = "z",
                        style = "cavity", t_m = UMS_MEMB_T, cav_d = UMS_CAV_D,
                        bump_h = UMS_BUMP_H_SPRUNG, up = "x") {
    if (spring) {
        if (style == "cavity") {
            if (ums_cav_fits(len, clr, bump_h, cav_d))
                _ums_cavity_oriented(len, mo, t_m, cav_d, bump_d, up);
        } else if (ums_spring_ok(len, mo, bump_d, axis, gap)) {
            if (axis == "z")
                _ums_spring_void_z(len, mo, t, travel, gap, bump_d);
            else
                mirror(side == "right" ? [1, 0, 0] : [0, 0, 0])
                    _ums_spring_void(len, mo, t, travel, gap, tip, bump_d);
        }
    }
}

module _ums_cavity_oriented(len, mo, t_m, d, bump_d, up) {
    zc = ums_detent_z(len);
    if (up == "z")
        translate([0, 0, zc]) rotate([0, -90, 0]) translate([0, 0, -zc])
            _ums_cavity(len, mo, t_m, d, bump_d);
    else
        _ums_cavity(len, mo, t_m, d, bump_d);
}

// Sealed cavity behind the membrane. Rounded in the x-z plane so the membrane
// has no sharp clamped corner, and ridged at its top edge so that, laid on its
// side, the cavity roofs itself instead of needing support.
module _ums_cavity(len, mo, t_m, d, bump_d) {
    zc   = ums_detent_z(len);
    w    = ums_cav_w();
    l    = ums_cav_l(len);
    y_lo = -UMS_DEPTH + t_m;
    y_hi = y_lo + d;
    rh   = (d / 2) / tan(mo);
    r    = min(UMS_CAV_R, l / 3, w / 3);
    intersection() {
        translate([0, y_hi, 0]) rotate([90, 0, 0]) linear_extrude(height = d)
            translate([0, zc]) hull() {
                // straight top edge, so the Y ridge above can roof the whole
                // length; rounded at the bottom, where nothing overhangs
                translate([w / 2 - 0.005, 0]) square([0.01, l], center = true);
                translate([-w / 2 + r, -(l / 2 - r)]) circle(r = r);
                translate([-w / 2 + r,  (l / 2 - r)]) circle(r = r);
            }
        translate([0, 0, zc - l]) linear_extrude(height = 2 * l)
            polygon([[-w, y_lo], [w / 2 - rh, y_lo], [w / 2, (y_lo + y_hi) / 2],
                     [w / 2 - rh, y_hi], [-w, y_hi]]);
    }
}

// Void around a Z tongue: the tongue is a trapezoid in the x-z plane, widest
// at the root, and the void is the same trapezoid grown by the slot gap.
// Both taper at beta, so the tongue's lower edge and the void's upper edge
// are both self-supporting once the part is laid on its side.
module _ums_spring_void_z(len, mo, t, travel, gap, bump_d) {
    m    = tan(uh_beta(mo));
    L    = ums_spring_len_z(len, mo, bump_d, gap);
    z_t  = ums_detent_z(len) - bump_d / 2 - UMS_SPRING_SIDE;   // free end
    z_r  = ums_detent_z(len) + L;                              // root
    wt   = ums_spring_tip_w(bump_d) / 2;
    difference() {
        translate([0, -UMS_DEPTH + t + travel, 0]) rotate([90, 0, 0])
            linear_extrude(height = t + travel + UH_EPS)
                _ums_tongue2d(z_t - gap, z_r, wt + gap, m);
        translate([0, -UMS_DEPTH + t, 0]) rotate([90, 0, 0])
            linear_extrude(height = t + 3)
                _ums_tongue2d(z_t, z_r, wt, m);
    }
}

// Trapezoid from (z0, half width hw0) widening at slope m up to z1
module _ums_tongue2d(z0, z1, hw0, m) {
    hw1 = hw0 + (z1 - z0) * m;
    polygon([[-hw0, z0], [hw0, z0], [hw1, z1], [-hw1, z1]]);
}

// The void around the tongue: a prism along x, minus the tongue itself.
module _ums_spring_void(len, mo, t, travel, gap, tip, bump_d) {
    m    = tan(uh_beta(mo));
    x_r  = ums_spring_root_x(len, mo, bump_d);
    x_f  = tip;
    z_t  = ums_spring_top_z(len, bump_d);
    y_f  = -UMS_DEPTH;                 // tip face
    y_tb = y_f + t;                    // back of the tongue
    y_pb = y_tb + travel;              // back of the pocket
    z_fl = ums_spring_floor_z(len, mo, bump_d);
    difference() {
        // pocket: open downward, ceiling sloping up from the pocket wall to
        // the front so it builds off that wall instead of being bridged
        translate([x_r, 0, 0]) rotate([90, 0, 90])
            linear_extrude(height = x_f + gap - x_r)
                polygon([[y_f - UH_EPS, z_fl], [y_pb, z_fl],
                         [y_pb, z_t + gap],
                         [y_f - UH_EPS, z_t + gap + (y_pb - y_f + UH_EPS) * m]]);
        // the tongue, put back: underside ramps up at beta from the bottom
        // of the rail, so the free end is shallower than the root
        translate([0, y_tb, 0]) rotate([90, 0, 0])
            linear_extrude(height = t + 2)
                polygon([[x_r, z_fl - UH_EPS], [x_f, z_fl + (x_f - x_r) * m],
                         [x_f, z_t], [x_r, z_t]]);
    }
}


module ums_iface_checks(len = UMS_LEN, clr = UMS_CLR, detent = true,
                        spring = true, mo = 60, t = UMS_SPRING_T,
                        travel = UMS_SPRING_TRAVEL, bump_h = UMS_BUMP_H,
                        bump_d = UMS_BUMP_D, axis = "z",
                        gap = UMS_SPRING_GAP, style = "cavity",
                        t_m = UMS_MEMB_T, cav_d = UMS_CAV_D) {
    assert(clr >= 0 && clr <= UMS_DEPTH / 4,
        "UMS: fit_clr must be between 0 and 1 mm");
    assert(len >= UMS_RAMP + 6,
        "UMS: interface length is shorter than the seat ramp plus material");
    uh_warn(!detent || ums_detent_fits(len),
        str("detent dropped: interface length ", len, " leaves no room below the seat"));
    // 48 is the standard for new parts and 38 is V1's own; both mate any
    // front part, so length alone is not worth a warning. Anything shorter
    // than the cavity needs is warned about below.
    uh_warn(len >= UMS_LEN - 0.001,
        str("interface length ", len, " is shorter than V1's ", UMS_LEN,
            "; engagement drops with it"));
    uh_info(str("UMS interface: rail ", ums_rail_root_w(clr), " root / ", UMS_TIP_W,
                " tip, full section ", ums_rail_full_h(len), " + ", UMS_RAMP,
                " seat, clearance ", clr));
    if (spring && detent && style == "cavity") {
        need = ums_spring_travel_needed(clr, bump_h);
        epsm = ums_memb_strain(len, clr, t_m, bump_h, bump_d);
        fits = ums_cav_fits(len, clr, bump_h, cav_d);
        uh_warn(len >= ums_rail_min_len_cavity(),
            str("interface length ", len, " is short for a sealed cavity: needs about ",
                ums_rail_min_len_cavity(), " for the cavity to sit centred on the bump"));
        uh_warn(fits, "cavity dropped: no room for it - the bump is rigid");
        uh_warn(!fits || epsm <= UMS_STRAIN_MAX,
            str("membrane strain ", epsm, " exceeds ", UMS_STRAIN_MAX,
                " - lengthen the rail, thin the membrane, or lower the bump"));
        if (fits)
            uh_info(str("sealed cavity ", ums_cav_w(), " x ", ums_cav_l(len), " x ",
                        cav_d, ", membrane ", t_m, ", spans ",
                        ums_memb_span(len, bump_d), " each side, retracts ", need,
                        ", strain ", epsm));
    }
    if (spring && detent && style != "cavity") {
        need = ums_spring_travel_needed(clr, bump_h);
        eps  = ums_spring_strain(len, clr, t, mo, bump_h, bump_d, axis, gap);
        ok   = ums_spring_ok(len, mo, bump_d, axis, gap);
        L    = axis == "z" ? ums_spring_len_z(len, mo, bump_d, gap)
                           : ums_spring_len(len, mo, bump_d);
        uh_warn(ok, "spring dropped: no room for the tongue - the bump is rigid");
        uh_warn(!ok || travel >= need + 0.2,
            str("spring travel ", travel, " is less than the ", need,
                " the bump has to retract plus 0.2 - raise spring_travel"));
        uh_warn(!ok || eps <= UMS_STRAIN_MAX,
            str("spring strain ", eps, " exceeds ", UMS_STRAIN_MAX,
                " - thin the tongue, lower the bump, or raise max_overhang"));
        if (ok)
            uh_info(str("spring tongue along ", axis, ": ", L, " long, ", t,
                        " thick, retracts ", need, ", strain ", eps,
                        " (prismatic estimate, tapered is lower)"));
    }
}

// No geometry; asserts stop the render if a derived value drifts off V1.
module ums_iface_selftest() {
    assert(uh_approx(ums_rail_root_w(0.20), 26.04, 0.01),   "rail root width vs V1");
    assert(uh_approx(ums_rail_flank_h(0.20), 2.48, 0.01),   "rail flank run vs V1");
    assert(uh_approx(UMS_DEPTH - ums_rail_flank_h(0.20), 1.52, 0.01),
                                                            "rail straight flank vs V1");
    assert(uh_approx(2 * ums_socket_half(UMS_CLR + UMS_DEPTH), UMS_FLOOR_W, 1e-6),
                                                            "socket floor width");
    assert(uh_approx(2 * ums_socket_half(UMS_CLR), UMS_MOUTH_W, 1e-6),
                                                            "socket mouth width");
    assert(uh_approx(ums_detent_z(UMS_LEN), 7.00, 1e-6),    "bump above the rail bottom");
    assert(uh_approx(ums_dimple_z(UMS_LEN) - ums_detent_z(UMS_LEN), UMS_DETENT_OFF, 1e-9),
                                                            "detent offset");
    assert(ums_spring_root_x(UMS_LEN, 60) < 0,              "spring root is left of the bump");
    assert(ums_spring_strain(UMS_LEN, UMS_CLR, UMS_SPRING_T, 60) <= UMS_STRAIN_MAX,
                                                            "default spring strain");
    assert(ums_spring_fits_z(UMS_LEN, 60),                  "default Z tongue fits");
    assert(ums_memb_strain(48, UMS_CLR) <= UMS_STRAIN_MAX,  "default membrane strain");
    assert(ums_cav_w() > ums_cav_l(48),
           "cavity must be wider than it is long, so the membrane bends about x");
    uh_info("ums_iface self-test passed");
}
