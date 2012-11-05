#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]
source [file join [file dirname [info script]] . question1.tcl]
source [file join [file dirname [info script]] . question2.tcl]
source [file join [file dirname [info script]] . PVNRT.tcl]

inherit FormuleAbstraction Abstraction
method FormuleAbstraction constructor {control} {
   this inherited $control
   lassign [PVNRT::equi 1 1 1] this(pressure) this(volume) this(temperature)
   trace add variable this(pressure) write "$objName change"
   trace add variable this(volume) write "$objName change"
   trace add variable this(temperature) write "$objName change"
}

method FormuleAbstraction change {varname} {
   $this(control) change
}

method FormuleAbstraction edit {varname value} {
	if {$varname == "temperature"} {
		lassign [PVNRT::equi $this(pressure) $this(volume) value isotherme] this(pressure) this(volume) this(temperature)
	} elseif {$varname == "isochore"} {
		lassign [PVNRT::equi $this(pressure) value $this(temperature) isobare] this(pressure) this(volume) this(temperature)
	} elseif {$varname == "pressure"} {
		lassign [PVNRT::equi value $this(volume) $this(temperature) isobare] this(pressure) this(volume) this(temperature)
	}
   	$this(control) change
}


# main --
if {[is_main]} {
   # executed only if the file is the main script
   TemperatureControl agent_central 10
   TemperatureControlCelsius agent_temp_c agent_central Température "°C"
}
