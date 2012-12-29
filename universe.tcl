# Génération d'un agent pac multivue : MapUniverse et MiniMapUniverse
generate_pac_agent_multi_view "Universe" [list "Map" "MiniMap"]

generate_pac_parent_accessors Universe kernel
generate_pac_accessors Universe kernel
# Génération d'un methode pour acceder au canvas_map parent depuis universe.
generate_pac_parent_accessors Universe canvas_map
generate_pac_parent_accessors Universe canvas_mini_map
# Génération d'un methode pour acceder au canvas_map parent depuis les deux
# vues de l'argent universe : MapUniverse et MiniMapUniverse
generate_pac_parent_accessors MapUniverse canvas_map
generate_pac_parent_accessors MiniMapUniverse canvas_mini_map
# Generation des accesseurs pour les attributs
generate_pac_presentation_accessors MapUniverse canvas_map
generate_pac_presentation_accessors MapUniverse num_background
generate_pac_presentation_accessors MiniMapUniverse canvas_mini_map


# UniverseAbstraction ##
method UniverseAbstraction init {} {
    this set_kernel [$this(control) get_parent_kernel]
    $this(kernel) Subscribe_after_Add_new_planet A "$this(control) add_planet_callback \$rep \$x \$y \$radius \$density"
    # $this(kernel) Subscribe_after_Update_planet A "$this(control) update_planet \$id \$D_update"
    $this(kernel) Subscribe_after_Add_new_ship A "$this(control) add_ship_callback \$rep \$x \$y \$radius"
    # $this(kernel) Subscribe_after_Update_ship A "$this(control) update_ship \$id \$D_update"
    # $this(kernel) Subscribe_after_Start_fire A "$this(control) start_fire \$rep \$this(L_bullets)"
    # $this(kernel) Subscribe_after_Compute_a_simulation_step A "$this(control) update_fire \$rep \$this(L_bullets)"
    # $this(kernel) Subscribe_after_Destroy_ship A "$this(control) destroy_ship \$rep \$id"
}

# UniverseControl ##
method UniverseControl init {} {
    $this(parent) set_universe $objName
    set this(ships) [list]
}

method UniverseControl add_ship_callback {id x y r} {
    set new_ship [ShipControl $id $objName ""]
    $new_ship set_position $x $y
    lappend this(ships) $new_ship
}

method UniverseControl add_planet_callback {id x y radius density} {
    set new_planet [PlanetControl $id $objName ""]
    $new_planet set_radius $radius
    $new_planet set_density $density
    $new_planet set_position_x $x
    $new_planet set_position_y $y
    $new_planet draw
}


method UniverseControl get_ship {id} {
    foreach ship  $this(ships) {
        if {[$ship get_id] == $id} {
            return $ship
        }
    }
}

method UniverseControl send_event_to_ship {event ship_id} {
    [this get_ship $ship_id] $event
}


# MapUniversePresentation ##
method MapUniversePresentation init {} {
    this set_num_background 0
    this set_canvas_map [$this(control) get_parent_canvas_map]
    $this(canvas_map) configure -width 400 -height 200 -background "#191919"

    initBackground $this(canvas_map) [get_new_universe_bg]

    bind $this(tk_parent) <Control-Key-b> "$objName switch_background"

}

method MapUniversePresentation switch_background {} {
    incr this(num_background)
    initBackground $this(canvas_map) [get_new_universe_bg $this(num_background)]
}


# MiniMapUniversePresentation ##
method MiniMapUniversePresentation init {} {
    this set_canvas_mini_map [$this(control) get_parent_canvas_mini_map]
    $this(canvas_mini_map) configure -width 200 -height 200 -background "#1E1E1E"

    set background_file [abspath ressources universe background_mini.jpg]
    set background [image create photo -file $background_file]
    $this(canvas_mini_map) create image 0 0 -anchor nw -image $background

}