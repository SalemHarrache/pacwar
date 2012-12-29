generate_pac_agent_multi_view Planet [list "Map" "MiniMap"]
generate_pac_accessors Planet id
generate_pac_accessors Planet name
generate_pac_parent_accessors Planet canvas_map
generate_pac_parent_accessors Planet canvas_mini_map


generate_pac_parent_accessors MapPlanet canvas_map
generate_pac_parent_accessors MiniMapPlanet canvas_mini_map
generate_pac_presentation_accessors MapPlanet canvas_map
generate_pac_presentation_accessors MiniMapPlanet canvas_mini_map

generate_pac_parent_accessors MapPlanet name
generate_pac_parent_accessors MiniMapPlanet name
generate_pac_presentation_accessors MapPlanet name
generate_pac_presentation_accessors MiniMapPlanet name

generate_pac_parent_accessors MapPlanet id
generate_pac_parent_accessors MiniMapPlanet id
generate_pac_presentation_accessors MapPlanet id
generate_pac_presentation_accessors MiniMapPlanet id

generate_pac_presentation_accessors MapPlanet radius
generate_pac_presentation_accessors MiniMapPlanet radius



method PlanetAbstraction init {} {
    this set_name [lindex [split "$objName" "_"] 1]
    this set_id $objName
}

method PlanetControl init {} {
}

method PlanetControl set_position {x y} {
    $this(map) set_position $x $y
    $this(minimap) set_position $x $y
}

method PlanetControl move_left {} {
    $this(map)  move -1 0
    $this(minimap)  move -1 0
}

method PlanetControl move_right {} {
    $this(map)  move 1 0
    $this(minimap)  move 1 0
}

method PlanetControl move_up {} {
    $this(map)  move 0 -1
    $this(minimap)  move 0 -1
}

method PlanetControl move_down {} {
    $this(map)  move 0 1
    $this(minimap)  move 0 1
}

method PlanetControl shut {} {
    puts "shut"
}


method MapPlanetControl move {x y} {
    $this(presentation) move $x $y
}

method MapPlanetControl set_position {x y} {
    $this(presentation) move $x $y
}

method MapPlanetPresentation init {} {
    this set_name [$this(control) get_parent_name]
    this set_id "map_ship_[$this(control) get_parent_id]"
    this set_canvas_map [$this(control) get_parent_canvas_map]
    set bg [get_ship_bg $this(name)]
    this set_radius [expr int([image height $bg] / 2)]
    this set_id [$this(canvas_map) create image 0  0 -anchor nw -image [get_ship_bg $this(name)]]
}

method MapPlanetPresentation move {x y} {
    move_canvas $this(canvas_map) [this get_id] [expr $x * 10] [expr $y * 10]
}


method MiniMapPlanetControl move {x y} {
    $this(presentation) move $x $y
}

method MiniMapPlanetControl set_position {x y} {
    $this(presentation) move $x $y
}

method MiniMapPlanetPresentation init {} {
    this set_name [$this(control) get_parent_name]
    this set_id "mini_map_ship_[$this(control) get_parent_id]"
    this set_canvas_mini_map [$this(control) get_parent_canvas_mini_map]
    set bg [get_ship_bg $this(name)]
    this set_radius 5
    this set_id [$this(canvas_mini_map) create oval 0 0 10 10 -outline [get_random_color] -fill [get_random_color]]
}

method MiniMapPlanetPresentation move {x y} {
    move_canvas $this(canvas_mini_map) [this get_id] $x $y
}