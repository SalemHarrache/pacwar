
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