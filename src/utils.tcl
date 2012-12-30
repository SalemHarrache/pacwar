# tcl utils

# is_main --
#
#   check if the calling script was executed on the command line or sourced
#

set global_id 0

proc abspath {arg args} {
    set cmd "return \[file normalize \[file join $arg $args]]"
    eval $cmd
}

# Sound
load [abspath .. lib snack libsnack.so]
load [abspath .. lib snack libsound.so]
load [abspath .. lib snack libsnackogg.so]
source [abspath .. lib snack snack.tcl]


# globals
set pi [expr 4 * atan(1)]

proc to_radian {deg} {
  global pi
  return [expr ($pi * $deg)/ 180]
}

# utils
proc lremove {liste quoi} {
    return [lsearch -all -inline -not -exact $liste $quoi]
}

proc random {{range 10}} {
    return [expr {int(rand()*$range)}]
}

proc hsvToRgb {h s v} {
    set Hi [expr { int( double($h) / 60 ) % 6 }]
    set f [expr { double($h) / 60 - $Hi }]
    set s [expr { double($s)/255 }]
    set v [expr { double($v)/255 }]
    set p [expr { double($v) * (1 - $s) }]
    set q [expr { double($v) * (1 - $f * $s) }]
    set t [expr { double($v) * (1 - (1 - $f) * $s) }]
    switch -- $Hi {
        0 {
            set r $v
            set g $t
            set b $p
        }
        1 {
            set r $q
            set g $v
            set b $p
        }
        2 {
            set r $p
            set g $v
            set b $t
        }
        3 {
            set r $p
            set g $q
            set b $v
        }
        4 {
            set r $t
            set g $p
            set b $v
        }
        5 {
            set r $v
            set g $p
            set b $q
        }
        default {
            error "Wrong Hi value in hsvToRgb procedure! This should never happen!"
        }
    }
    set r [expr {round($r*255)}]
    set g [expr {round($g*255)}]
    set b [expr {round($b*255)}]
    return [list $r $g $b]
 }


proc get_random_color {} {
    set h [expr { int(256 * rand()) }]
    set s [expr { int(256 * rand()) }]
    set v [expr { int(256 * rand()) }]

    lassign [hsvToRgb $h $s $v] r g b

    return [format "#%02x%02x%02x" $r $g $b]
}

# path
proc cos {angle} {
    return [expr cos($angle)]
}
proc sin {angle} {
    return [expr sin($angle)]
}
proc toInt {num} {
    return [expr int($num)]
}

proc is_main {} {
  global argv0
  return [string equal [info script] $argv0]
}

proc is_defined {procname} {
  return [lsearch [info procs] $procname]
}

proc loop_sound sound {
    set cmd "$sound play -command {loop_sound $sound}"
    eval $cmd
}

# Images
proc get_random_planet_bg {} {
  set path [abspath .. ressources planet "planet[random 12].png"]
  return [image create photo -file $path]
}

proc get_ship_bg {name} {
  set path [abspath .. ressources ship "$name.png"]
  return [image create photo -file $path]
}

proc get_new_universe_bg {{num 0}} {
  set path [abspath .. ressources universe "universe[expr $num % 3].jpg"]
  return [image create photo -file $path]
}

# Canvas
proc move_canvas {w wid x y} {
    set movement {}
    foreach {xx yy} [$w coords $wid] {
        lappend movement [expr {$xx + $x}] [expr {$yy + $y}]
    }
    $w coords $wid $movement
}


proc initBackground {canvas sourceImage} {
    set tiledImage [image create photo]
    $canvas create image 0 0  -anchor nw  -image $tiledImage  -tags {backgroundBitmap}
    $canvas lower backgroundBitmap
    if {0} {
        proc {tile} {canvas sourceImage tiledImage} {
            $tiledImage copy $sourceImage  -to 0 0 [winfo width $canvas] [winfo height $canvas]
        }
        bind $canvas <Configure> [list tile $canvas $sourceImage $tiledImage]
        bind $canvas <Destroy> [list image delete $sourceImage $tiledImage]
        tile $canvas $sourceImage $tiledImage
    } else {
        # avoid needing a tile proc
        bind $canvas <Configure> "$tiledImage copy $sourceImage  -to 0 0 \[winfo width $canvas\] \[winfo height $canvas\]"
        bind $canvas <Destroy> [list image delete $sourceImage $tiledImage]
        $tiledImage copy $sourceImage  -to 0 0 [winfo width $canvas] [winfo height $canvas]
    }
}

