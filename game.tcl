source [file join [file dirname [info script]] . lib init.tcl]

generate_pac_agent "Game"

generate_pac_presentation_accessors Game canvas_map
generate_pac_presentation_accessors Game frame_panel
generate_pac_presentation_accessors Game canvas_mini_map
generate_pac_presentation_accessors Game canvas_panel


method GamePresentation init {} {
    wm aspect $this(tk_parent) 3 2 3 2
    wm minsize $this(tk_parent) 900 600
    wm maxsize $this(tk_parent) 900 600
    wm title $this(tk_parent) "PacWar !"

    this set_canvas_map [canvas $this(tk_parent).canvas_map]
    this set_frame_panel  [frame $this(tk_parent).frame_panel -relief raised \
                            -borderwidth 1]
    # On ajoute les deux map dans une frame
    this set_canvas_mini_map [canvas $this(frame_panel).canvas_mini_map]
    this set_canvas_panel [canvas $this(frame_panel).canvas_panel -width 200 \
                            -height 200 -background "#383838"]



    pack $this(canvas_map) -expand 1 -side right -fill both
    pack $this(frame_panel) -side left -fill both
    pack $this(canvas_panel) -expand 1 -fill both
    pack $this(canvas_mini_map) -fill both

}


method GameControl add_player {player} {

}