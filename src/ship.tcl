generate_pac_agent_multi_view Ship [list "Map" "MiniMap"]
generate_pac_accessors Ship id
generate_pac_accessors Ship position_x
generate_pac_accessors Ship position_y
generate_pac_accessors Ship player_id
generate_pac_accessors Ship radius

generate_pac_parent_accessors Ship kernel
generate_pac_accessors Ship kernel

generate_pac_parent_accessors Ship canvas_map
generate_pac_parent_accessors Ship canvas_mini_map

generate_pac_parent_accessors MapShip canvas_map
generate_pac_parent_accessors MiniMapShip canvas_mini_map

generate_pac_presentation_accessors MapShip canvas_map
generate_pac_presentation_accessors MapShip bg_image
generate_pac_presentation_accessors MiniMapShip canvas_mini_map

generate_pac_parent_accessors MapShip id
generate_pac_parent_accessors MiniMapShip id
generate_pac_presentation_accessors MapShip id
generate_pac_presentation_accessors MiniMapShip id


method ShipAbstraction init {} {
    this set_id [lindex [split "$objName" "_"] 0]
    this set_kernel [$this(control) get_parent_kernel]
}

method ShipControl draw {} {
    [$this(map) attribute presentation] draw [this get_position_x] [this get_position_y] [this get_radius]
    [$this(minimap) attribute presentation] draw [expr ([this get_position_x] / 10)] \
                                                 [expr ([this get_position_y] / 10)] \
                                                 [expr ([this get_radius] / 10)]
}

method ShipControl move {x y} {
    [$this(map) attribute presentation] move $x $y
    [$this(minimap) attribute presentation] move $x $y
    this set_position_x [expr [this get_position_x] + [expr $x * 10]]
    this set_position_y [expr [this get_position_y] + [expr $y * 10]]
    [this get_kernel] Update_ship [this get_player_id] [this get_id] \
                                  [dict create x [this get_position_x] y [this get_position_y]]
}

method ShipControl move_left {} {
    this move -1 0
}

method ShipControl move_right {} {
    this move 1 0
}

method ShipControl move_up {} {
    this move 0 -1
}

method ShipControl move_down {} {
    this move 0 1
}

method ShipControl get_fire_angle {} {
    return [to_radian [expr ([lindex [split [this get_id] ""] 1] % 2) * 180 + 90]]
}

method ShipControl shut {} {
    [this get_kernel] Update_ship [this get_player_id] [this get_id] \
        [dict create fire_velocity 10 fire_angle [this get_fire_angle]]
}


# Map
method MapShipPresentation init {} {
    this set_canvas_map [$this(control) get_parent_canvas_map]
    set num [expr (([lindex [split [$this(control) get_parent_id] ""] 1]) % 2)]
    this set_bg_image [get_ship_bg "s$num"]
}

method MapShipPresentation draw {x y radius} {
    this set_id [$this(canvas_map) create image $x  $y -anchor center -image [this get_bg_image]]
}

method MapShipPresentation move {x y} {
    move_canvas $this(canvas_map) [this get_id] [expr $x * 10] [expr $y * 10]
}

method MapShipPresentation destructor {} {
    $this(canvas_map) delete [this get_id]
}

# MiniMap
method MiniMapShipPresentation init {} {
    this set_canvas_mini_map [$this(control) get_parent_canvas_mini_map]
}

method MiniMapShipPresentation draw {x y radius} {
    set x1 [expr $x - $radius]
    set y1 [expr $y - $radius]
    set x2 [expr $x + $radius]
    set y2 [expr $y + $radius]
    this set_id [$this(canvas_mini_map) create rect $x1 $y1 $x2 $y2 -outline #F00 -fill [get_random_color]]
}

method MiniMapShipPresentation move {x y} {
    move_canvas $this(canvas_mini_map) [this get_id] $x $y
}

method MiniMapShipPresentation delete {} {
    $this(canvas_mini_map) delete [this get_id]
}

method MiniMapShipPresentation destructor {} {
    this delete
}