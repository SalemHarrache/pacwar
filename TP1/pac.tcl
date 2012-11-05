#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]


# TemperatureAbstraction --

inherit TemperatureAbstraction Abstraction

method TemperatureAbstraction constructor {control value} {
   this inherited $control
   set this(value) $value
   trace add variable this(value) write "$objName change"
}

method TemperatureAbstraction change {args} {
   $this(control) change
}

method TemperatureAbstraction edit {value} {
   set this(value) $value
   $this(control) change
}

# TemperaturePresentation --

inherit TemperaturePresentation Presentation
method TemperaturePresentation constructor {control label_name unit_name} {
   this inherited $control

   set this(window) [toplevel .${objName}]
   wm protocol $this(window) WM_DELETE_WINDOW "$this(control) dispose"

   set this(entry) [entry $this(window).entry -justify right]
   set this(label) [label $this(window).label -text $label_name -justify center]
   set this(unit) [label $this(window).unit -text $unit_name -justify center]
   pack $this(label) -expand 1 -fill both
   pack $this(entry) $this(unit) -side left -padx 4


   bind $this(entry) <Return> "$objName edit"
}

method TemperaturePresentation change {value} {
   $this(entry) delete 0 end
   $this(entry) insert 0 $value
}

method TemperaturePresentation edit {} {
   set newTemperatureControl [$this(entry) get]
   $this(control) edit $newvalue
}

method TemperaturePresentation destructor {} {
   destroy $this(window)
}



# TemperatureControl --

inherit TemperatureControl Control
method TemperatureControl constructor {parent value label unit} {
   TemperatureAbstraction ${objName}_abst $objName $value
   TemperaturePresentation ${objName}_pres $objName $label $unit
   this inherited $parent ${objName}_abst ${objName}_pres

   this change
}

method TemperatureControl edit {newvalue} {
   $this(abstraction) edit $newvalue
}

method TemperatureControl change {} {
   $this(presentation) change [$this(abstraction) attribute value]
}

method TemperatureControl destructor {} {
   this inherited
}

TemperatureControl value "" 10 Température "°C"
