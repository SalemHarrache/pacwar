#### setup
package require Img
package require Tk
package require XOTcl
namespace import xotcl::*


#### globals
set ::pi  [expr 4 * atan(1)]
set ::deg [expr $pi / 180]

# z coordinate of the vector product of a triangle
proc zVecProd {p1x p1y p2x p2y p3x p3y} {
   return [expr ($p1x - $p3x) * ($p2y - $p3y) - \
                ($p1y - $p3y) * ($p2x - $p3x)]
}

# return true if the triangles PQR1 and PQR2 have edge intersection
proc edgeIntersect {p1x p1y q1x q1y r1x r1y p2x p2y q2x q2y r2x r2y} {

  if {[zVecProd $r2x $r2y $p2x $p2y $q1x $q1y] >= 0.0} {

    if {[zVecProd $p1x $p1y $p2x $p2y $q1x $q1y] >= 0.0} {
        return [expr [zVecProd $p1x $p1y $q1x $q1y $r2x $r2y] >= 0.0]
    }

    return [expr {[zVecProd $q1x $q1y $r1x $r1y $p2x $p2y] >= 0.0 &&
                  [zVecProd $r1x $r1y $p1x $p1y $p2x $p2y] >= 0.0}]
  }

  if {[zVecProd $r2x $r2y $p2x $p2y $r1x $r1y] < 0.0} {
     return 0
  }

  if {[zVecProd $p1x $p1y $p2x $p2y $r1x $r1y] >= 0.0} {

     return [expr {[zVecProd $p1x $p1y $r1x $r1y $r2x $r2y] >= 0.0 ||
                   [zVecProd $q1x $q1y $r1x $r1y $r2x $r2y] >= 0.0}]
  }

  return 0
}

# return true if triangle 1 (pqr) intersects 2 (pqr) via a vertex
proc vertIntersect {p1x p1y q1x q1y r1x r1y p2x p2y q2x q2y r2x r2y} {

   if {[zVecProd $r2x $r2y $p2x $p2y $q1x $q1y] >= 0.0} {

      if {[zVecProd $r2x $r2y $q2x $q2y $q1x $q1y] <= 0.0} {

         if {[zVecProd $p1x $p1y $p2x $p2y $q1x $q1y] > 0.0} {

            return [expr {[zVecProd $p1x $p1y $q2x $q2y $q1x $q1y] <= 0.0}]
         }

         return [expr {[zVecProd $p1x $p1y $p2x $p2y $r1x $r1y] >= 0.0 &&
                       [zVecProd $q1x $q1y $r1x $r1y $p2x $p2y] >= 0.0}]
      }

      return [expr {[zVecProd $p1x $p1y $q2x $q2y $q1x $q1y] <= 0.0 &&
                    [zVecProd $r2x $r2y $q2x $q2y $r1x $r1y] <= 0.0 &&
                    [zVecProd $q1x $q1y $r1x $r1y $q2x $q2y] >= 0.0}]
   }

   if {[zVecProd $r2x $r2y $p2x $p2y $r1x $r1y] < 0.0} {
      return 0
   }

   if {[zVecProd $q1x $q1y $r1x $r1y $r2x $r2y] >= 0.0} {

      return [expr {[zVecProd $p1x $p1y $p2x $p2y $r1x $r1y] >= 0.0}]
   }

   return [expr {[zVecProd $q1x $q1y $r1x $r1y $q2x $q2y] >= 0.0 &&
                 [zVecProd $r2x $r2y $r1x $r1y $q2x $q2y] >= 0.0}]
}

# return true if triangle 1 (pqr) intersects triange 2 (pqr)
proc triIntersect {p1x p1y q1x q1y r1x r1y p2x p2y q2x q2y r2x r2y} {

   if {[zVecProd $p2x $p2y $q2x $q2y $p1x $p1y] >= 0.0} {

      if {[zVecProd $q2x $q2y $r2x $r2y $p1x $p1y] >= 0.0} {

         if {[zVecProd $r2x $r2y $p2x $p2y $p1x $p1y] >= 0.0} {
            return 1
         }

         return [edgeIntersect $p1x $p1y $q1x $q1y $r1x $r1y $p2x $p2y $q2x $q2y $r2x $r2y]
      }

      if {[zVecProd $r2x $r2y $p2x $p2y $p1x $p1y] >= 0.0} {
         return [edgeIntersect $p1x $p1y $q1x $q1y $r1x $r1y $r2x $r2y $p2x $p2y $q2x $q2y]
      }

      return [vertIntersect $p1x $p1y $q1x $q1y $r1x $r1y $p2x $p2y $q2x $q2y $r2x $r2y]
   }

   if {[zVecProd $q2x $q2y $r2x $r2y $p1x $p1y] >= 0.0} {
      if {[zVecProd $r2x $r2y $p2x $p2y $p1x $p1y] >= 0.0} {
         return [edgeIntersect $p1x $p1y $q1x $q1y $r1x $r1y $q2x $q2y $r2x $r2y $p2x $p2y]
      }

      return [vertIntersect $p1x $p1y $q1x $q1y $r1x $r1y $q2x $q2y $r2x $r2y $p2x $p2y]
   }

   return [vertIntersect $p1x $p1y $q1x $q1y $r1x $r1y $r2x $r2y $p2x $p2y $q2x $q2y]
}

