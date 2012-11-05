#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]
source [file join [file dirname [info script]] . question1.tcl]
source [file join [file dirname [info script]] . question2.tcl]
source [file join [file dirname [info script]] . PVNRT.tcl]

# Formule Abstraction
inherit FormuleAbstraction Abstraction
method FormuleAbstraction constructor {control} {
   this inherited $control
   lassign [PVNRT::equi 1 1 1] this(pressure) this(volume) this(temperature)
   trace add variable this(pressure) write "$objName change"
   trace add variable this(volume) write "$objName change"
   trace add variable this(temperature) write "$objName change"
}

method FormuleAbstraction change {} {
   $this(control) change
}

method FormuleAbstraction edit {varname newvalue} {
	if {$varname == "temperature"} {
		lassign [PVNRT::equi $this(pressure) $this(volume) $newvalue isotherme] this(pressure) this(volume) this(temperature)
	} elseif {$varname == "volume"} {
		lassign [PVNRT::equi $this(pressure) $newvalue $this(temperature) isochore] this(pressure) this(volume) this(temperature)
	} elseif {$varname == "pressure"} {
		lassign [PVNRT::equi $newvalue $this(volume) $this(temperature) isobare] this(pressure) this(volume) this(temperature)
	}
   	$this(control) change
}


# FormuleControl --
inherit FormuleControl Control
method TemperatureControl constructor {} {
   FormuleAbstraction ${objName}_abst $objName
   this inherited "" ${objName}_abst

   this change
}

method FormuleControl edit {varname newvalue} {
   $this(abstraction) edit $varname $newvalue
}

method FormuleControl get {varname} {
	set var [$this(abstraction) attribute $varname]
   	return $var
}

method FormuleControl change {} {
    foreach child $this(children) {
        $child change
    }
}

method FormuleControl destructor {} {
   this inherited
}


# Controleur Temperature Celsius
inherit TemperatureControlCelsius Control
method TemperatureControlCelsius constructor {parent label unit} {
   TemperaturePresentation ${objName}_pres $objName $label $unit
   this inherited $parent "" ${objName}_pres
   this change
}

method TemperatureControlCelsius edit {newvalue} {
   $this(parent) edit temperature [this celsius_to_kelvin $newvalue]
}

method TemperatureControlCelsius change {} {
   $this(presentation) change [this kelvin_to_celsius [[$this(parent) attribute abstraction] attribute temperature]]]
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
   FormuleControl agent_central
   TemperatureControlCelsius agent_temp_c agent_central Température "°C"
}
