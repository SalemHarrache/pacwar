#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]
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

method FormuleAbstraction change {args} {
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
}


# FormuleControl --
inherit FormuleControl Control
method FormuleControl constructor {} {
   FormuleAbstraction ${objName}_abst $objName
   this inherited "" ${objName}_abst

   this change
}

method FormuleControl edit {varname newvalue} {
   $this(abstraction) edit $varname $newvalue
}

method FormuleControl get {varname} {
    return [$this(abstraction) attribute $varname]
}

method FormuleControl change {} {
    foreach child $this(children) {
        $child change
    }
}

method FormuleControl destructor {} {
   this inherited
}

# UnitPresentation --

inherit UnitPresentation Presentation
method UnitPresentation constructor {control label_name unit_name} {
   this inherited $control

   set this(window) [toplevel .$objName]
   wm protocol $this(window) WM_DELETE_WINDOW "$this(control) dispose; destroy $this(window)"
   set this(label) [label $this(window).label -text $label_name -justify center]

   set this(entry) [entry $this(window).entry -justify center]
   set this(unit) [label $this(window).unit -text $unit_name -justify center]

   wm minsize $this(window) 200 50
   wm maxsize $this(window) 200 50
   wm positionfrom $this(window) user
   wm sizefrom $this(window) user
   #Titre de la fenêtre
   wm title $this(window) "$label_name en $unit_name"

   pack $this(label) -expand 1 -fill both
   pack $this(entry) $this(unit) -side left -padx 4

   bind $this(entry) <Return> "$objName edit"
}

method UnitPresentation change {value} {
   $this(entry) delete 0 end
   $this(entry) insert 0 $value
}

method UnitPresentation edit {} {
   $this(control) edit [$this(entry) get]
}

method UnitPresentation destructor {} {
   destroy $this(window)
}


# Controleur Temperature Celsius
inherit TemperatureControlCelsius Control
method TemperatureControlCelsius constructor {parent} {
   UnitPresentation ${objName}_pres $objName "Température" "°C"
   this inherited $parent "" ${objName}_pres
   this change
}

method TemperatureControlCelsius edit {newvalue} {
   $this(parent) edit temperature [expr $newvalue - 0]
}

method TemperatureControlCelsius change {} {
   $this(presentation) change [expr  [$this(parent) get "temperature"] + 0]
}

method TemperatureControlCelsius destructor {} {
   this inherited
}

# Controleur Pression
inherit PressureControl Control
method PressureControl constructor {parent} {
   UnitPresentation ${objName}_pres $objName "Pression" "Bar"
   this inherited $parent "" ${objName}_pres
   this change
}

method PressureControl edit {newvalue} {
   $this(parent) edit pressure [expr $newvalue * 100000]
}

method PressureControl change {} {
   $this(presentation) change [expr  [$this(parent) get "pressure"] / 100000]
}

method PressureControl destructor {} {
   this inherited
}


# Controleur Volume
inherit VolumeControl Control
method VolumeControl constructor {parent} {
   UnitPresentation ${objName}_pres $objName "Volume" "m^3"
   this inherited $parent "" ${objName}_pres
   this change
}

method VolumeControl edit {newvalue} {
   $this(parent) edit volume $newvalue
}

method VolumeControl change {} {
   $this(presentation) change [$this(parent) get "volume"]
}

method VolumeControl destructor {} {
   this inherited
}

# main --
if {[is_main]} {
   # executed only if the file is the main script
   FormuleControl agent_central

   TemperatureControlCelsius agent_temp_c agent_central
   PressureControl agent_press agent_central
   VolumeControl agent_volume agent_central
}
