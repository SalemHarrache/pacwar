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

    # 2 players
    game add_player "feisar" 50 0
    game add_player "goteki"  90 50 

    # 10 planets
    game add_planet 190 249 80 50
    # game add_planet 294 795 80 50
    game add_planet 27 1001 80 50
    game add_planet 642 147 80 50
    game add_planet 10 10 80 50
    game add_planet 600 700 80 50
    game add_planet 1400 1001 80 50
    game add_planet 1200 1500 80 50
    game add_planet 1600 800 80 50

    # PlanetControl planet_1 universe .

    if {$argc > 0} {
        Introspact introspact game
    }
}

run

# "
#         bind . <Left>  \"\$objName move_left\"
#         bind . <Right> \"\$objName move_right\"
#         bind . <Up>    \"\$objName move_up\"
#         bind . <Down>  \"\$objName move_down\"
#         bind . <Key-space>  \"\$objName shut\"
#     " 
# "
#         bind . <q>  \"\$objName move_left\"
#         bind . <d> \"\$objName move_right\"
#         bind . <z>    \"\$objName move_up\"
#         bind . <s>  \"\$objName move_down\"
#         bind . <Shift_L>  \"\$objName shut\"
#     "