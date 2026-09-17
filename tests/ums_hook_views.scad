// Preview only: the hook drawn transparent with its two internal voids solid,
// so the wall shell and the detent cavity can be seen where they sit.
tube_d = 32;
rail_len = 48;
include <../lib/uh_core.scad>
include <../lib/uh_shapes.scad>
include <../lib/ums_iface.scad>
include <../lib/ums_hook_lib.scad>
use <../ums_hook.scad>
$fa = 2; $fs = 0.4;
%back_part();
ums_wall_shell(tube_d, 0, UMS_WALL_T, UMS_PLATE_T, rail_len, UMS_RAIL_CLEAR,
               -45, 0.6, UMS_SHELL_END, UMS_SHELL_SIDE, UMS_PLATE_W);
ums_rail_cutters(rail_len, 0.20, true, 60, UMS_SPRING_T, UMS_SPRING_TRAVEL,
                 UMS_SPRING_GAP, UMS_SPRING_TIP, UMS_BUMP_D, "left", "z",
                 "cavity", 0.6, 1.4, 0.6);
