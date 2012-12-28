
generate_pac_agent Player
generate_pac_accessors Player score
generate_pac_accessors Player id
generate_pac_accessors Player name


method PlayerAbstraction init {} {
    this set_name [lindex [split "$objName" "_"] [expr {[llength [split "$objName" "_"]] - 2}]]
    this set_id [get_new_id]
    this set_score 10
}


method PlayerPresentation init {} {
    set this(label) [label $this(tk_parent).label -justify right -text [this get_label_message]]
    pack $this(label) -expand 1 -fill both
}


method PlayerPresentation get_label_message {} {
    return "Joueur [this get_id] ([this get_name]): [this get_score]"
}


method PlayerPresentation refresh {} {
    set this(label) configure -text [this get_label_message]
}


method PlayerControl init {} {

}


method PlayerControl set_binding {config} {
    eval $config
}

method PlayerControl send_event {event} {
    $this(parent) send_event_from_player $event [this get_id]
}


method PlayerControl move_left {} {
    this send_event "move_left"
}

method PlayerControl move_right {} {
    this send_event "move_right"
}

method PlayerControl move_up {} {
    this send_event "move_up"
}

method PlayerControl move_down {} {
    this send_event "move_down"
}

method PlayerControl shut {} {
    this send_event "shut"
}