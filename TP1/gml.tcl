#!/bin/sh
# restart using tclsh \
exec tclsh "$0" "$@"

# load utilities
set gmlObjectPath [file join [file dirname [info script]] ..]
if {[catch {load [file join $gmlObjectPath  libgmlobject.so]}]} {
   source [file join $gmlObjectPath gml_Object.tcl]
}


method Rectangle area {} { return [expr $this(width) * $this(height)] }

method Rectangle constructor {width height} {
   set this(width) $width
   set this(height) $height
}

# Héritage
inherit carre Rectangle


method carre constructor {width} {
    # Super
   this inherited $width $width
}

carre carre_obj 12

puts [carre_obj area]

puts $carre_obj(width)

carre_obj dispose