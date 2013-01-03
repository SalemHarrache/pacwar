#!/bin/sh
# restart using tclsh \
# exec wish ./lib/tkcon.tcl -load Tk "$0" "$@" \
exec wish "$0" "$@"

set VERSION 1.2-dev

package require Img
package require Tk

# load utilities
source [file normalize [file join . utils.tcl]]

source [abspath .. lib gml_Object.tcl]
source [abspath .. lib PAC.tcl]
source [abspath .. lib introspact.tcl]
source [abspath .. lib SWL_FC.tcl]
source [abspath game.tcl]
source [abspath sound.tcl]
source [abspath panel.tcl]
source [abspath planet.tcl]
source [abspath player.tcl]
source [abspath ship.tcl]
source [abspath universe.tcl]


GameControl game "" .
PanelControl panel game
UniverseControl universe game
SoundControl sfx_manager game


proc new_game {} {
    # 2 players
    game add_player "goteki" 360 760
    game add_player "feisar"  80 330
    # game add_player "omega"  400 500

    # 3 planets
    game add_planet 200 400 80 100
    game add_planet 600 400 80 100
    game add_planet 400 100 80 100
}

new_game

if {$argc > 0} {
    Introspact introspact game
}