#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
# Functionnal core of StarWarLight
# 	A planet is a dictionnary with entries: x, y, radius, density
#	A player is a dictionnary with entries: name, D_ships
#	D_ships  is a dictionnary of ships
# 	A ship   is a dictionnary with entries: x, y, radius, energy, fire_velocity, fire_angle (expressed in radians)
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method SWL_FC constructor {} {
	set this(player_uid) 0
	set this(uid) 0
	set this(dt)  0.05
	set this(simulation_step) 10

	this reset
}

#___________________________________________________________________________________________________________________________________________
method SWL_FC generate_uid {prefix} {
	incr this(uid)
	return ${prefix}$this(uid)
}

method SWL_FC generate_player_uid {prefix} {
	incr this(player_uid)
	return ${prefix}$this(player_uid)
}

#___________________________________________________________________________________________________________________________________________
method SWL_FC reset {} {
	set this(D_planets) [dict create]
	set this(D_players) [dict create]
	set this(L_bullets) [list]

	set this(interupt_simulation) 0
}

#___________________________________________________________________________________________________________________________________________
method SWL_FC get_dt { } {return $this(dt)}
method SWL_FC set_dt {v} {set this(dt) $v}

#___________________________________________________________________________________________________________________________________________
method SWL_FC get_simulation_step { } {return $this(simulation_step)}
method SWL_FC set_simulation_step {v} {set this(simulation_step) $v}

#___________________________________________________________________________________________________________________________________________
method SWL_FC Stop_simulation {} {set this(interupt_simulation) 1}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________ Simulation ____________________________________________________________
#___________________________________________________________________________________________________________________________________________
method SWL_FC Start_fire {} {
	set this(interupt_simulation) 0
	# Initialize bullets
	set this(L_bullets) [list]
	dict for {id_player D_player} $this(D_players) {
		 dict for {id_ship D_ship} [dict get $D_player D_ships] {
			 set cos_x [expr cos([dict get $D_ship fire_angle])]
			 set sin_x [expr sin([dict get $D_ship fire_angle])]
			 set x  [expr [dict get $D_ship x] + 1.1 * $cos_x * [dict get $D_ship radius]]
			 set y  [expr [dict get $D_ship y] + 1.1 * $sin_x * [dict get $D_ship radius]]
			 set vx [expr [dict get $D_ship fire_velocity] * $cos_x]
			 set vy [expr [dict get $D_ship fire_velocity] * $sin_x]
			 lappend this(L_bullets) Bullet_$id_ship $x $y $vx $vy
			}
		}

	# Start simulation loop
	this Compute_a_simulation_step
}

#___________________________________________________________________________________________________________________________________________
method SWL_FC Collision_with_planets {x y} {
	 dict for {id_planet D_planet} $this(D_planets) {
		 # Collision with this planet?
		 set DX [expr [dict get $D_planet x] - $x]
		 set DY [expr [dict get $D_planet y] - $y]
		 set distance [expr sqrt($DX * $DX + $DY * $DY)]
		 if {$distance <= [dict get $D_planet radius]} {
			 return 1
			}
		}

	return 0
}

#___________________________________________________________________________________________________________________________________________
method SWL_FC Collision_with_ships {x y} {
	 dict for {id_player D_player} $this(D_players) {
		 dict for {id_ship D_ship} [dict get $D_player D_ships] {
			 # Collision with this ship?
			 set DX [expr [dict get $D_ship x] - $x]
			 set DY [expr [dict get $D_ship y] - $y]
			 set distance [expr sqrt($DX * $DX + $DY * $DY)]
			 if {$distance <= [dict get $D_ship radius]} {
				 # remove the ship
				 this Destroy_ship $id_player $id_ship
				 return 1
				}
			}
		}
	return 0
}

#___________________________________________________________________________________________________________________________________________
method SWL_FC Compute_acceleration_at {x y} {
	set ax 0; set ay 0
	dict for {id_planet D_planet} $this(D_planets) {
		 set DX [expr [dict get $D_planet x] - $x]
		 set DY [expr [dict get $D_planet y] - $y]
		 set distance [expr sqrt($DX * $DX + $DY * $DY)]
		 if {$distance < 0.000001} {continue}
		 set M        [dict get $D_planet mass]
		 set D        [expr $distance * $distance]
		 set ax [expr $ax + $DX * $M / ($D * $distance)]
		 set ay [expr $ay + $DY * $M / ($D * $distance)]
		}

	return [list $ax $ay]
}

