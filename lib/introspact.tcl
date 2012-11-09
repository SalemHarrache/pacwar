#!/bin/sh
#\
exec wish "$0" "$@"

##############################################################################
# file    : introspact.tcl
# content : run-time introspection of PAC agents
# history : 2007-Oct-18 - [rb] inital version
#           2007-Oct-22 - [rb] allow to reopen details on agent
#                         [rb] allow reparent
#           2007-Oct-23 - [rb] allow to change animation delay
#           2007-Oct-24 - [rb] adapt size of canvas to its content
#           2007-Nov-12 - [rb] switched to active value in details view
#                         [rb] close details if object disappears
# todo    : - enable method call
#           - enable links in details view
##############################################################################


# globals ####################################################################

set underline [font create -underline true]


# Code #######################################################################

# CodeP --
#
#   PAC agent to edit/eval code

inherit CodeP Presentation
method CodeP constructor {control klass method} {
	this inherited $control

	set this(window) [toplevel .w_${klass}_${method}]
	wm title $this(window) "${klass}::${method}"
	wm protocol $this(window) WM_DELETE_WINDOW "$this(control) dispose"
	
	text $this(window).c
	set args [gmlObject info arglist $klass $method]
	if {[llength $args] > 0} {
		$this(window).c insert end "method $klass $method \{ $args \} \{"
	} else {
		$this(window).c insert end "method $klass $method \{\} \{"
	}
	$this(window).c insert end [gmlObject info body $klass $method]
	$this(window).c insert end "\}"
	pack $this(window).c -side top -fill both -expand true
	pack [button $this(window).close -text "close" -command "$this(control) dispose"] -side right -padx 5 -pady 5
	pack [button $this(window).eval -text "eval" -command "$objName eval"] -side right -pady 5
}

method CodeP eval {} {
#	uplevel #0 [$this(window).c get 0.0 end]
	eval [$this(window).c get 0.0 end]
}

method CodeP destructor {} {
	destroy $this(window)
}


# Inspect ####################################################################

# InspectP --
#
#   inpector is just a presentation, it uses the generic Control as controler