#______________________________________________________________________________
# Add_aspect --
#
#   Inject code 'code' marked with 'mark' into a the method 'm' of a class 'c'
#
#______________________________________________________________________________
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

#______________________________________________________________________________
# Add_propagation --
#
#   Inject propagation code into a the method 'm' of a class 'c' that inherit directly or not from Control
#
#______________________________________________________________________________
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
proc generate_pac_agent {agent {abstraction 1} {presentation 1}} {
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
      }"
  }
  append cmd "
  inherit ${agent}Control Control

  # ${agent} Control --
  method ${agent}Control init {} {}

  method ${agent}Control constructor {{parent \"\"} {tk_parent \"\"}} {
  "
  if {$abstraction == 1} {
    if {$presentation == 1} {
      append cmd "
      ${agent}Presentation \${objName}_pres \$objName \$tk_parent
      ${agent}Abstraction \${objName}_abst \$objName
      this inherited \$parent \${objName}_abst \${objName}_pres
      this init
      \${objName}_abst init
      \${objName}_pres init
      "
    } else {
      append cmd "
      ${agent}Abstraction \${objName}_abst \$objName
      this inherited \$parent \${objName}_abst \"\"
      this init
      \${objName}_abst init
      "
    }
  } else {
    if {$presentation == 1} {
      append cmd "
      ${agent}Presentation \${objName}_pres \$objName \$tk_parent
      this inherited \$parent \"\" \${objName}_pres
      this init
      \${objName}_pres init
      "
    } else {
      append cmd "
      this inherited \$parent \"\" \"\"
      this init
      "
    }
  }
  append cmd "
  }
      method ${agent}Control destructor {} {
  }"
  # puts $cmd
  eval $cmd
}

# Cette fonction genère les classes PAC pour un agent donné
proc generate_pac_agent_multi_view {agent views} {
  foreach name $views {
      # generate pac agent without abstraction
      generate_pac_agent ${name}${agent} 0 1
  }
  generate_pac_agent ${agent} 1 0
  set cmd ""
  append cmd "
  method ${agent}Control constructor {{parent \"\"} {tk_parent \"\"}} {
    ${agent}Abstraction \${objName}_abst \$objName
    this inherited \$parent \${objName}_abst \"\"
    this init
    \${objName}_abst init
    foreach name \[\list ${views}\] {
        set this(\[string tolower \$name\]) \[\${name}${agent}Control \${name}_\${objName} \$objName \$tk_parent\]
    }
  }"
  # puts $cmd
  eval $cmd
}


proc generate_pac_accessors {agent var {propagate 0}} {

  set cmd ""

  # Generates accessors for the control facet $C
  if {[is_defined "${agent}Control"]} {
    append cmd "method ${agent}Control set_$var {v} {if {\$this(abstraction) != \"\"} {\$this(abstraction) set_$var \$v}}\n"
    append cmd "method ${agent}Control user_change_$var {v} {if {\$this(abstraction) != \"\"} {\$this(abstraction) set_$var \$v}}\n"
    append cmd "method ${agent}Control system_change_$var {v} {
                  if {\$this(presentation) != \"\"} {
                      \$this(presentation) set_$var \$v
                  }
                }\n"
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


proc generate_simple_accessors {class var} {
  if {[is_defined "${class}"]} {
    append cmd "method ${class} get_$var { } {return \$this($var)}\n"
    append cmd "method ${class} set_$var {v} {set this($var) \$v}\n"
  }
  eval $cmd
}


proc get_p1_control {} {
    return "
        bind . <Left>  \"\$objName send_event move_left\"
        bind . <Right> \"\$objName send_event move_right\"
        bind . <Up>    \"\$objName send_event move_up\"
        bind . <Down>  \"\$objName send_event move_down\"
    "
}

proc get_p2_control {} {
    return  "
        bind . <q>  \"\$objName send_event move_left\"
        bind . <d> \"\$objName send_event move_right\"
        bind . <z>    \"\$objName send_event move_up\"
        bind . <s>  \"\$objName send_event move_down\"
    "
}