# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]


proc Generate_PAC_accessors {C A P var} {
  set cmd ""

  # Generates accessors for the control facet $C
  append cmd "method $C user_change_$var {v} {if {\$this(abstraction) != \"\"} {\$this(abstraction) set_$var \$v}}\n"
  append cmd "method $C system_change_$var {v} {\$this(presentation) set_$var \$v}\n"
  append cmd "method $C get_$var { } {if {\$this(abstraction) != \"\"} {return \[\$this(abstraction) get_$var\]} else {return \$this($var)}}\n"

  # Generates accessors for the presentation facet $P
  if {$P != ""} {
    append cmd "method $P change_$var {v} {\$this(control) user_change_$var \$v}\n"
    append cmd "method $P get_$var { } {return \[\$this(control) get_$var\]}\n"
    append cmd "method $P set_$var {v} {}\n"
  }

  # Generates accessors for the abstraction facet $A
  if {$A != ""} {
    append cmd "method $A change_$var {v} {\$this(control) system_change_$var \$v}\n"
    append cmd "method $A set_$var {v} {set this($var) \$v; this change_$var \$v}\n"
    append cmd "method $A get_$var { } {return \$this($var)}\n"
  }

  # Evaluation of the command
  eval $cmd
}