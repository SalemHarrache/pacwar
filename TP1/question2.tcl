#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]
source [file join [file dirname [info script]] . question1.tcl]


# Controleur Kelvin

inherit TemperatureControlCelsius Control
method TemperatureControlCelsius constructor {parent label unit} {
   TemperaturePresentation ${objName}_pres $objName $label $unit
   this inherited $parent "" ${objName}_pres
   this change
}

method TemperatureControlCelsius edit {newvalue} {
   # On convertit en Kelvin avant de repercuter les changement vers l'abstraction
   $this(parent) edit [this celsius_to_kelvin $newvalue]
}

method TemperatureControlCelsius change {} {
   # On convertit en °C avant d'afficher 
   $this(presentation) change [this kelvin_to_celsius [$this(parent) get]]
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
   TemperatureControl agent_central 10
   TemperatureControlCelsius agent_temp_c agent_central Température "°C"
}
