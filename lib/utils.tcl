# tcl utils

# is_main --
#
#   check if the calling script was executed on the command line or sourced
#

proc is_main {} {
	global argv0
	return [string equal [info script] $argv0]
}


#___________________________________________________________________________________________________________________________________________
# assert --
#
#   check the result of an expression
#
#___________________________________________________________________________________________________________________________________________
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


#___________________________________________________________________________________________________________________________________________
# Manage_variable_consistency --
#
#   Create methods to handle consistency between facets of a PAC agent for a certain variable
#
#___________________________________________________________________________________________________________________________________________
proc Generate_PAC_accessors {C A P var {propagate 1}} {
 set cmd ""
# C facet
 append cmd "method $C user_set_$var   {v} {this set_$var \$v}\n"
 append cmd "method $C system_set_$var {v} {this set_$var \$v}\n"
 append cmd "method $C get_$var { } {if {\$this(abstraction) != \"\"} {return \[\$this(abstraction) get_$var\]} else {return \$this($var)}}\n"
 append cmd "method $C set_$var {v} {if {\$this(abstraction)  != \"\"} {\$this(abstraction) set_$var \$v}; if {\$this(presentation)  != \"\"} {\$this(presentation) set_$var \[this get_$var\]}}\n"
 if {$propagate} {append cmd "Add_propagation $C set_$var\n"}
 
# A facet
 if {$A != ""} {
   append cmd "method $A system_set_$var {v} {\$this(control) system_set_$var \$v}\n"
   append cmd "method $A set_$var {v} {set this($var) \$v}\n"
   append cmd "method $A get_$var { } {return \$this($var)}\n"
  }
  
# P facet
 if {$P != ""} {
   append cmd "method $P user_set_$var {v} {\$this(control) user_set_$var \$v}\n"
   append cmd "method $P get_$var { } {return \[\$this(control) get_$var\]}\n"
   append cmd "method $P set_$var {v} {}\n"
  }
  
# Evaluation of the command
 eval $cmd
}
