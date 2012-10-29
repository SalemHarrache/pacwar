###############################################################################
# file    : PAC.tcl
# content : basic gmlObject implementation of PAC model
# history : 2007-Oct-18 - [rb] inital version
# todo    : - remove abstraction, presentation, children from constructor args
#           - automatic forward of unknown methods to parent
###############################################################################


# PAC --
#
#   PAC class implementation
#

# object extension
set gmlObjectPath [file join [file dirname [info script]]]
if {[catch {load [file join $gmlObjectPath libgmlobject.so]}]} {
    source [file join $gmlObjectPath gml_Object.tcl]
}


# Control --
#
#   control facet for PAC architecture
#

method Control constructor {{parent ""}
                            {abstraction ""}
                            {presentation ""}
                            {children {}}} {
    set this(parent) $parent
    set this(abstraction) $abstraction
    set this(presentation) $presentation
    set this(children) $children

    if {$this(parent) != ""} {
        $this(parent) append $objName
    }
}

method Control destructor {} {
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
}

method Control append {child} {
    lappend this(children) $child
}

method Control remove {child} {
    set child_index [lsearch $this(children) $child]
    set this(children) [lreplace $this(children) $child_index $child_index]
}


# Abstraction --
#
#   abstraction facet for PAC architecture
#

method Abstraction constructor {control} {
    set this(control) $control
}


# Presentation --
#
#   presentation facet for PAC architecture
#

method Presentation constructor {control} {
    set this(control) $control
}