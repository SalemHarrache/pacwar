# load utilities
source [file join [file dirname [info script]] .. lib init.tcl]


proc generate_pac_accessors {C A P var} {
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

# Cette fonction genère les classes PAC pour un agent donné
proc generate_pac_agent {agent} {
  set cmd ""
  append cmd "
  inherit ${agent}Abstraction Abstraction
  inherit ${agent}Control Control
  inherit ${agent}Presentation Presentation

  # ${agent}Abstraction --
  method ${agent}Abstraction constructor {control} {
    this inherited \$control
  }

  method ${agent}Abstraction destructor {} {
    this inherited
  }

  # ${agent}Presentation --
  method ${agent}Presentation constructor {control canvas} {
    this inherited \$control
    set this(canvas) \$canvas
  }

  method ${agent}Presentation destructor {} {
    this inherited
  }

  # ${agent} Control --
  method ${agent}Control constructor {{parent \"\"} {canvas \"\"}} {
    ${agent}Presentation \${objName}_pres \$objName \$canvas
    ${agent}Abstraction \${objName}_abst \$objName
    this inherited \$parent \${objName}_abst \${objName}_pres
  }

  method ${agent}Control destructor {} {
    this inherited
  }"
  # puts $cmd
  eval $cmd
}