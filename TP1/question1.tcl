#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]


# ValueAbstraction --

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
   puts "$value K"
}

# ValuePresentation --

inherit TemperaturePresentation Presentation
method TemperaturePresentation constructor {control label_name unit_name} {
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

method TemperaturePresentation change {value} {
   $this(entry) delete 0 end
   $this(entry) insert 0 $value
}

method TemperaturePresentation edit {} {
   set newvalue [$this(entry) get]
   $this(control) edit $newvalue
}

method TemperaturePresentation destructor {} {
   destroy $this(window)
}

# ValueControl --

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


# main --
if {[is_main]} {
   # executed only if the file is the main script
   TemperatureControl agent_temp "" 10 Température "K"
}

