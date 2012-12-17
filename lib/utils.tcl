# tcl utils

# is_main --
#
#   check if the calling script was executed on the command line or sourced
#

proc lremove {liste quoi} {
    return [lsearch -all -inline -not -exact $liste $quoi]
}


proc is_main {} {
  global argv0
  return [string equal [info script] $argv0]
}

proc is_defined {procname} {
  return [lsearch [info procs] $procname]
}


#______________________________________________________________________________
# assert --
#
#   check the result of an expression
#
#______________________________________________________________________________
proc assert {expression {expected_result 1} {verbose 1}} {
	set result [eval $expression]
	set assert_ok [expr {$result == $expected_result}]

	if {$verbose} {
		puts -nonewline "assert (\[$expression\] == $expected_result): "
		if {$assert_ok} {
			puts "passed"
		} else {
			puts "failed (expected \"$expected_result\", got \"$result\")"
		}
	}

	return $assert_ok
}

#___________________________________________________________________________________________________________________________________________
# Add_aspect --
#
#   Inject code 'code' marked with 'mark' into a the method 'm' of a class 'c'
#
#___________________________________________________________________________________________________________________________________________
proc Add_aspect {c m mark code {position begin}} {
 # Get the existing body
 set body [gmlObject info body $c $m]

 # Inject code into the body
 set bgn_mark "# <${mark}>"
 set end_mark "# </${mark}>"
 if {[regexp "^(.*)${bgn_mark}\n.*$end_mark\n(.*)\$" $body reco bgn end]} {
   set body "$bgn$bgn_mark\n$code\n$end_mark\n$end"
  } else {if {$position == "begin"} {
            set body "$bgn_mark\n$code\n$end_mark\n$body"
		   } else {set body "$body\n$bgn_mark\n$code\n$end_mark"}
		 }

 # Enter the new body into the TCL interpretor by building the command
 set   cmd "method $c $m {[gmlObject info arglist $c $m]} {\n$body}"
 eval $cmd
}

#___________________________________________________________________________________________________________________________________________
# Add_propagation --
#
#   Inject propagation code into a the method 'm' of a class 'c' that inherit directly or not from Control
#
#___________________________________________________________________________________________________________________________________________
proc Add_propagations {c Lm} {
 foreach m $Lm {Add_propagation $c $m}
}

proc Add_propagation {c m} {
# Constructtion of the propagation command
 set cmd_propagation "this Propagate \$objName \"\$objName $m"
   foreach a [gmlObject info args $c $m] {
     append cmd_propagation " " \$[lindex $a 0]
	}
 append cmd_propagation "\""

# Check if the propagation was still added
 Add_aspect $c $m {__PAC PROPAGATION MECHANISM__} $cmd_propagation end
}


