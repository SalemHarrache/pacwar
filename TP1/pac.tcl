#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]


# ValueAbstraction --

inherit ValueAbstraction Abstraction
method ValueAbstraction constructor {control value} {
   this inherited $control
   set this(value) $value
   trace add variable this(value) write "$objName change"
}

method ValueAbstraction change {args} {
   $this(control) change
}

method ValueAbstraction edit {value} {
   set this(value) $value
   $this(control) change
   puts $value
}

# ValuePresentation --

inherit ValuePresentation Presentation
method ValuePresentation constructor {control label_name unit_name} {
   this inherited $control

   set this(window) [toplevel .$objName]
   wm protocol $this(window) WM_DELETE_WINDOW "$this(control) dispose"
   set this(label) [label $this(window).label -text $label_name -justify center]

   set this(unit_layout) [frame $this(window).frame]
   set this(entry) [entry $this(window).entry -justify center]
   set this(unit) [label $this(window).unit -text $unit_name -justify center]

   pack $this(label) -expand 1 -fill both
   pack $this(entry) $this(unit) -side left -padx 4



   bind $this(entry) <Return> "$objName edit"
}

method ValuePresentation change {value} {
   $this(entry) delete 0 end
   $this(entry) insert 0 $value
}

method ValuePresentation edit {} {
   set newvalue [$this(entry) get]
   $this(control) edit $newvalue
}

method ValuePresentation destructor {} {
   destroy $this(window)
}



# ValueControl --

inherit ValueControl Control
method ValueControl constructor {parent value label unit} {
   ValueAbstraction ${objName}_abst $objName $value
   ValuePresentation ${objName}_pres $objName $label $unit
   this inherited $parent ${objName}_abst ${objName}_pres

   this change
}

method ValueControl edit {newvalue} {
   $this(abstraction) edit $newvalue
}

method ValueControl change {} {
   $this(presentation) change [$this(abstraction) attribute value]
}

method ValueControl destructor {} {
   this inherited
}

ValueControl value "" 10 Température "°C"