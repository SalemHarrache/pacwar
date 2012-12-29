# Génération d'un agent Panel
generate_pac_agent "Panel"

generate_pac_parent_accessors "Panel" kernel
generate_pac_accessors "Panel" kernel

generate_pac_accessors "Panel" volume_level

generate_pac_presentation_accessors "Panel" frame_panel
generate_pac_parent_accessors "Panel" frame_panel


# UniverseAbstraction ##
method PanelAbstraction init {} {
    this set_kernel [$this(control) get_parent_kernel]
    $this(kernel) Subscribe_after_Add_new_player A "$this(control) add_player_callback \$rep \$name"
}


method PanelControl init {} {
     $this(parent) set_panel $objName
     set this(players) [list]
}


method PanelControl sound_changed {v} {
    this user_change_volume_level $v
}


method PanelControl add_player_callback {id name} {
    set new_player [PlayerControl ${id}_${name} $objName [$this(presentation) get_new_player_frame]]
    $new_player set_binding
    lappend this(players) $new_player
    $this(presentation) refresh
}


method PanelControl get_player {id} {
    foreach player  $this(players) {
        if {[$player get_id] == $id} {
            return $player
        }
    }
}


method PanelControl send_event_from_player {event id} {
    $this(parent) send_event_from_player $event $id
}

method PanelPresentation init {} {
    this set_frame_panel [$this(control) get_parent_frame_panel]
    set this(player_frames) {}
    set this(volume_label) [label $this(frame_panel).volume_label -justify center -text "Volume : "]
    this refresh
}


method PanelPresentation get_new_player_frame {} {
    set new_frame [frame $this(frame_panel).frame_[llength $this(player_frames)]]
    lappend this(player_frames) $new_frame
    return $new_frame
}


method PanelPresentation refresh {} {
    pack forget $this(volume_label)
    foreach frame $this(player_frames) {
        pack forget $frame
    }
    foreach frame $this(player_frames) {
        pack configure $frame  -expand 1
    }
    pack configure $this(volume_label) -expand 1
}


method PanelPresentation set_volume_level {v} {
    $this(volume_label) configure -text "Volume :  $v"
}