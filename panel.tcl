# Génération d'un agent Panel
generate_pac_agent "Panel"

generate_pac_accessors "Panel" volume_level
generate_pac_presentation_accessors "Panel" frame_panel
generate_pac_parent_accessors "Panel" frame_panel

method PanelPresentation init {} {
    this set_frame_panel [$this(control) get_parent_frame_panel]
    set this(label) [label $this(frame_panel).label -justify center -text "Joueur X"]
    set this(volume_label) [label $this(frame_panel).volume_label -justify center -text "Volume : "]
    pack configure $this(label) -expand 1 -fill both
    pack configure $this(volume_label) -expand 1 -fill both
}

method PanelPresentation set_volume_level {v} {
    $this(volume_label) configure -text "Volume :  $v"
}

method PanelControl init {} {
     $this(parent) set_panel $objName
}


method PanelControl sound_changed {v} {
    this user_change_volume_level $v
}