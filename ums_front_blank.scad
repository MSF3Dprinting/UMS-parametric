// =====================================================================
//  UMS V1 — ums_front_blank.scad                                   ST-5
//  The front side of the interface: a blank carrying the V1 socket, and
//  the same blank with a bolt pattern that fixes it to a UniHolder.
//
//  The socket is V1 exactly - mouth 27, floor 35, depth 4 at 45 deg, and
//  the dimple 26.58 below the top of the floor. Nothing about the front
//  part's inner geometry is ours to change, so a V1 back part fits this
//  and this fits a V1 back part.
//
//  Prints standing, the way V1's own front parts do: measured on the
//  three V1 holders, unsupported area above 60 deg is 0.1 to 29 mm2
//  standing against thousands any other way. The socket is then a
//  vertical slot, its closing ramp the only overhang.
//
//  THE UNIHOLDER IS NOT MODIFIED. The adapter is a separate printed part
//  that bolts through the holder's existing back holes, the same method
//  the DIN clip uses. Screws go in from inside the holder, through its
//  back wall, into a captive nut held in this part.
// =====================================================================

/* [Part] */
// blank is the bare connector to build a holder on; adapter bolts to a UniHolder
mode = "adapter"; // [blank, adapter]

/* [Print] */
max_overhang = 60; // [45:5:60]
quality = "fine"; // [draft, normal, fine]

/* [Fit] */
// Clearance between front and back part, on every mating face
clr = 0.20; // [0:0.05:0.6]
// Dimple for the back part's detent
detent = true;

/* [Body] */
// Width across the part
body_w = 40; // [31:0.5:120]
// Height. 0 = auto: enough socket to engage a 48 rail
body_h = 0; // [0:0.5:200]
// Thickness front to back. 0 = auto from the fixing
body_t = 0; // [0:0.5:30]
// Corner radius
body_r = 3; // [0:0.5:12]
// Chamfer where the part meets the bed
edge_ch = 0.6; // [0:0.1:2]
// Material above the seat, so the bed chamfer never clips the seat ramp.
// V1's own front parts carry about 3
top_margin = 3; // [1:0.5:20]

/* [Fixing] */
// nut_pocket takes a nut pushed in from the side edge after printing. The
// pocket is closed towards the holder, so the nut cannot fall out while you
// line the two up, and it is elongated so it can follow the slot.
// pilot is a blind hole for a self tapping screw, and needs no nut at all
fix = "nut_pocket"; // [nut_pocket, pilot]
// Bolt clearance diameter. The UniHolder's back holes are 4.5
bolt_d = 4.5; // [3:0.5:8]
// Nut across flats: 7.0 is M4, 8.0 is M5
nut_af = 7.0; // [5:0.1:14]
nut_t = 3.2; // [1.6:0.1:6]
// Material between the nut and the holder. The nut bears on this
nut_skin = 1.2; // [0.8:0.1:4]
// Which side edge the nut goes in from
nut_side = "right"; // [right, left]
// Room past the nut for the end of the bolt
bolt_tail = 1.5; // [0:0.1:6]
// Bolt columns and rows
cols = 1; // [1:1:4]
rows = 2; // [1:1:6]
pitch_x = 0; // [0:0.5:120]
// Row pitch. 0 = derived from holder_h below
pitch_z = 0; // [0:0.5:200]
// Height of the UniHolder this bolts to, outer size in z. Its two back holes
// sit 9.67 up from the bottom and 6.02 down from the top, measured on holders
// of 60, 80, 100 and 120, so the pitch is this minus 15.69
holder_h = 80; // [0:0.5:400]
// Height of the lowest bolt above the foot of this part. 0 = 9.67, which is
// where a UniHolder's lower back hole sits when the two are stood foot to foot
bolt_z0 = 0; // [0:0.5:200]
// Play along the slots, for print tolerance and a pitch that is a hair out
slot_travel = 6; // [0:0.5:20]
// Material left behind the nut
skin = 1.2; // [0.8:0.1:4]

/* [Hidden] */
include <lib/uh_core.scad>
include <lib/uh_shapes.scad>
include <lib/ums_iface.scad>

$fa = uh_quality(quality)[0];
$fs = uh_quality(quality)[1];

MO   = max_overhang;
// UniHolder back holes: 9.67 from the bottom, 6.02 from the top
UH_LO = 9.67;
UH_HI = 6.02;
PZ   = uh_auto(pitch_z, holder_h > 0 ? holder_h - UH_LO - UH_HI : 40);
// Stack front to back: socket, then whatever holds the bolt, then skin. The
// bolt must never reach the socket floor - that face mates the rail.
// Stack front to back for a nut pocket: skin the nut bears on, the nut, the
// tail of the bolt, then the skin behind it and the socket
FIXD = fix == "nut_pocket" ? nut_skin + nut_t + bolt_tail : bolt_tail + 3;
BT   = uh_auto(body_t, UMS_DEPTH + FIXD + skin);
// Bolts are placed from the foot up, not centred on the part: that is what
// registers them to the holder's own holes when the two stand foot to foot
BZ0  = uh_auto(bolt_z0, UH_LO);
BH   = uh_auto(body_h, mode == "adapter"
                       ? max(UMS_LEN_STD + top_margin, BZ0 + (rows - 1) * PZ + UH_LO)
                       : UMS_LEN_STD + top_margin);
