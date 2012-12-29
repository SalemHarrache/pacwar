
generate_pac_agent Player
generate_pac_accessors Player score
generate_pac_accessors Player id
generate_pac_accessors Player name


method PlayerAbstraction init {} {
    set infos [split "$objName" "_"] 
    this set_name [lindex $infos [expr ([llength $infos] - 2)]]
    this set_id "[lindex $infos [expr ([llength $infos] - 3)]]"
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

method PlayerControl set_binding {} {
    eval [get_[this get_id]_control]
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