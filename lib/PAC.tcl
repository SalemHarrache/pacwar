#___________________________________________________________________________________________________________________________________________
# PAC --
#
#   PAC class implementation
#___________________________________________________________________________________________________________________________________________

#___________________________________________________________________________________________________________________________________________
# object extension
set gmlObjectPath [file join [file dirname [info script]]]
if {[catch {load [file join $gmlObjectPath libgmlobject.so]}]} {
	source [file join $gmlObjectPath gml_Object.tcl]
}

#___________________________________________________________________________________________________________________________________________
# Object --
#
#   define some standard methods
#
#___________________________________________________________________________________________________________________________________________
method Object constructor  {}    {}
method Object setAttribute {a v} {set this($a) $v}
method Object getAttribute {a  } {return $this($a)}


#___________________________________________________________________________________________________________________________________________
# Control --
#
#   control facet for PAC architecture
#
#___________________________________________________________________________________________________________________________________________
inherit Control Object
method Control constructor {{parent ""} 
                            {abstraction ""} 
                            {presentation ""} 
                            {children {}}} {
    this inherited
	set this(L_subscriptions) [list ]
	set this(parent) $parent
	set this(abstraction) $abstraction
	set this(presentation) $presentation
	set this(children) [list]
	
	foreach c $children {this append $c}
	
	if {$this(parent) != ""} {
		$this(parent) append $objName
	}
}

#___________________________________________________________________________________________________________________________________________
method Control dispose {} {
	if {$this(parent) != ""} {
		$this(parent) remove $objName
	}

	foreach child $this(children) {
		$child dispose
	}
	
	foreach facet {presentation abstraction} {
		if {$this($facet) != ""} {
			$this($facet) dispose
			set this($facet) ""
		}
	}
	
	this inherited
}

#___________________________________________________________________________________________________________________________________________
method Control append {child} {
	lappend this(children) $child
	$child setAttribute parent $objName
}

#___________________________________________________________________________________________________________________________________________
method Control remove {child} {
	set this(children) [lremove $this(children) $child]
}

#___________________________________________________________________________________________________________________________________________
# id : an identifyer for the subscription, allow to redifine the command associated to a subscription.
# re : regular expression that has to be matched to trigger the CallBack (CB).
# CB : CallBack to be triggered when the regular expression (re) is matched.
#___________________________________________________________________________________________________________________________________________
method Control Subscribe {id re CB} {
	set pos 0
	foreach s $this(L_subscriptions) {
	  if {[lindex $s 0] == $id} {set this(L_subscriptions) [lreplace $this(L_subscriptions) $pos $pos]; break}
	  incr pos
	 }
	lappend this(L_subscriptions) [list $id $re $CB]
}

#___________________________________________________________________________________________________________________________________________
# Test if a message is recognize by the Control. If yes, the related CallBack is triggered.
# In any case, the message is propagated to the parent Control.
#___________________________________________________________________________________________________________________________________________
method Control Propagate {owner msg} {
	if {$owner == ""} {set owner $objName}
	foreach s $this(L_subscriptions) {
	  if {[regexp [lindex $s 1] $msg]} {eval [lindex $s 2]}
	 }
	if {$this(parent) != ""} {
	  $this(parent) Propagate $owner $msg
	 }
}

#___________________________________________________________________________________________________________________________________________
# Abstraction --
#
#   abstraction facet for PAC architecture
#
#___________________________________________________________________________________________________________________________________________
inherit Abstraction Object
method Abstraction constructor {control} {
	this inherited
	set this(control) $control
}


#___________________________________________________________________________________________________________________________________________
# Presentation --
#
#   presentation facet for PAC architecture
#
#___________________________________________________________________________________________________________________________________________
inherit Presentation Object
method Presentation constructor {control} {
	this inherited
	set this(control) $control
}
