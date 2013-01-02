generate_pac_agent Player
generate_pac_accessors Player id
generate_pac_accessors Player name
generate_pac_accessors Player status
generate_pac_accessors Player position
generate_pac_parent_accessors Player kernel
generate_pac_parent_accessors Player frame_panel


method PlayerAbstraction init {} {
    set infos [split "$objName" "_"]
    this set_name [lindex $infos [expr ([llength $infos] - 2)]]
    this set_id [lindex $infos [expr ([llength $infos] - 3)]]
    set this(status) 1
    set this(position) "(0,0)"
}

method PlayerPresentation init {} {
    set this(label_status) [label $this(tk_parent).label_status -justify right]
    set this(label_position) [label $this(tk_parent).label_position -justify center]
    pack $this(label_status) -expand 1 -fill both
    pack $this(label_position) -expand 1 -fill both
    this set_status [this get_status]
    this set_position [this get_position]
}

method PlayerPresentation set_status {v} {
    if {$v == 1} {
        $this(label_status) configure -text "Player [this get_id] ([this get_name]) : Alive"
    } else {
        $this(label_status) configure -text "Player [this get_id] ([this get_name]) : Dead" -foreground red
        $this(label_position) configure -text "position : unknown"
    }
}

method PlayerPresentation set_position {v} {
    $this(label_position) configure -text "position : $v"
}

method PlayerControl set_binding {} {
    eval [get_p[expr ([lindex [split [this get_id] ""] 1] % 2) + 1]_control]
}

method PlayerControl send_event {event} {
    if {[this get_status] == 1} {
        $this(parent) send_event_from_player $event [this get_id]
    }
}