generate_pac_agent "Game"


# Noyau du jeu
generate_pac_accessors Game kernel
generate_simple_accessors GameControl players
generate_simple_accessors GameControl ships

# Univers
generate_simple_accessors GameControl universe
generate_simple_accessors GameControl panel
# Pour gerer le son depuis Game
generate_simple_accessors GameControl sfx_manager


# Sert a afficher la map
generate_pac_presentation_accessors Game canvas_map
# Sert a afficher la mini map
generate_pac_presentation_accessors Game canvas_mini_map
# Sert a afficher le panel
generate_pac_presentation_accessors Game frame_panel
# Sert juste à regrouper le panel et la mini map
generate_pac_presentation_accessors Game frame_wrapper
# Mode d'affichage
generate_pac_presentation_accessors Game display_mode
# Pour gerer l'activation ou pas de la musique dans le jeu
generate_pac_presentation_accessors Game mute


method GameAbstraction init {} {
    this set_kernel [SWL_FC kernel]
    $this(kernel) Subscribe_after_Destroy_ship $objName "$this(control) destroy_ship_callback \$id"
}


method GameControl init {} {
    this set_players [dict create]
    this set_ships [dict create]
    bind . <Key-space>  "$objName start_fire"
}


method GameControl toggle_sound {} {
    $this(sfx_manager) toggle_sound
}


method GameControl sound_changed {v} {
    $this(panel) sound_changed $v
}


method GameControl add_player {name position_x position_y} {
    set player_id [[this get_kernel] Add_new_player $name]
    set ship_id [[this get_kernel] Add_new_ship $player_id $position_x $position_y 50]
    dict set this(players) $player_id $ship_id
    dict set this(ships) $ship_id $player_id
}

method GameControl add_planet { position_x position_y radius density} {
    [this get_kernel] Add_new_planet $position_x $position_y $radius $density
}


method GameControl send_event_from_player {event player_id} {
    set ship_id [dict get $this(players) $player_id]
    $this(universe) send_event_to_ship $event $ship_id
}

method GameControl destroy_ship_callback {ship_id} {
    # set player_id [this get_player_from_player $ship_id]
    # set ship_id [[this get_kernel] Add_new_ship $player_id 0 0 50]
    # lappend this(ships) $ship_id
    puts "GameControl destroy_ship_callback"
}


method GameControl start_fire {} {
    foreach {ship_id player}  $this(ships) {
        $this(universe) send_event_to_ship "shut" $ship_id
    }
    [this get_kernel] Start_fire
}


method GamePresentation init {} {
    wm aspect $this(tk_parent) 3 2 3 2
    wm title $this(tk_parent) "PacWar !"
    this set_display_mode vertical

    this set_canvas_map [canvas $this(tk_parent).canvas_map]
    this set_frame_wrapper [frame $this(tk_parent).frame_wrapper -relief raised -borderwidth 1]
    # On regroupe les le panel et la minimap dans une frame
    this set_canvas_mini_map [canvas $this(frame_wrapper).canvas_mini_map]
    this set_frame_panel [frame $this(frame_wrapper).frame_panel]


    pack $this(canvas_map) -expand 1 -side right -fill both
    pack $this(frame_wrapper) -side left -fill both
    pack $this(frame_panel) -expand 1 -fill both
    pack $this(canvas_mini_map) -fill both

    bind $this(tk_parent) <Control-Key-p> "$objName switch_view_mode; $objName refresh"
}

method GamePresentation switch_view_mode {} {
    if {[this get_display_mode] == "vertical"} {
        this set_display_mode "horizontal"
    } else {
        this set_display_mode "vertical"
    }
}

method GamePresentation refresh {} {
    pack forget $this(canvas_map) $this(frame_wrapper) $this(frame_panel) $this(canvas_mini_map)
    if {$this(display_mode) == "vertical"} {
        pack configure $this(canvas_map)  -expand 1 -side right -fill both
        pack configure $this(frame_wrapper) -side left -fill both
        pack configure $this(frame_panel) -expand 1 -fill both
        pack configure $this(canvas_mini_map) -fill both
    } else {
        pack configure $this(frame_wrapper) -side right -fill both
        pack configure $this(frame_panel) -expand 1 -fill both
        pack configure $this(canvas_mini_map) -fill both
        pack configure $this(canvas_map)  -expand 1 -side right -fill both
    }
}