# Cette fonction génère les classes PAC pour un agent donné
proc generate_pac_agent {agent {abstraction 1} {presentation 1} {control 1}} {
  set cmd ""
  if {$abstraction == 1} {
      append cmd "
      # ${agent}Abstraction --
      inherit ${agent}Abstraction Abstraction

      method ${agent}Abstraction init {} {}

      method ${agent}Abstraction constructor {control} {
        this inherited \$control
      }
      method ${agent}Abstraction destructor {} {
        this inherited
      }"
  }
  if {$presentation == 1} {
      append cmd "
      inherit ${agent}Presentation Presentation

      # ${agent}Presentation --
      method ${agent}Presentation init {} {}

      method ${agent}Presentation constructor {control tk_parent} {
        this inherited \$control
        set this(tk_parent) \$tk_parent
      }

      method ${agent}Presentation destructor {} {
        this inherited
      }"
  }
  if {$control == 1} {
      append cmd "
      inherit ${agent}Control Control

      # ${agent} Control --
      method ${agent}Control init {} {}

      method ${agent}Control constructor {{parent \"\"} {tk_parent \"\"}} {
        set pres \"\"
        set abst \"\"
      "
      if {$abstraction == 1} {
        append cmd "
        set abst \[${agent}Abstraction \${objName}_abst \$objName\]
        "
      }
      if {$presentation == 1} {
        append cmd "
        set pres \[${agent}Presentation \${objName}_pres \$objName \$tk_parent\]
        "
      }
      append cmd "
        this inherited \$parent \$abst \$pres
        this init
      "
      if {$abstraction == 1} {
        append cmd "
        \$abst init
        "
      }
      if {$presentation == 1} {
        append cmd "
        \$pres init
        "
      }
      append cmd "
      }
      method ${agent}Control destructor {} {
        this inherited
      }"
  }
  # puts $cmd
  eval $cmd
}

# Cette fonction genère les classes PAC pour un agent donné
proc generate_pac_agent_multi_view {agent views} {
  foreach name $views {
      # generate pac agent without abstraction
      generate_pac_agent ${name}${agent} 0 1 1
  }
  generate_pac_agent ${agent} 1 0 1
  set cmd ""
  append cmd "
  method ${agent}Control constructor {{parent \"\"} {tk_parent \"\"}} {
    ${agent}Abstraction \${objName}_abst \$objName
    this inherited \$parent \${objName}_abst \"\"
    foreach name \[\list ${views}\] {
        \${name}${agent}Control \${name}_\${objName} \$objName \$tk_parent
    }
    this init
  }"
  # puts $cmd
  eval $cmd
}


proc generate_pac_accessors {agent var {propagate 1}} {

  set cmd ""


  # Generates accessors for the control facet $C
  if {[is_defined "${agent}Control"]} {
    append cmd "method ${agent}Control user_change_$var {v} {if {\$this(abstraction) != \"\"} {\$this(abstraction) set_$var \$v}}\n"
    append cmd "method ${agent}Control system_change_$var {v} {\$this(presentation) set_$var \$v}\n"
    if {[is_defined "${agent}Abstraction"]} {
    append cmd "method ${agent}Control get_$var { } {if {\$this(abstraction) != \"\"} {return \[\$this(abstraction) get_$var\]} else {return \$this($var)}}\n"
    }
    if {$propagate} {append cmd "Add_propagation ${agent}Control system_change_$var\n"}
  }
  # Generates accessors for the presentation facet $P
  if {[is_defined "${agent}Presentation"]} {
    append cmd "method ${agent}Presentation change_$var {v} {\$this(control) user_change_$var \$v}\n"
    append cmd "method ${agent}Presentation get_$var { } {return \[\$this(control) get_$var\]}\n"
    append cmd "method ${agent}Presentation set_$var {v} {}\n"
  }
  # Generates accessors for the abstraction facet $A
  if {[is_defined "${agent}Abstraction"]} {
    append cmd "method ${agent}Abstraction change_$var {v} {\$this(control) system_change_$var \$v}\n"
    append cmd "method ${agent}Abstraction set_$var {v} {set this($var) \$v; this change_$var \$v}\n"
    append cmd "method ${agent}Abstraction get_$var { } {return \$this($var)}\n"
  }

  # Evaluation of the command
  # puts $cmd
  eval $cmd
}

proc generate_pac_presentation_accessors {agent var} {
  set cmd ""

  # Generates accessors for the control facet $C
  if {[is_defined "${agent}Control"]} {
    append cmd "method ${agent}Control get_$var { } {return \[\$this(presentation) get_$var\]}\n"
    append cmd "method ${agent}Control set_$var {v} {\$this(presentation) set_$var \$v}\n"
  }
  # Generates accessors for the presentation facet $P
  if {[is_defined "${agent}Presentation"]} {
    append cmd "method ${agent}Presentation set_$var {v} {set this($var) \$v}\n"
    append cmd "method ${agent}Presentation get_$var { } {return \$this($var)}\n"
  }
  # Evaluation of the command
  # puts $cmd
  eval $cmd
}


proc generate_pac_parent_accessors {agent var} {
  set cmd ""
  append cmd "
  method ${agent}Control get_parent_$var { }  {
    #return \[\$this(parent) get_$var\]
    set parent_value_exist \[catch {set value \[\$this(parent) get_$var\]}\]
    if { \$parent_value_exist != 0 } {
      # Try get_parent_$var
      set sub_parent_value_exist \[catch {set value \[\$this(parent) get_parent_$var\]}\]
      if { \$sub_parent_value_exist != 0 } {
          puts \"\\nERROR: Inexistant value : $var!!!\"
          exit 1
      }
    }
    return \$value
  }
  "
  eval $cmd
}