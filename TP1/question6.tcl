#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] question5.tcl]

# FormulePresentation --
inherit FormulePresentation Presentation
method FormulePresentation constructor {control} {
    this inherited $control
    set this(frames) {}
    set this(window) .
    set this(label) [label $this(window).label -justify center -text "R = $PVNRT::R, n = $PVNRT::n mole"]
    # Lorsque l'utilisateur appuie sur les touches <Control> et <p> en meme temps, l'interface se modifie
    # pour passer du mode horizontal précédent à un empilement vertical
    bind $this(window) <Control-Key-p> "$objName switch_view_mode; $objName refresh"
    set this(mode) horizontal

    wm title $this(window) "Formule"
}

method FormulePresentation switch_view_mode {} {
    if {$this(mode) == "vertical"} {
        set this(mode) horizontal
    } else {
        set this(mode) vertical
    }
}

method FormulePresentation refresh {} {
    pack forget $this(label)
    foreach frame $this(frames) {
        pack forget $frame
    }
    pack configure $this(label) -expand 1 -fill both
    if {$this(mode) == "vertical"} {
        foreach frame $this(frames) {
            pack configure $frame -expand 1 -fill both
        }
    } else {
        foreach frame $this(frames) {
            pack configure $frame -expand 1 -side left
        }
    }
}

# main --
if {[is_main]} {
   # executed only if the file is the main script
   FormuleControl agent_central

   TemperatureControlCelsius agent_temp_c agent_central
   PressureControl agent_press agent_central
   VolumeControl agent_volume agent_central
}