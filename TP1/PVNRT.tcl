#!/bin/sh
#\
exec tclsh "$0" "$@"

namespace eval PVNRT {
	set n 1.   ; # mole number
	set R 8.31 ; # constant
	
	# equi --
	#
	#   given a pressure, volume and temperature, compute the equilibrium of
	#   an ideal gaz mole
	#
	# arguments:
	#   P     pressure (pascal)
	#   V     volume   (m^3)
	#   T     temperature (kelvin)
	#   type  kinf of transformation
	
	proc equi {P V T {type "isobare"}} {
		variable n
		variable R
		
		switch $type {
			"isotherme" -
			"T" {
				set PV [expr $n * $R * $T]
				set c [expr sqrt($PV / ($P * $V))]
				set P [expr $P * $c]
				set V [expr $V * $c]
			}
			"isochore" -
			"V" {
				set TiP [expr $V / ($n * $R)]
				set c [expr sqrt($TiP * $P / $T)]
				set T [expr $T * $c]
				set P [expr $P / $c]
				
			}
			"isobare" -
			"P" {
				set TiV [expr $P / ($n * $R)]
				set c [expr sqrt($TiV * $V / $T)]
				set T [expr $T * $c]
				set V [expr $V / $c]
			}
		}
		
		return "$P $V $T"
	}
}
