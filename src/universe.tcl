# Génération d'un agent pac multivue : Universe + MapUniverse et MiniMapUniverse
generate_pac_agent_multi_view "Universe" [list "Map" "MiniMap"]

generate_pac_accessors Universe kernel

generate_pac_presentation_accessors MapUniverse canvas_map
generate_pac_presentation_accessors MapUniverse num_background
generate_pac_presentation_accessors MiniMapUniverse canvas_mini_map


# UniverseAbstraction
method UniverseAbstraction init {} {
    this set_kernel [$this(control) get_parent_value kernel]
    $this(kernel) Subscribe_after_Add_new_planet $objName "$this(control) add_planet_callback \$rep \$x \$y \$radius \$density"
    $this(kernel) Subscribe_after_Add_new_ship $objName "$this(control) add_ship_callback \$rep \$x \$y \$radius \$id_player"
    $this(kernel) Subscribe_after_Start_fire $objName "$this(control) start_fire_callback \$rep \$this(L_bullets)"
    $this(kernel) Subscribe_after_Compute_a_simulation_step $objName "$this(control) update_fire_callback \$rep \$this(L_bullets)"
    $this(kernel) Subscribe_after_Destroy_ship $objName "$this(control) destroy_ship_callback \$id"
    $this(kernel) Subscribe_after_Destroy_planet $objName "$this(control) destroy_planet_callback \$id"
}

# UniverseControl
method UniverseControl init {} {
    $this(parent) set_universe $objName
    set this(ships) [dict create]
    set this(planets) [dict create]
}

method UniverseControl add_ship_callback {id x y radius player_id} {
    set new_ship [ShipControl $id $objName ""]
    $new_ship set_position_x $x
    $new_ship set_position_y $y
    $new_ship set_radius $radius
    $new_ship set_player_id $player_id
    $new_ship draw
    dict set this(ships) [$new_ship get_id] $new_ship
}

method UniverseControl add_planet_callback {id x y radius density} {
    set new_planet [PlanetControl $id $objName ""]
    $new_planet set_radius $radius
    $new_planet set_density $density
    $new_planet set_position_x $x
    $new_planet set_position_y $y
    $new_planet draw
    dict set this(planets) [$new_planet get_id] $new_planet
}

method UniverseControl start_fire_callback {rep L_bullets} {
    $this(map) create_bullets $rep $L_bullets
}

method UniverseControl update_fire_callback {rep L_bullets} {
    $this(map) update_bullets $rep $L_bullets
}

method UniverseControl destroy_ship_callback {id} {
    set ship [dict get $this(ships) $id]
    set this(ships) [dict remove $this(ships) $id]
    $ship dispose
}

method UniverseControl destroy_planet_callback {id} {
    set planet [dict get $this(planets) $id]
    set this(planets) [dict remove $this(planets) $id]
    $planet dispose
}

method UniverseControl send_event_to_ship {event ship_id} {
    [dict get $this(ships) $ship_id] $event
}


# MapUniverseControl ##
method MapUniverseControl create_bullets {rep L_bullets} {
    $this(presentation) create_bullets $rep $L_bullets
}

method MapUniverseControl update_bullets {rep L_bullets} {
    $this(presentation) update_bullets $rep $L_bullets
}


# MapUniversePresentation ##
method MapUniversePresentation init {} {
    this set_num_background 0
    this set_canvas_map [$this(control) get_parent_value canvas_map]
    $this(canvas_map) configure -width 400 -height 200 -background "#191919"

    initBackground $this(canvas_map) [get_new_universe_bg]

    bind $this(tk_parent) <Control-Key-b> "$objName switch_background"
}

method MapUniversePresentation switch_background {} {
    incr this(num_background)
    initBackground $this(canvas_map) [get_new_universe_bg $this(num_background)]
}

method MapUniversePresentation create_bullets {rep L_bullets} {
    $this(canvas_map) delete Bullet
    set radius 5
    foreach {id x y vx vy} $L_bullets {
         $this(canvas_map) create oval [expr $x - $radius] [expr $y - $radius] [expr $x + $radius] [expr $y + $radius] -fill red -tags [list Bullet $id]
    }
}

method MapUniversePresentation update_bullets {rep L_bullets} {
    set radius 5
    foreach {id x y vx vy} $L_bullets  {
         $this(canvas_map) coords $id [expr $x - $radius] [expr $y - $radius] [expr $x + $radius] [expr $y + $radius]
    }
}


# MiniMapUniversePresentation ##
method MiniMapUniversePresentation init {} {
    this set_canvas_mini_map [$this(control) get_parent_value canvas_mini_map]
    $this(canvas_mini_map) configure -width 200 -height 200 -background "#1E1E1E"

    set background_file [abspath .. ressources universe background_mini.jpg]
    set background [image create photo -file $background_file]
    $this(canvas_mini_map) create image 0 0 -anchor nw -image $background

}