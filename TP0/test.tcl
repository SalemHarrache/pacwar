#!/bin/sh
# restart using tclsh \
exec tclsh "$0" "$@"

# load utilities
source [file join [file dirname [info script]] utils.tcl]


# lmax --
#
#   find the max in a list
#
# args:
#   list - the list
# returns:
#   the max

proc max {x y} {
    if {$x > $y} {
        return $x
    } else {
        return $y
    }
}

proc lmax {list} {
    foreach arg $list {
        set max [maximum $max $arg]
    }
    return $max
}

proc lmax_r {list} {
    if { [llength $list] <= 1 } {
        return [lindex $list 0]
    } else {
        return [max [lindex $list 0] [lmax_r [lrange $list 1 end]]]
    }
}

proc factorial n {
   if {$n == 0} {
        return 1
    } else {
        return [expr $n * [factorial [expr $n - 1]]]
    }
}

proc maximum {x list} {
    if {$x > $y} {
        return $x
    } else {
        return $y
    }
}


# main --
if {[is_main]} {
   # executed only if the file is the main script
   proc test {} {
      assert "lmax {23 56}" 56
   }
   test
   exit
}