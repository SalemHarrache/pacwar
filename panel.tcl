# Génération d'un agent Panel
generate_pac_agent "Panel"

generate_pac_accessors "Panel" volume_level
generate_pac_presentation_accessors "Panel" frame_panel
generate_pac_parent_accessors "Panel" frame_panel

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

method PanelControl init {} {
     $this(parent) set_panel $objName
     set this(players) {}
}

method PanelControl sound_changed {v} {
    this user_change_volume_level $v
}

method PanelControl add_player {name config} {
    set new_player [PlayerControl player_$name $objName [$this(presentation) get_new_player_frame]]
    $new_player set_binding $config
    lappend $this(players) $new_player
    $this(presentation) refresh
}


method PanelControl get_player {id} {
    foreach player  $this(players) {
        if {[$player get_id] == $id} {
            return player
        }
    }
}