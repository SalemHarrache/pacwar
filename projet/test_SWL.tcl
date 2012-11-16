source gml_Object.tcl
source SWL_FC.tcl

SWL_FC S

package require Tk
canvas .c
pack .c -expand 1 -fill both

proc Help {C exp} {
	puts $C
	foreach m [gmlObject info methods $C] {
		 if {[regexp $exp $m]} {puts "\t$m {[gmlObject info arglist $C $m]}"}
		}
}


S Subscribe_after_Add_new_planet ALEX {.c delete $rep; .c create oval [expr $x - $radius] [expr $y - $radius] [expr $x + $radius] [expr $y + $radius] -fill green -tags [list ALEX $rep]}
S Subscribe_after_Destroy_planet ALEX {puts "Destroy planet $id"; .c delete $id}
S Subscribe_after_Update_planet  ALEX {
	set x [dict get $this(D_planets) $id x]
	set y [dict get $this(D_planets) $id y]
	set radius [dict get $this(D_planets) $id radius]
	.c coords $id [expr $x - $radius] [expr $y - $radius] [expr $x + $radius] [expr $y + $radius]
}


S Subscribe_after_Add_new_ship ALEX {.c delete $rep; .c create oval [expr $x - $radius] [expr $y - $radius] [expr $x + $radius] [expr $y + $radius] -fill red -tags [list ALEX $rep]}
S Subscribe_after_Destroy_ship ALEX {puts "Destroy ship $id"; .c delete $id}
S Subscribe_after_Update_ship  ALEX {
	set x [dict get $this(D_players) $id_player D_ships $id x]
	set y [dict get $this(D_players) $id_player D_ships $id y]
	set radius [dict get $this(D_players) $id_player D_ships $id radius]
	.c coords $id [expr $x - $radius] [expr $y - $radius] [expr $x + $radius] [expr $y + $radius]
}


S Subscribe_after_Start_fire                ALEX {
	.c delete Bullet
	set radius 2
	foreach {id x y vx vy} $this(L_bullets) {
		 .c create oval [expr $x - $radius] [expr $y - $radius] [expr $x + $radius] [expr $y + $radius] -fill black -tags [list Bullet $id]
		}
}
S Subscribe_after_Compute_a_simulation_step ALEX {
	set radius 2
	foreach {id x y vx vy} $this(L_bullets) {
		 .c coords $id [expr $x - $radius] [expr $y - $radius] [expr $x + $radius] [expr $y + $radius]
		}
}


set id_P1 [S Add_new_player "toto"]
set id_P2 [S Add_new_player "Bob" ]
set id_S1 [S Add_new_ship $id_P1 300 200 10]; S Update_ship $id_P1 $id_S1 [dict create fire_velocity 1 fire_angle 1]
set id_S2 [S Add_new_ship $id_P1 200 300 10]; S Update_ship $id_P1 $id_S2 [dict create fire_velocity 10 fire_angle 1]
set id_S3 [S Add_new_ship $id_P2 500 200 10]; S Update_ship $id_P2 $id_S3 [dict create fire_velocity 1 fire_angle 5]
set id_S4 [S Add_new_ship $id_P2 500 300 10]; S Update_ship $id_P2 $id_S4 [dict create fire_velocity 10 fire_angle 5]

set id_p1 [S Add_new_planet 400 400 30 10]
set id_p2 [S Add_new_planet 400 300 20 5 ]


puts "S Start_fire"