// The socket seats top_margin below the top of the part
SL   = BH - top_margin;

ums_iface_selftest();
checks();
front_part();

module front_part() {
    difference() {
        body();
        ums_socket_cutter(SL, clr, detent, below = 2);
        if (mode == "adapter") fixings();
    }
}

// Body: rounded slab standing on the bed, rear face on the socket mouth plane
module body() {
    uh_chamfered_extrude(BH, edge_ch, edge_ch, MO)
        translate([0, -clr - BT / 2])
            offset(r = body_r) square([body_w - 2 * body_r, BT - 2 * body_r], center = true);
}

// Bolt slots, and whatever holds the nut. Slots run up and down so a pitch
// that is a little out still lands in them.
module fixings() {
    y_front = -clr - BT;
    for (i = [0:cols - 1], j = [0:rows - 1]) {
        x = (i - (cols - 1) / 2) * uh_auto(pitch_x, body_w / 2);
        z = BZ0 + j * PZ;
        // rotate([90,0,0]) carries the profile's +y to +z, which keeps the
        // slot's teardrop and the nut's point facing up, and extrudes toward
        // -Y, so each cutter starts at its blind end and runs out through the
        // front face
        translate([x, 0, z]) {
            // clearance slot, blind: it stops FIXD in, clear of the socket
            // floor behind it, because that floor mates the rail
            translate([0, y_front + FIXD, 0]) rotate([90, 0, 0])
                linear_extrude(height = FIXD + 1)
                    translate([0, -slot_travel / 2])
                        uh_slot2d(fix == "pilot" ? bolt_d - 1 : bolt_d, slot_travel, MO);
            // Nut channel, entered from a side edge and closed towards the
            // holder, so the nut is captive in this part on its own. It is
            // elongated in z like the slot, so the nut follows the bolt, and
            // its flats still stop it turning. Printed standing the channel is
            // a horizontal pocket, so the hexagon goes in point up and roofs
            // itself.
            if (fix == "nut_pocket") nut_slot(y_front);
        }
    }
}

// Nut pocket at the bolt, plus a channel out to the side edge so the nut can
// be pushed in after printing. The pocket is a hexagon elongated upwards, so
// the nut's flats bear on its vertical walls and it cannot turn, while it can
// still slide to follow the slot. It is closed toward the holder by nut_skin,
// so the nut is captive in this part on its own - nothing has to be held in
// place while the two are lined up, and nothing is inserted mid-print.
module nut_slot(y_front) {
    y0 = y_front + nut_skin;
    sgn = nut_side == "left" ? -1 : 1;
    // pocket: hexagonal prism on the bolt axis, elongated in z
    translate([0, y0 + nut_t, 0]) rotate([90, 0, 0])
        linear_extrude(height = nut_t) hull() {
            translate([0, -slot_travel / 2]) uh_hex_cell2d(nut_af, MO);
            translate([0,  slot_travel / 2]) uh_hex_cell2d(nut_af, MO);
        }
    // entry channel out to the side edge, roofed by its own peak
    translate([0, 0, 0]) rotate([90, 0, 90]) mirror([0, 0, sgn < 0 ? 1 : 0])
        linear_extrude(height = body_w / 2 + 1)
            translate([y0 + nut_t / 2, 0]) uh_peaked_rect2d([nut_t, nut_af], MO);
}

module checks() {
    assert(body_w >= UMS_PLATE_W, "body_w is narrower than the rail");
    assert(BT >= UMS_DEPTH + 1.2, "body_t leaves no material behind the socket");
    uh_warn(mode != "adapter" || fix != "nut_pocket" || nut_skin >= 1.0,
        str("only ", nut_skin, " in front of the nut; that is what stops it pulling through"));
    assert(mode != "adapter" || BT - UMS_DEPTH - FIXD >= 0.8,
        "body_t leaves no skin between the bolt and the socket floor");
    uh_warn(mode != "adapter" || BT - UMS_DEPTH - FIXD >= skin - 0.001,
        str("only ", BT - UMS_DEPTH - FIXD, " of skin behind the bolt"));
    uh_warn(mode != "adapter" || rows < 2 || PZ > nut_af + slot_travel + 2,
        str("row pitch ", PZ, " is tight for a ", nut_af, " nut with ", slot_travel,
            " of travel"));
    uh_warn(SL >= UMS_LEN_STD - 0.001,
        str("socket ", SL, " long engages less than a full ", UMS_LEN_STD, " rail"));
    uh_info(str("front ", mode, ": ", body_w, " x ", BT, " x ", BH,
                ", socket ", SL, " long seating ", top_margin, " below the top, ",
                mode == "adapter" ? str(cols * rows, " bolts \u00d8", bolt_d, " at ",
                                        PZ, " row pitch from ", BZ0, " up, ",
                                        slot_travel, " travel")
                                  : "no fixings"));
}
