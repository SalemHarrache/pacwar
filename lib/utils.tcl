# tcl utils

# is_main --
#
#   check if the calling script was executed on the command line or sourced
#

proc is_main {} {
	global argv0
	return [string equal [info script] $argv0]
}


# assert --
#
#   check the result of an expression
#

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
