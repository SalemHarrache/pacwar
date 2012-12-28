
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


method ShipAbstraction init {} {
    this set_name [lindex [split "$objName" "_"] [expr {[llength [split "$objName" "_"]] - 2}]]
    this set_id [get_new_id]
}

method ShipControl init {} {
    # this(map) add_ship $name
    # this set_canvas_map [$this(control) get_parent_canvas_map]
    # return [$this(canvas_map) create image 0 0 -anchor nw -image [get_ship_bg $name] -tag mobile]
}

method ShipControl decr_ang {} {
    puts "decr_ang"
}

method ShipControl incr_ang {} {
    puts "incr_ang"
}

method ShipControl speed_up {} {
    puts "speed_up"
}

method ShipControl speed_down {} {
    puts "speed_down"
}

method ShipControl shut {} {
    puts "shut"
}

method MapShipPresentation init {} {
    this set_name [$this(control) get_parent_name]
    this set_id "map_ship_[$this(control) get_parent_id]"
    this set_canvas_map [$this(control) get_parent_canvas_map]
    $this(canvas_map) create image 0 0 -anchor nw -image [get_ship_bg $this(name)] -tag $this(id)
}

method MiniMapShipPresentation init {} {
    this set_name [$this(control) get_parent_name]
    this set_id "mini_map_ship_[$this(control) get_parent_id]"
    this set_canvas_mini_map [$this(control) get_parent_canvas_mini_map]
    $this(canvas_mini_map) create oval 0 0 10 10 -outline [get_random_color] -fill [get_random_color]
}