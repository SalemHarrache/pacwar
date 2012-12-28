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
        bind . <Left>  \"\$objName decr_ang\"
        bind . <Right> \"\$objName incr_ang\"
        bind . <Up>    \"\$objName speed_up\"
        bind . <Down>  \"\$objName speed_down\"
        bind . <Key-space>  \"\$objName shut\"
    "
    game add_player "goteki" "
        bind . <q>  \"\$objName decr_ang\"
        bind . <d> \"\$objName incr_ang\"
        bind . <z>    \"\$objName speed_up\"
        bind . <s>  \"\$objName speed_down\"
        bind . <Shift_L>  \"\$objName shut\"
    "

    # PlanetControl planet_1 universe .

    # ShipControl ship_1 universe .

    if {$argc > 0} {
        Introspact introspact game
    }
}

run