generate_pac_agent Player
generate_pac_accessors Player id
generate_pac_accessors Player name
generate_pac_accessors Player status


method PlayerAbstraction init {} {
    set infos [split "$objName" "_"]
    this set_name [lindex $infos [expr ([llength $infos] - 2)]]
    this set_id [lindex $infos [expr ([llength $infos] - 3)]]
    set this(status) 1
}

method PlayerPresentation init {} {
    set this(label) [label $this(tk_parent).label -justify right]
    pack $this(label) -expand 1 -fill both
    this refresh
}

method PlayerPresentation refresh {} {
    if {[this get_status] == 1} {
        $this(label) configure -text "Joueur [this get_id] ([this get_name]) : Alive"
    } else {
        $this(label) configure -text "Joueur [this get_id] ([this get_name]) : Dead" -foreground red
    }
}

method PlayerPresentation set_status {v} {
    this refresh
}

method PlayerControl set_binding {} {
    eval [get_[this get_id]_control]
}

method PlayerControl send_event {event} {
    if {[this get_status] == 1} {
        $this(parent) send_event_from_player $event [this get_id]
    }
}