#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]
source [file join [file dirname [info script]] . question1.tcl]
source [file join [file dirname [info script]] . question2.tcl]
source [file join [file dirname [info script]] . PVNRT.tcl]

inherit FormuleAbstraction Abstraction
method FormuleAbstraction constructor {control value} {
   this inherited $control
   set this(value) $value
   trace add variable this(value) write "$objName change"
}




# main --
if {[is_main]} {
   # executed only if the file is the main script
   TemperatureControl agent_central 10
   TemperatureControlCelsius agent_temp_c agent_central Température "°C"
}
