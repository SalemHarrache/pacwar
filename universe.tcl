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
    $this(kernel) Subscribe_after_Add_new_ship A "$this(control) add_ship_callback \$rep \$x \$y \$radius \$id_player"
    $this(kernel) Subscribe_after_Start_fire A "$this(control) start_fire_callback \$rep \$this(L_bullets)"
    $this(kernel) Subscribe_after_Compute_a_simulation_step A "$this(control) update_fire_callback \$rep \$this(L_bullets)"
    $this(kernel) Subscribe_after_Destroy_ship A "$this(control) destroy_ship_callback \$id"
    $this(kernel) Subscribe_after_Destroy_planet A "$this(control) destroy_planet_callback \$id"
}

# UniverseControl ##
method UniverseControl init {} {
    $this(parent) set_universe $objName
    set this(ships) [list]
    set this(planets) [list]
}

method UniverseControl add_ship_callback {id x y radius player_id} {
    set new_ship [ShipControl $id $objName ""]
    $new_ship set_position_x $x
    $new_ship set_position_y $y
    $new_ship set_radius $radius
    $new_ship set_player_id $player_id
    $new_ship draw
    lappend this(ships) $new_ship
}

method UniverseControl add_planet_callback {id x y radius density} {
    set new_planet [PlanetControl $id $objName ""]
    $new_planet set_radius $radius
    $new_planet set_density $density
    $new_planet set_position_x $x
    $new_planet set_position_y $y
    $new_planet draw
    lappend this(planets) $new_planet
}

method UniverseControl start_fire_callback {rep L_bullets} {
    $this(map) create_bullets $rep $L_bullets
}

method UniverseControl update_fire_callback {rep L_bullets} {
    $this(map) update_bullets $rep $L_bullets
}

method UniverseControl destroy_ship_callback {id} {
    set ship [this get_ship $id]
    if {$ship !=""} {
        set this(ships) [lremove $this(ships) $ship]
        $ship dispose
    }
}

method UniverseControl destroy_planet_callback {id} {
    set planet [this get_planet $id]
    if {$planet !=""} {
        set this(planets) [lremove $this(planets) $planet]
        $planet dispose
    }
}

method UniverseControl get_planet {id} {
    foreach planet  $this(planets) {
        if {[$planet get_id] == $id} {
            return $planet
        }
    }
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
method MapUniverseControl create_bullets {rep L_bullets} {
    $this(presentation) create_bullets $rep $L_bullets
}

method MapUniverseControl update_bullets {rep L_bullets} {
    $this(presentation) update_bullets $rep $L_bullets
}

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

method MapUniversePresentation create_bullets {rep L_bullets} {
    $this(canvas_map) delete Bullet
    set radius 10
    foreach {id x y vx vy} $L_bullets {
         $this(canvas_map) create oval [expr $x - $radius] [expr $y - $radius] [expr $x + $radius] [expr $y + $radius] -fill red -tags [list Bullet $id]
    }
}

method MapUniversePresentation update_bullets {rep L_bullets} {
    set radius 10
    foreach {id x y vx vy} $L_bullets  {
         $this(canvas_map) coords $id [expr $x - $radius] [expr $y - $radius] [expr $x + $radius] [expr $y + $radius]
    }
}


# MiniMapUniversePresentation ##
method MiniMapUniversePresentation init {} {
    this set_canvas_mini_map [$this(control) get_parent_canvas_mini_map]
    $this(canvas_mini_map) configure -width 200 -height 200 -background "#1E1E1E"

    set background_file [abspath ressources universe background_mini.jpg]
    set background [image create photo -file $background_file]
    $this(canvas_mini_map) create image 0 0 -anchor nw -image $background

}