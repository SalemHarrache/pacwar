generate_pac_agent "Game"


# Noyau du jeu
generate_pac_accessors Game kernel
generate_simple_accessors GameControl players
generate_simple_accessors GameControl ships

# Univers
generate_simple_accessors GameControl universe
generate_simple_accessors GameControl panel
generate_simple_accessors GameControl sfx_manager

generate_pac_presentation_accessors Game canvas_map
generate_pac_presentation_accessors Game canvas_mini_map

generate_pac_presentation_accessors Game frame_wrapper
generate_pac_presentation_accessors Game frame_panel_players
generate_pac_presentation_accessors Game frame_panel_sound



# Mode d'affichage
generate_pac_presentation_accessors Game display_mode


# Abstraction  ##
method GameAbstraction init {} {
    this set_kernel [SWL_FC kernel]
    $this(kernel) Subscribe_after_Destroy_ship $objName "$this(control) destroy_ship_callback \$id"
    $this(kernel) Subscribe_after_Update_ship $objName "$this(control) update_ship_callback \$id \$D_update"
}

method GameAbstraction reset {} {
    $this(kernel) dispose
    this init
}

# Control  ##
method GameControl init {} {
    set this(universe) ""
    set this(panel) ""
    set this(sfx_manager) ""
    this set_players [dict create]
    this set_ships [dict create]
    bind . <Key-space>  "$objName start_fire"
}

method GameControl reset {} {
    this set_players [dict create]
    this set_ships [dict create]
    $this(abstraction) reset
    $this(universe) reset
    $this(panel) reset
    $this(sfx_manager) reset
}

method GameControl add_player {name position_x position_y} {
    set kernel [this get_kernel]
    set player_id [$kernel Add_new_player $name]
    set ship_id [$kernel Add_new_ship $player_id $position_x $position_y 50]
    dict set this(players) $player_id $ship_id
    dict set this(ships) $ship_id $player_id
    $kernel Update_ship $player_id $ship_id \
                [dict create x $position_x y $position_y]
}

method GameControl add_planet {position_x position_y radius density} {
    [this get_kernel] Add_new_planet $position_x $position_y $radius $density
}


method GameControl send_event_from_player {event player_id} {
    set ship_id [dict get $this(players) $player_id]
    $this(universe) send_event_to_ship $event $ship_id
}

method GameControl destroy_ship_callback {ship_id} {
    set player_id [dict get $this(ships) $ship_id]
    [this get_kernel] Destroy_player $player_id
    set this(ships) [dict remove $this(ships) $ship_id]
    set this(players) [dict remove $this(players) $player_id]
}

method GameControl update_ship_callback {ship_id D_update} {
    set player_id [dict get $this(ships) $ship_id]
    set x [dict get $D_update x]
    set y [dict get $D_update y]
    if {$this(panel) != ""} {
        $this(panel) send_position_to_player $player_id "($x , $y)"
    }
}

method GameControl start_fire {} {
    foreach {ship_id player}  $this(ships) {
        $this(universe) send_event_to_ship "shut" $ship_id
    }
    [this get_kernel] Start_fire
}


method GameControl gameover {} {
    if {$this(sfx_manager) != ""} {
        $this(sfx_manager) set_mode "end"
    }
}


# Presentation  ##
method GamePresentation init {} {
    global VERSION
    wm aspect $this(tk_parent) 3 2 3 2
    wm title $this(tk_parent) "PacWar ! - $VERSION"
    wm minsize $this(tk_parent)  900 800
    this set_display_mode normal

    this set_canvas_map [canvas $this(tk_parent).canvas_map]
    this set_frame_wrapper [frame $this(tk_parent).frame_wrapper -relief raised -borderwidth 1]
    # On regroupe les le panel et la minimap dans une frame
    this set_canvas_mini_map [canvas $this(frame_wrapper).canvas_mini_map]
    this set_frame_panel_players [frame $this(frame_wrapper).frame_panel_players]
    this set_frame_panel_sound [frame $this(frame_wrapper).frame_panel_sound]


    pack $this(canvas_map) -expand 1 -side right -fill both
    pack $this(frame_wrapper) -side left -fill both
    pack $this(frame_panel_players) -expand 1 -fill both
    pack $this(frame_panel_sound) -expand 1 -fill both
    pack $this(canvas_mini_map) -fill both

    bind $this(tk_parent) <Control-Key-p> "$objName switch_display_mode; $objName refresh"
}

method GamePresentation destructor {} {
    destroy $this(tk_parent)
}

method GamePresentation switch_display_mode {} {
    if {[this get_display_mode] == "normal"} {
        this set_display_mode "fullscreen"
    } else {
        this set_display_mode "normal"
    }
}

method GamePresentation refresh {} {
    pack forget $this(frame_wrapper)
    if {$this(display_mode) == "normal"} {
        pack configure $this(frame_wrapper) -side left -fill both
    }
}