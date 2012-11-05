#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]
source [file join [file dirname [info script]] . question1.tcl]


inherit TemperatureControlCelsius TemperatureControl
method TemperatureControlCelsius constructor {parent value label unit} {
   this inherited $parent $value $label $unit
}

method TemperatureControlCelsius edit {newvalue} {
   $this(abstraction) edit [this celsius_to_kelvin $newvalue]
}

method TemperatureControlCelsius change {} {
   $this(presentation) change [this kelvin_to_celsius [$this(abstraction) attribute value]]
}

method TemperatureControlCelsius destructor {} {
   this inherited
}

method TemperatureControlCelsius kelvin_to_celsius {value} {
   return [expr $value + 273.15]
}

method TemperatureControlCelsius celsius_to_kelvin {value} {
   return [expr $value - 273.15]
}


# main --
if {[is_main]} {
   # executed only if the file is the main script
   TemperatureControlCelsius agent_temp "" 10 Température "°C"
}
