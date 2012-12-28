# Génération d'un agent pac multivue : MapUniverse et MiniMapUniverse
generate_pac_agent_multi_view "Universe" [list "Map" "MiniMap"]

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


method UniverseControl init {} {
    $this(parent) set_universe $objName
    set this(ships) [list]
}


method UniverseControl add_ship {name position_x position_y} {
    set new_ship [ShipControl ship_$name $objName ""]
    $new_ship set_position $position_x $position_y
    lappend this(ships) $new_ship
    return [$new_ship get_id]
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

method MapUniversePresentation init {} {
    this set_num_background 0
    this set_canvas_map [$this(control) get_parent_canvas_map]
    $this(canvas_map) configure -width 400 -height 200 -background "#191919"

    initBackground $this(canvas_map) [get_new_universe_bg]

    $this(canvas_map) create image 0 0 -anchor nw -image [get_random_planet_bg] -tag mobile

    $this(canvas_map) create image 0 0 -anchor nw -image [get_random_planet_bg] -tag mobile

    set cmd "
    $this(canvas_map) bind mobile <Button-1> {
        set selected \[$this(canvas_map) find closest %x %y\]
        set atx %x
        set aty %y
    }"

    append cmd "
    $this(canvas_map) bind mobile <B1-Motion> {
        set changed_x \[expr %x - \$atx\]
        set changed_y \[expr %y - \$aty\]
        $this(canvas_map) move \$selected \$changed_x \$changed_y
        set atx %x
        set aty %y
    }"
    eval $cmd

    bind $this(tk_parent) <Control-Key-b> "$objName switch_background"

}

method MapUniversePresentation switch_background {} {
    incr this(num_background)
    initBackground $this(canvas_map) [get_new_universe_bg $this(num_background)]
}

method MiniMapUniversePresentation init {} {
    this set_canvas_mini_map [$this(control) get_parent_canvas_mini_map]
    $this(canvas_mini_map) configure -width 200 -height 200 -background "#1E1E1E"

    set background_file [abspath ressources universe background_mini.jpg]
    set background [image create photo -file $background_file]
    $this(canvas_mini_map) create image 0 0 -anchor nw -image $background

}