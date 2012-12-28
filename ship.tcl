
generate_pac_agent_multi_view Ship [list "Map" "MiniMap"]
generate_pac_accessors Ship id
generate_pac_accessors Ship name
generate_pac_parent_accessors Ship canvas_map
generate_pac_parent_accessors Ship canvas_mini_map


generate_pac_parent_accessors MapShip canvas_map
generate_pac_parent_accessors MiniMapShip canvas_mini_map
generate_pac_presentation_accessors MapShip canvas_map
generate_pac_presentation_accessors MiniMapShip canvas_mini_map

generate_pac_parent_accessors MapShip name
generate_pac_parent_accessors MiniMapShip name
generate_pac_presentation_accessors MapShip name
generate_pac_presentation_accessors MiniMapShip name

generate_pac_parent_accessors MapShip id
generate_pac_parent_accessors MiniMapShip id
generate_pac_presentation_accessors MapShip id
generate_pac_presentation_accessors MiniMapShip id

generate_pac_presentation_accessors MapShip radius
generate_pac_presentation_accessors MiniMapShip radius

proc move_canvas {w wid x y} {
    set movement {}
    foreach {xx yy} [$w coords $wid] {
        lappend movement [expr {$xx + $x}] [expr {$yy + $y}]
    }
    $w coords $wid $movement
}



method ShipAbstraction init {} {
    this set_name [lindex [split "$objName" "_"] [expr {[llength [split "$objName" "_"]] - 2}]]
    this set_id [get_new_id]
}

method ShipControl init {} {
}

method ShipControl move_left {} {
    $this(map)  move -1 0
    $this(minimap)  move -1 0
}

method ShipControl move_right {} {
    $this(map)  move 1 0
    $this(minimap)  move 1 0
}

method ShipControl move_up {} {
    $this(map)  move 0 -1
    $this(minimap)  move 0 -1
}

method ShipControl move_down {} {
    $this(map)  move 0 1
    $this(minimap)  move 0 1
}

method ShipControl shut {} {
    puts "shut"
}


method MapShipControl move {x y} {
    $this(presentation) move $x $y
}

method MapShipPresentation init {} {
    this set_name [$this(control) get_parent_name]
    this set_id "map_ship_[$this(control) get_parent_id]"
    this set_canvas_map [$this(control) get_parent_canvas_map]
    set bg [get_ship_bg $this(name)]
    this set_radius [expr int([image height $bg] / 2)]
    this set_id [$this(canvas_map) create image 100  100 -anchor nw -image [get_ship_bg $this(name)]]
}

method MapShipPresentation move {x y} {
    move_canvas $this(canvas_map) [this get_id] [expr $x * 10] [expr $y * 10]
}


method MiniMapShipControl move {x y} {
    $this(presentation) move $x $y
}

method MiniMapShipPresentation init {} {
    this set_name [$this(control) get_parent_name]
    this set_id "mini_map_ship_[$this(control) get_parent_id]"
    this set_canvas_mini_map [$this(control) get_parent_canvas_mini_map]
    set bg [get_ship_bg $this(name)]
    this set_radius 5
    this set_id [$this(canvas_mini_map) create oval 0 0 10 10 -outline [get_random_color] -fill [get_random_color]]
}

method MiniMapShipPresentation move {x y} {
    move_canvas $this(canvas_mini_map) [this get_id] $x $y
}