inherit InspectP Presentation
method InspectP constructor {control agent} {
	this inherited $control
	
	set this(window) [toplevel .w_$control]
	wm title $this(window) "$agent details"
	wm protocol $this(window) WM_DELETE_WINDOW "$this(control) dispose"

	# attributes
	pack [frame $this(window).attr] -side top -fill both
	pack [label $this(window).attr.label -text "attributes" -bg black -fg white -anchor w -padx 2 -pady 2] -side top -fill x
	
	global $agent
	foreach name [array names $agent] {
		pack [frame $this(window).attr.a_$name] -side top -fill x
		pack [label $this(window).attr.a_$name.name -text "$name: " -anchor w -padx 2] -side left 
		pack [label $this(window).attr.a_$name.value -textvariable ${agent}($name) -anchor e -padx 2] -side right
	}
	
	# methods
	pack [frame $this(window).meth] -side top -fill both
	pack [label $this(window).meth.label -text "methods" -bg black -fg white -anchor w -padx 2 -pady 2] -side top -fill x
	set classes [gmlObject info classes $agent]
	
	foreach klass $classes {
		pack [frame $this(window).meth.h_$klass -bg grey -padx 2 -pady 2] -side top -fill x
		pack [label $this(window).meth.h_$klass.name -text "${klass}::" -bg grey -anchor w] -side left -fill x
		pack [label $this(window).meth.h_$klass.show -text "show" -bd 2 -relief raise] -side right
		bind $this(window).meth.h_$klass.show <1> "$objName show $klass show"
		
		frame $this(window).meth.c_$klass
		foreach {m c name a} [gmlObject info interface $klass] {
			pack [frame $this(window).meth.c_$klass.m_$name -padx 1] -side top -fill x
			pack [label $this(window).meth.c_$klass.m_$name.name -text "$name " -anchor nw -font underline -fg blue] -side left -fill y
			bind $this(window).meth.c_$klass.m_$name.name <1> "$objName show_code $klass $name"
			set args [gmlObject info args $klass $name]
			pack [label $this(window).meth.c_$klass.m_$name.value -text "$args" -fg #777 -anchor nw] -side right -fill x
		}
	}	
	this show [lindex $classes 0]
	
	# delay
	pack [frame $this(window).delay] -side top -fill both
	pack [label $this(window).delay.label -text "delay" -bg black -fg white -anchor w -padx 2 -pady 2] -side top -fill x

	pack [checkbutton $this(window).delay.switch -command "$objName toggle $agent" -variable __delay(switch,$agent)] -side left -fill y
	pack [scale $this(window).delay.scale -orient horizontal -to 1000 -width 10 -variable __delay(delay,$agent)] -side left -fill y
	this toggle $agent
}

method InspectP toggle {agent} {
	global __delay
	if {$__delay(switch,$agent)} {
		$this(window).delay.scale configure -state active
	} else {
		$this(window).delay.scale configure -state disabled
	}
}

method InspectP show {klass {show "show"}} {
	if {$show == "show"} {
		pack $this(window).meth.c_$klass -side top -fill x -after $this(window).meth.h_$klass
		set show "hide"
	} else {
		pack forget $this(window).meth.c_$klass
		set show "show"
	}
	
	$this(window).meth.h_$klass.show configure -text $show
	bind $this(window).meth.h_$klass.show <1> "$objName show $klass $show"
}

method InspectP show_code {klass method} {
	set code_name code_${klass}_${method}
	if {[gmlObject info exists object $code_name]} {
		$code_name dispose
	}
	Control $code_name $this(control) "" [CodeP ${code_name}_pres $code_name $klass $method]
}

method InspectP destructor {} {
	destroy $this(window)
}


# Introspact #################################################################

# IntrospactA --
#
#   introspac functionnal core

inherit IntrospactA Abstraction
method IntrospactA constructor {control {agent ""}} {
	this inherited $control
	
	set this(agent) ""
	this attach $agent
}

method IntrospactA destructor {} {
	this detach
}

method IntrospactA attach {agent} {
	this detach

	set this(call_stack) {}
	set this(agent) $agent

	this wrap $this(agent)
}

method IntrospactA detach {} {
	this wrap $this(agent) remove
	set this(agent) ""
}

method IntrospactA wrap {agent {action add}} {
	if {$agent == ""} return
	
	# depth first traversal
	foreach child [$agent attribute children] {
		this wrap $child $action
	}

	# trace facets
	foreach facet {abstraction presentation} {
		this trace_facet [$agent attribute $facet] $action
	}
	this trace_facet $agent $action

	# trace parts (childrens, abstraction and presentation)
	global $agent
	foreach part {children abstraction presentation} {
		trace $action variable ${agent}($part) "write" "$objName manage_geometry"
	}
}

method IntrospactA trace_facet {facet action} {
	if {$facet != ""} {
		trace $action execution $facet "enter leave" "$objName manage_call_stack"
	}
}
	
method IntrospactA manage_geometry {args} {
	set agent $this(agent)
	
	this detach
	$this(control) display
	this attach $agent	
}

method IntrospactA manage_call_stack {args} {
	set cmd [lindex $args 0]
	set op [lindex $args end]

	set target [lindex $cmd 0]
	set method [lindex $cmd 1]
	set margs [lrange $cmd 2 end]
	
	if {($target == $this(agent)) && ($method == "dispose")	&& ($op == "enter")} {
		$this(control) detach
	}
	
	# special cases
	switch $method {
		attribute {
			return
		}
		dispose {
			# close potential detailed view
			set inspect_name inspect_${target}_
			if {[gmlObject info exists object $inspect_name]} {
				$inspect_name dispose
			}
			return	
		}
	}
	
	# general cases
	switch $op {
		enter {
			set caller [lindex $this(call_stack) 0]
			set this(call_stack) [linsert $this(call_stack) 0 $target]
			$this(control) render_enter $caller $target $method $margs [llength $this(call_stack)]
		}
		leave { 
			$this(control) render_leave [llength $this(call_stack)]
			set this(call_stack) [lrange $this(call_stack) 1 end]
		}
		default {
			error "unexpected op $op"
		}
	}
}


# IntrospactP --
#
#   introspact presentation

inherit IntrospactP Presentation
method IntrospactP constructor {control {agent ""}} {
	this inherited $control

	# window
	set this(window) [toplevel .w_$control]
	wm protocol $this(window) WM_DELETE_WINDOW "$control dispose"
	
	# pause/stop buttons
	pack [frame $this(window).pause] -side top -fill x
	pack [checkbutton $this(window).pause.c -text "pause" -variable __pause] -side left
	pack [button $this(window).pause.s -text ">" -command {incr __pause_signal}] -side right
	
	# canvas & scrollbars
	frame $this(window).f
	
	set this(canvas) [canvas $this(window).f.c]

	scrollbar $this(window).f.v -orient vertical -command "$this(canvas) yview"
	scrollbar $this(window).f.h -orient horizontal -command "$this(canvas) xview"
	$this(canvas) configure -yscrollcommand "$this(window).f.v set" \
	                        -xscrollcommand "$this(window).f.h set"
	
	grid rowconfigure $this(window).f 0 -weight 1
	grid columnconfigure $this(window).f 0 -weight 1
	grid $this(canvas) -row 0 -column 0 -sticky "nsew"
	grid $this(window).f.v -row 0 -column 1 -sticky "ns"
	grid $this(window).f.h -row 1 -column 0 -sticky "ew"
	
	pack $this(window).f -fill both -expand true -side bottom
	
	# attach to PAC agent
	this attach $agent
}

method IntrospactP destructor {} {
	destroy $this(window)
}

method IntrospactP attach {agent} {
	set this(agent) $agent
	wm title $this(window) "$this(control) $agent"
	this display
}

method IntrospactP detach {} {
	this attach ""
}

method IntrospactP display {} {
	$this(canvas) delete all

	this render $this(agent)

	set bbox [$this(canvas) bbox all]
	if {$bbox != ""} {
		set MARGIN 20
		set left   [expr [lindex $bbox 0]-$MARGIN]
		set top    [expr [lindex $bbox 1]-$MARGIN]
		set right  [expr [lindex $bbox 2]+$MARGIN]
		set bottom [expr [lindex $bbox 3]+$MARGIN]
		$this(canvas) configure -scrollregion "$left $top $right $bottom"
	}
}

method IntrospactP render {agent {level 0}} {
	if {$this(agent) == ""} return
	
	if {$level == 0} { 
		set this(x) 0 
	}
	
	foreach child [$agent attribute children] {
		this render $child [expr $level+1]
	}
	this render_agent $agent $level
}


method IntrospactP render_agent {agent level} {
	set level_height 100
	set agent_width  120

	# position
	set bbox [$this(canvas) bbox child_$agent]
	if {$bbox != ""} {
		set x [center $bbox x]
	} else {
		set x $this(x)
		incr this(x) $agent_width
	}

	set y [expr $level * $level_height + 50]
	
	# abstraction, presentation
	foreach {facet dx dxt label} {abstraction -40 -2 A presentation 40 2 P} {
		set facet [$agent attribute $facet]
		if {$facet != ""} {
			set x0 [expr $x + $dx - 15]
			set x1 [expr $x0 + 30]
			set y0 [expr $y - 20]
			set y1 [expr $y0 + 20]
			$this(canvas) create oval $x0 $y0 $x1 $y1 -fill white -tags "$facet oval_$facet"
			$this(canvas) create text [expr $x + $dx + $dxt] [expr $y0 + 10] -text $label -tags "$facet text_$facet"
			this bind $facet
		}
	}

	# control
	set x0 [expr $x - 40]
	set x1 [expr $x + 40]
	set y0 [expr $y - 17]
	set y1 [expr $y + 15]
	set parent [$agent attribute parent]
	$this(canvas) create oval $x0 $y0 $x1 $y1 -fill white -tags "$agent child_$parent oval_$agent"
	$this(canvas) create text $x $y -text $agent -tags "$agent text_$agent"
	this bind $agent
	
	# links to the children
	foreach child [$this(canvas) find withtag child_$agent] {
		set cbbox [$this(canvas) coords $child]
		set clink [$this(canvas) create line $x $y [center $cbbox x] [center $cbbox y] -tags link_$agent]
		$this(canvas) lower $clink $agent
		$this(canvas) lower $clink $child
	}
}

method IntrospactP bind {agent} {
	$this(canvas) bind $agent <Enter> "$this(canvas) itemconfigure oval_$agent -width 2"
	$this(canvas) bind $agent <Leave> "$this(canvas) itemconfigure oval_$agent -width 1"
	$this(canvas) bind $agent <1> "$objName inspect $agent"
}

method IntrospactP inspect {agent} {
	set inspect_name inspect_${agent}_
	if {[gmlObject info exists object $inspect_name]} {
		$inspect_name dispose
	}
	Control $inspect_name $this(control) "" [InspectP ${inspect_name}_pres $inspect_name $agent]
}

method IntrospactP render_enter {caller target method args depth} {
	set callerid [$this(canvas) find withtag oval_$caller]
	set targetid [$this(canvas) find withtag oval_$target]	

	# render call
	set tbbox [$this(canvas) bbox $targetid]
	if {$tbbox == ""} return
	
	set xt [center $tbbox x]
	set yt [center $tbbox y]
	
	if {$callerid == $targetid} {
		set yc [expr $yt - 20]
		set xc $xt	
		set coords [list $xt $yt [expr $xt-20] $yc [expr $xt+20] $yc $xt $yt]
	} else {
		if {$callerid != ""} {
			set cbbox [$this(canvas) bbox $callerid]
			set xc [center $cbbox x]
			set yc [center $cbbox y]	
		} else {
			set xc [expr $xt + 40]
			set yc [expr $yt - 30]
		}
		if {$xc != $xt} {
			set coords [list $xc $yc $xc $yt $xt $yt]
		} else {
			set coords [list $xc $yc $xt $yt]
		}
	}
	$this(canvas) itemconfigure arrow -width 1
	$this(canvas) create line $coords -arrow last -fill red -smooth 1 -tags "call_$depth arrow" -width 2
	$this(canvas) create text [expr $xt+10] [expr $yt+10] -fill blue -text "$method $args" -tags call_text -anchor nw
	
	# delay
	global __pause
	if {$__pause} {
		tkwait variable __pause_signal
	} else {
		update idletask
		after [delay $target]
	}
	$this(canvas) delete call_text
}

method IntrospactP render_leave {depth} {
	$this(canvas) delete call_$depth
}

proc center {bbox {axe x}} {
	if {$axe == "x"} {
		return [expr ([lindex $bbox 0] + [lindex $bbox 2])/2.]
	} else {
		return [expr ([lindex $bbox 1] + [lindex $bbox 3])/2.]
	}
}

proc delay {agent} {
	# delay set for this agent
	global __delay
	if {[info exists __delay(switch,$agent)]} {
		if {$__delay(switch,$agent)} {
			return $__delay(delay,$agent)
		}
	}
	
	# delay not set: find containing agent delay
	global $agent
	if {[info exists ${agent}(parent)]} {
		set parent [$agent attribute parent]
	} else {
		set parent [$agent attribute control]
	}
	
	if {$parent == ""} {
		return 0
	} else {
		return [delay $parent]
	}
}


# Introspact --
#
#   introspacter control

inherit Introspact Control
method Introspact constructor {{agent ""} {parent ""}} {
	IntrospactA ${objName}_abst $objName
	IntrospactP ${objName}_pres $objName
	this inherited $parent ${objName}_abst ${objName}_pres

	this attach $agent	
}

method Introspact destructor {} {
	this inherited
}

method Introspact attach {agent} {
	this detach
	$this(presentation) attach $agent
	$this(abstraction) attach $agent
}

method Introspact detach {} {
	foreach child $this(children) {
		$child dispose
	}
	$this(presentation) detach
	$this(abstraction) detach
}

method Introspact display {} {
	$this(presentation) display
}

method Introspact render_enter {caller target method args depth} {
	$this(presentation) render_enter $caller $target $method $args $depth
}

method Introspact render_leave {depth} {
	$this(presentation) render_leave $depth
}

