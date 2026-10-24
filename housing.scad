// Housing for an Andamiro Pump It Up sensor (5.6 x 0.6 x 0.3 in), designed to
// fit in US DDR X2 pads.
// tray: open-top holder with slide-in cover interlock + mount tabs.
// cover: inverted-U cap that presses the sensor; slides under the tray_interlock.

$fa = 1;
$fs = 1;

// all constants are in mm

// sensor size
sensor_len = 142.24;
sensor_width = 15.24;
sensor_height = 7.62;

// ---- tray body ----
tray_wall_thickness = 2;
// per-side clearance
sensor_clearance = 0.5;
tray_floor_thickness = 2;
end_roof_len = 5;

// ---- mount tabs ----
hole_spacing = 170;
hole_diameter = 3.5;
tab_thickness = 3;
// material past each hole center
tab_margin = 6;

// ---- cover ----
cover_len = 76.2;
cover_wall_to_floor_gap = 3;
window_play = 1.5;       // lengthwise play between cover and side_wall_gap
interlock_len = 12.7;
tray_interlock_height = 2;   // tray wall ledge that captures the cover
contact_pad_height = 2;  // sensor-contact pad height
interlock_clearance = 0.5; // vertical gap so the cover slides under the tray_interlock

cavity_len = sensor_len + 2 * sensor_clearance;
cavity_width = sensor_width + 2 * sensor_clearance;
tray_width = cavity_width + 2 * tray_wall_thickness;
wall_height = tray_floor_thickness + sensor_height;
side_wall_gap = cover_len + 2 * window_play;
side_wall_gap_start = (cavity_len - side_wall_gap) / 2;
side_wall_gap_end = (cavity_len + side_wall_gap) / 2;
cover_wall_height = sensor_height + contact_pad_height - cover_wall_to_floor_gap; // roof sits on the pads, so cover is lifted by pad height
cover_z = tray_floor_thickness + cover_wall_to_floor_gap;
cover_interlock_height = wall_height - tray_interlock_height - interlock_clearance - cover_z; // top clears the tray_interlock
tray_len = cavity_len + tray_wall_thickness;
tab_len = hole_spacing / 2 - tray_len / 2 + tab_margin;

module tray() {
	difference() {
		union() {
			// floor
			cube([cavity_len + tray_wall_thickness, tray_width, tray_floor_thickness]);
			// far wall to keep one end of sensor in place
			translate([cavity_len, 0, 0]) {
				cube([tray_wall_thickness, tray_width, wall_height]);
			}
			// far roof to keep one end of sensor in place
			translate([cavity_len - end_roof_len, 0, wall_height]) {
				cube([end_roof_len + tray_wall_thickness, tray_width, tray_wall_thickness]);
			}
			// side walls, split by the side_wall_gap
			for (y = [0, tray_width - tray_wall_thickness]) {
				translate([0, y, 0]) {
					cube([side_wall_gap_start, tray_wall_thickness, wall_height]);
				}
				translate([side_wall_gap_end, y, 0]) {
					cube([cavity_len + tray_wall_thickness - side_wall_gap_end, tray_wall_thickness, wall_height]);
				}
			}
			// tray_interlock ledges at both ends of the side_wall_gap
			for (x = [side_wall_gap_start, side_wall_gap_end - interlock_len]) {
				for (y = [0, tray_width - tray_wall_thickness]) {
					translate([x, y, wall_height - tray_interlock_height]) {
						cube([interlock_len, tray_wall_thickness, tray_interlock_height]);
					}
				}
			}
			// mount tabs for screws
			translate([-tab_len, 0, 0]) {
				cube([tab_len, tray_width, tab_thickness]);
			}
			translate([tray_len, 0, 0]) {
				cube([tab_len, tray_width, tab_thickness]);
			}
		}
		// screw holes
		for (x = [tray_len / 2 - hole_spacing / 2, tray_len / 2 + hole_spacing / 2]) {
			translate([x, tray_width / 2, -1]) {
				cylinder(d = hole_diameter, h = tab_thickness + 2);
			}
		}
	}
}

module cover() {
	// cover walls; both ends notched so they slide under the tray_interlock
	for (y = [0, tray_width - tray_wall_thickness]) {
		translate([-cover_len / 2, y, 0]) {
			cube([interlock_len, tray_wall_thickness, cover_interlock_height]);
		}
		translate([-cover_len / 2 + interlock_len, y, 0]) {
			cube([cover_len - 2 * interlock_len, tray_wall_thickness, cover_wall_height]);
		}
		translate([cover_len / 2 - interlock_len, y, 0]) {
			cube([interlock_len, tray_wall_thickness, cover_interlock_height]);
		}
	}
	// roof between the notched ends
	translate([-cover_len / 2 + interlock_len, 0, cover_wall_height]) {
		cube([cover_len - 2 * interlock_len, tray_width, tray_wall_thickness]);
	}
	// sensor-contact pads at both ends under roof
    // (to reduce contact area between cover and sensor for more sensitivity)
	for (x = [-cover_len / 2 + interlock_len, cover_len / 2 - 2 * interlock_len]) {
		translate([x, tray_wall_thickness, cover_wall_height - contact_pad_height]) {
			cube([interlock_len, tray_width - 2 * tray_wall_thickness, contact_pad_height]);
		}
	}
}

part = "both";

if (part == "tray") {
	tray();
} else if (part == "cover") {
	cover();
} else {
	tray();
	translate([cavity_len + tray_wall_thickness + 20 + cover_len / 2, 0, cover_z]) {
		cover();
	}
}
