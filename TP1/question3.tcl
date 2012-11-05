#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]
source [file join [file dirname [info script]] . question1.tcl]
source [file join [file dirname [info script]] . question2.tcl]


# main --
if {[is_main]} {
   # executed only if the file is the main script
   TemperatureControl agent_central 10
   TemperatureControlKelvin agent_temp_k agent_central Température "K"
   TemperatureControlCelsius agent_temp_c agent_central Température "°C"
}
