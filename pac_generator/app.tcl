#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]

generate_pac_agent Value
generate_pac_accessors Value value


# ValuePresentation --
method ValuePresentation constructor {control} {
   this inherited $control

   set this(window) .
   set this(label) [label $this(window).label -text "Température" -justify center]

   set this(unit_layout) [frame $this(window).frame]
   set this(entry) [entry $this(window).entry -justify center]
   set this(unit) [label $this(window).unit -text "°C" -justify center]

   pack $this(label) -expand 1 -fill both
   pack $this(entry) $this(unit) -side left -padx 4

   bind $this(entry) <Return> "$objName change_value \[$this(entry) get\]"
}

method ValuePresentation set_value {value} {
   $this(entry) delete 0 end
   $this(entry) insert 0 $value
}

# ValueControl --
method ValueControl constructor {parent value} {
   ValuePresentation ${objName}_pres $objName
   ValueAbstraction ${objName}_abst $objName
   this inherited $parent ${objName}_abst ${objName}_pres
   $this(abstraction) set_value $value
}

ValueControl control_value "" 10