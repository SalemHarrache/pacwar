#!/bin/sh
# restart using tclsh \
exec tclsh "$0" "$@"

# load lib
source [file join [file dirname [info script]] .. lib init.tcl]

proc max {x y} {
    if {$x > $y} {
        return $x
    } else {
        return $y
    }
}

proc lmax {list} {
    set themax [lindex $list 0]
    foreach arg [lrange $list 1 end] {
        set themax [max $themax $arg]
    }
    return $themax
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


# main --
if {[is_main]} {
   # executed only if the file is the main script
   proc test {} {
      assert "lmax {23 56 100 23}" 100
      assert "lmax_r {23 56 100 102}" 102
      assert "factorial 1" 1
      assert "factorial 5" 120
      assert "factorial 10" 3628800
   }
   test
   exit
}