#___________________________________________________________________________________________________________________________________________
method SWL_FC Compute_a_simulation_step {} {
	# Compute bullets moves
	set new_L_bullets [list]
	foreach {id x y vx vy} $this(L_bullets) {
		 # Compute collision with ships
		 if {[this Collision_with_ships   $x $y]} {continue}
		 # Compute collision with planets
		 if {[this Collision_with_planets $x $y]} {continue}
		 # Compute acceleration
		 lassign [this Compute_acceleration_at $x $y] ax ay
		 # Update velocity
		 set vx [expr $vx + $this(dt)*$ax]; set vy [expr $vy + $this(dt)*$ay]
		 # Move the bullet
		 set x [expr $x + $vx * $this(dt)]; set y [expr $y + $vy * $this(dt)]
		 # Append the bullet to the new list of bullets
		 lappend new_L_bullets $id $x $y $vx $vy
		}
	set this(L_bullets) $new_L_bullets

	# Prepare a new step if needed
	if {[llength $this(L_bullets)] > 0 && !$this(interupt_simulation)} {
		 after $this(simulation_step) [list $objName Compute_a_simulation_step]
		}
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________ Planets _______________________________________________________________
#___________________________________________________________________________________________________________________________________________
method SWL_FC Add_new_planet {x y radius density} {
	set id [this generate_uid "pt"]
	dict set this(D_planets) $id ""
	this Update_planet $id [dict create x $x y $y radius $radius density $density]
	return $id
}

#___________________________________________________________________________________________________________________________________________
method SWL_FC Destroy_planet {id} {
	if {![dict exists $this(D_planets) $id]} {error "There is no planet identified by $id\nPlanets are: $this(D_planets)"}
	dict unset $this(D_planets) $id
}

#___________________________________________________________________________________________________________________________________________
method SWL_FC Update_planet {id D_update} {
	if {![dict exists $this(D_planets) $id]} {error "There is no planet identified by $id\nPlanets are: $this(D_planets)"}
	dict for {k v} $D_update {dict set this(D_planets) $id $k $v}
	set R [dict get $this(D_planets) $id radius ]
	set D [dict get $this(D_planets) $id density]
	dict set this(D_planets) $id mass [expr $R * $R * 3.1415 * $D]
}

#___________________________________________________________________________________________________________________________________________
#__________________________________________________________________ Players ________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method SWL_FC Add_new_player {name} {
	set id [this generate_player_uid "p"]
	dict set this(D_players) $id [dict create name $name D_ships [dict create]]
	return $id
}

#___________________________________________________________________________________________________________________________________________
method SWL_FC Destroy_player {id} {
	if {![dict exists $this(D_players) $id]} {error "There is no player identified by $id\nPlayers are: $this(D_players)"}
	dict unset this(D_players) $id
}

#___________________________________________________________________________________________________________________________________________
method SWL_FC Update_player {id D_update} {
	if {![dict exists $this(D_players) $id]} {error "There is no player identified by $id\nPlayers are: $this(D_players)"}
	dict for {k v} $D_update {dict set this(D_players) $id $k $v}
}

#___________________________________________________________________________________________________________________________________________
#__________________________________________________________________ Ships__ ________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method SWL_FC Add_new_ship {id_player x y radius} {
	if {![dict exists $this(D_players) $id_player]} {error "There is no player identified by $id_player\nPlayers are: $this(D_players)"}
	set id [this generate_uid "s"]
	dict set this(D_players) $id_player D_ships $id [dict create x $x y $y radius $radius energy 100 fire_velocity 0 fire_angle 0]
	return $id
}

#___________________________________________________________________________________________________________________________________________
method SWL_FC Destroy_ship {id_player id} {
	if {![dict exists $this(D_players) $id_player]} {error "There is no player identified by $id_player\nPlayers are: $this(D_players)"}
	if {![dict exists $this(D_players) $id_player D_ships $id]} {error "There is no ship identified by $id for player $id_player\nHis ships are: [dict get $this(D_players) $id_player D_ships]"}
	dict unset this(D_players) $id_player D_ships $id
}

#___________________________________________________________________________________________________________________________________________
method SWL_FC Update_ship {id_player id D_update} {
	if {![dict exists $this(D_players) $id_player]} {error "There is no player identified by $id_player\nPlayers are: $this(D_players)"}
	if {![dict exists $this(D_players) $id_player D_ships $id]} {error "There is no ship identified by $id for player $id_player\nHis ships are: [dict get $this(D_players) $id_player D_ships]"}
	dict for {k v} $D_update {dict set this(D_players) $id_player D_ships $id $k $v}
}


#___________________________________________________________________________________________________________________________________________
#_______________________________________________________________ Subscribers _______________________________________________________________
#___________________________________________________________________________________________________________________________________________
proc Generate_SWL_FC_subscriber {C L_methods} {
	foreach M $L_methods {
		 # Rename the original method
		 method $C Original_$M [gmlObject info arglist $C $M] [gmlObject info body $C $M]

		 # Redefine the method so that Callbacks are called
		 set ARGS [list]; foreach a [gmlObject info args $C $M] {append ARGS " \$[lindex $a 0]"}
		 method $C $M [gmlObject info arglist $C $M] "
			 dict for {key_ofthe_CB_$M value_of_the_CB_$M} \$this(D_CB_before_$M) {eval \$value_of_the_CB_$M}
			 set rep \[this Original_$M $ARGS\]
			 dict for {key_of_the_CB_$M value_of_the_CB_$M} \$this(D_CB_after_$M)  {eval \$value_of_the_CB_$M}
			 return \$rep
			"

		 # Generate Subscribers methods
		 method $C Subscribe_before_$M {id CB} "dict set this(D_CB_before_$M) \$id \$CB"
		 method $C Subscribe_after_$M  {id CB} "dict set this(D_CB_after_$M)  \$id \$CB"

		 # Add to the constructor Callback list attribute
		 method $C constructor [gmlObject info arglist $C constructor] "\tset this(D_CB_before_$M) \[dict create\]; set this(D_CB_after_$M) \[dict create\]\n[gmlObject info body $C constructor]"
		}
}

Generate_SWL_FC_subscriber SWL_FC [list Add_new_planet Destroy_planet Update_planet \
										Add_new_player Destroy_player Update_player \
										Add_new_ship   Destroy_ship   Update_ship   \
										Start_fire Compute_a_simulation_step \
										]