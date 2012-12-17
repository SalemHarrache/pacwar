# Génération d'un agent Panel
generate_pac_agent "Panel"

generate_pac_parent_accessors "Panel" frame_panel
generate_pac_presentation_accessors "Panel" frame_panel

method PanelPresentation init {} {
    this set_frame_panel [$this(control) get_parent_frame_panel]
    set this(label) [label $this(frame_panel).label -justify center -text "Joueur X"]
    pack configure $this(label) -expand 1 -fill both
    # $this(frame_map) configure -width 400 -height 200 -background "#191919"
}
