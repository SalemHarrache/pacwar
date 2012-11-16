#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]
source pac_generator.tcl


inherit ValueControl Control


inherit ValueAbstraction Abstraction
inherit ValuePresentation Presentation


Generate_PAC_accessors ValueControl ValueAbstraction ValuePresentation value


# ValueAbstraction --
method ValueAbstraction constructor {control} {
   this inherited $control
}

method ValueAbstraction destructor {} {
   this inherited
}


# ValuePresentation --
method ValuePresentation constructor {control label_name unit_name} {
   this inherited $control

   set this(window) .
   set this(label) [label $this(window).label -text $label_name -justify center]

   set this(unit_layout) [frame $this(window).frame]
   set this(entry) [entry $this(window).entry -justify center]
   set this(unit) [label $this(window).unit -text $unit_name -justify center]

   pack $this(label) -expand 1 -fill both
   pack $this(entry) $this(unit) -side left -padx 4

   bind $this(entry) <Return> "$objName change_value \[$this(entry) get\]"
}

method ValuePresentation set_value {value} {
   $this(entry) delete 0 end
   $this(entry) insert 0 $value
}

method ValuePresentation destructor {} {
   this inherited
}

# ValueControl --
method ValueControl constructor {parent value label unit} {
   ValuePresentation ${objName}_pres $objName $label $unit
   ValueAbstraction ${objName}_abst $objName
   this inherited $parent ${objName}_abst ${objName}_pres
   $this(abstraction) set_value $value
}

method ValueControl destructor {} {
   this inherited
}

ValueControl control_value "" 10 Température "°C"