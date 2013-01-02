#!/bin/sh
# restart using tclsh \
# exec wish ./lib/tkcon.tcl -load Tk "$0" "$@" \
exec wish "$0" "$@"

set VERSION 1.1-dev

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
PanelControl panel game .
UniverseControl universe game .
SoundControl sfx_manager game ""

# 2 players
game add_player "goteki" 360 860
game add_player "feisar"  600 300
# game add_player "rastar"  400 500
# game add_player "omega"  400 500

# 10 planets
game add_planet 200 500 80 100
game add_planet 600 500 80 100
game add_planet 400 200 80 100
# game add_planet 10 10 80 100
# game add_planet 642 147 80 200
# game add_planet 1200 400 80 100
# game add_planet 1400 1001 80 50
# game add_planet 1200 1500 80 50
# game add_planet 1600 800 80 50

if {$argc > 0} {
    Introspact introspact game
}