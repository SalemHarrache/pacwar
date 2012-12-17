#!/bin/sh
# restart using tclsh \
# exec wish ./lib/tkcon.tcl -load Tk "$0" "$@" \
exec wish "$0" "$@"

package require Img
package require Tk

# load utilities
source [file join [file dirname [info script]] . utils.tcl]
source [file join [file dirname [info script]] . lib gml_Object.tcl]
source [file join [file dirname [info script]] . lib PAC.tcl]
source [file join [file dirname [info script]] . lib introspact.tcl]
source [file join [file dirname [info script]] . lib SWL_FC.tcl]
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

# pack [canvas .c]
# bind .c <ButtonPress-1>   {oval_create %W %x %y}
# bind .c <B1-Motion>       {oval_move %W %x %y}
# bind .c <ButtonRelease-1> {oval_end %W %x %y}
# proc oval_create {win x y} {
#     global oval
#     set oval(x0) $x
#     set oval(y0) $y
#     set oval(id) \
#          [$win create oval $x $y $x $y]
# }

# proc oval_move {win x y} {
#     global oval
#     $win coords $oval(id) \
#           $oval(x0) $oval(y0) $x $y
# }
# proc oval_end {win x y} {
#     global oval
#     oval_move $win $x $y
#     $win itemconfigure $oval(id) -fill lightblue
# }