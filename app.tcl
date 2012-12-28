#!/bin/sh
# restart using tclsh \
# exec wish ./lib/tkcon.tcl -load Tk "$0" "$@" \
exec wish "$0" "$@"

package require Img
package require Tk

# load utilities
source [file normalize [file join . utils.tcl]]

source [abspath lib gml_Object.tcl]
source [abspath lib PAC.tcl]
source [abspath lib introspact.tcl]
source [abspath lib SWL_FC.tcl]
source [abspath game.tcl]
source [abspath sound.tcl]
source [abspath panel.tcl]
source [abspath planet.tcl]
source [abspath player.tcl]
source [abspath ship.tcl]
source [abspath universe.tcl]

proc run {} {
    global argc

    GameControl game "" .
    PanelControl panel game .
    UniverseControl universe game .
    SoundControl sfx_manager game ""

    game add_player "feisar" "
        bind . <Left>  \"\$objName move_left\"
        bind . <Right> \"\$objName move_right\"
        bind . <Up>    \"\$objName move_up\"
        bind . <Down>  \"\$objName move_down\"
        bind . <Key-space>  \"\$objName shut\"
    "
    game add_player "goteki" "
        bind . <q>  \"\$objName move_left\"
        bind . <d> \"\$objName move_right\"
        bind . <z>    \"\$objName move_up\"
        bind . <s>  \"\$objName move_down\"
        bind . <Shift_L>  \"\$objName shut\"
    "

    # PlanetControl planet_1 universe .

    # ShipControl ship_1 universe .

    if {$argc > 0} {
        Introspact introspact game
    }
}

run