#### Car class
Class create ^Car

^Car instproc init {{x 15} {y 10}} {
   my instvar carAng carSpeed carX carY

   set carAng   [expr 5 * $::pi / 8]
   set carSpeed  0
   set carX     $x
   set carY     $y
}

^Car instproc checkWalls {ret} {
   my instvar carAng carSpeed carX carY

   set minX [expr min([lindex $ret 0],[lindex $ret 2],[lindex $ret 4])]
   set minY [expr min([lindex $ret 1],[lindex $ret 3],[lindex $ret 5])]

   set maxX [expr max([lindex $ret 0],[lindex $ret 2],[lindex $ret 4])]
   set maxY [expr max([lindex $ret 1],[lindex $ret 3],[lindex $ret 5])]

   set cwidth  [.c cget -width]
   set cheight [.c cget -height]

   if {$minX < 0} {
      set carX [expr $carX - $minX]
      set carSpeed 0
   } elseif {$maxX > $cwidth} {
      set carX [expr $carX - $maxX + $cwidth]
      set carSpeed 0
   }

   if {$minY < 0} {
      set carY [expr $carY - $minY]
      set carSpeed 0
   } elseif {$maxY > $cheight} {
      set carY [expr $carY - $maxY + $cheight]
      set carSpeed 0
   }
}

# construct a triplet of coords
^Car instproc makeCar {} {
   my instvar carAng carSpeed carX carY

   set r 10 ;# car "radius" (size)
   set t $carAng
   set offX $carX
   set offY $carY

   set ret ""

   # point 1, right side
   lappend ret [expr $r * cos($t+90*$::deg) + $offX]
   lappend ret [expr $r * sin($t+90*$::deg) + $offY]

   # point 2, left side
   lappend ret [expr $r * cos($t-90*$::deg) + $offX]
   lappend ret [expr $r * sin($t-90*$::deg) + $offY]

   # point 3, front
   lappend ret [expr 2*$r * cos($t) + $offX]
   lappend ret [expr 2*$r * sin($t) + $offY]

   return $ret
}

^Car instproc move {} {
   my instvar carX carY carSpeed carAng

   # adjust position for speed
   set carX [expr $carX + $carSpeed/4.0 * cos($carAng)]
   set carY [expr $carY + $carSpeed/4.0 * sin($carAng)]
}

^Car instproc accel {{amt 1}} {
   my instvar carSpeed
   incr carSpeed $amt
}

^Car instproc incrAng {} {
   my instvar carAng carSpeed

   set amt [expr (abs($carSpeed)+3) / 4.0 * $::deg]
   set carAng [expr $carAng + $amt]
   if {$carAng >= 2 * $::pi} {
      set carAng 0
   }
}

^Car instproc decrAng {} {
   my instvar carAng carSpeed

   set amt [expr (abs($carSpeed)+3) / 4.0 * $::deg]
   set carAng [expr $carAng - $amt]
   if {$carAng < 0} {
      set carAng [expr 2 * $::pi]
   }
}

#### cars
^Car create p1car ;# player 1 car
^Car create ccar 200 200;# computer car


#### event loop
proc eventLoop {} {
   p1car move
   ccar move

   set c1loc [p1car makeCar]
   set c2loc [ccar makeCar]
   p1car checkWalls $c1loc
   ccar  checkWalls $c2loc

   if {[triIntersect {*}$c1loc {*}$c2loc]} {
      p1car set carSpeed 0
      ccar  set carSpeed 0
   }

   # redraw car
   .c coords $::carId  $c1loc
   .c coords $::ccarId $c2loc

   after 30 eventLoop
}

proc abspath {arg args} {
    set cmd "return \[file normalize \[file join $arg $args]]"
    eval $cmd
}

proc get_new_universe_bg {{num 0}} {
  set path [abspath .. ressources universe "universe[expr $num % 3].jpg"]
  return [image create photo -file $path]
}

pack [canvas .c] -side top -expand 1 -fill both

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

initBackground .c [get_new_universe_bg]

set ::carId  [.c create poly [p1car makeCar] -fill blue -tags car]
set ::ccarId [.c create poly [ccar makeCar] -fill red -tags car]

bind .c <Left>  {p1car decrAng}
bind .c <Right> {p1car incrAng}
bind .c <Up>    {p1car accel}
bind .c <Down>  {p1car accel -1}
bind .c <Enter> {focus %W}

bind .c <Configure> {
   %W configure -width  [winfo width  .c]
   %W configure -height [winfo height .c]
}

initBackground .c [get_new_universe_bg]

eventLoop