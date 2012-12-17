#!/bin/sh
# restart using tclsh \
# exec wish ./lib/tkcon.tcl -load Tk "$0" "$@" \
exec wish "$0" "$@"

package require Img

# load utilities
source [file join [file dirname [info script]] . lib init.tcl]
source [file join [file dirname [info script]] . game.tcl]
source [file join [file dirname [info script]] . panel.tcl]
source [file join [file dirname [info script]] . planet.tcl]
source [file join [file dirname [info script]] . player.tcl]
source [file join [file dirname [info script]] . ship.tcl]
source [file join [file dirname [info script]] . universe.tcl]


proc run {} {
    global argc

    GameControl game "" .

    PanelControl panel game .
    PlayerControl player_1 panel .
    PlayerControl player_2 panel .

    UniverseControl universe game .

    PlanetControl planet_1 universe .

    ShipControl ship_1 universe .

    if {$argc > 0} {
        Introspact introspact game
    }
}

run