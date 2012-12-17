source [file join [file dirname [info script]] . lib init.tcl]


generate_pac_agent_multi_view "Universe" [list "Map" "MiniMap"]

generate_pac_parent_accessors Universe canvas_map
generate_pac_accessors MapUniverse canvas_map
generate_pac_parent_accessors MapUniverse canvas_map


method MapUniversePresentation init {} {
    # this set_canvas_map [$this(control) get_parent_canvas_map]
    # this set_canvas_map [$this(parent) get_canvas_map]

    # $this(canvas_map)

    # [canvas $this(tk_parent).canvas_map -width 400 \
    #                         -height 200 -background "#191919" ]
}