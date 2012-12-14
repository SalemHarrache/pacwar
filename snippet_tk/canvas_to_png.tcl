 proc CanvasToPic { canvasID } {
           set returnThis [catch {package require Img} version]
       #Gets the contents of the canvas canvasID and put into photo image photoimage.
       set returnThis [catch {image create photo -format window -data $canvasID} photoimage]
       if { $returnThis != 0 } {
          puts "\nERROR: Cannot create photo!!!"
          exit 1
       }
       return $photoimage
   }

   canvas .c1 -width 460 -height 350 -bg white -relief groove \
           -borderwidth 4
   grid .c1 -row 1 -column 1 -columnspan 2
   frame .f1
   button .f1.b1 -text "Selection Board" -command {
   .c1 create line 55 0 55 350 -width 2
   for { set q 1 } { $q <= 21 } { incr q } {
   .c1 create rect 10 10 30 30 -fill red -tag movable
   .c1 create poly 30 10 30 30 50 30 -fill blue -tag movable -outline black
   .c1 create poly 30 10 50 10 50 30 -fill blue -tag movable -outline black

   .c1 create rect 10 30 30 50 -fill red -tag movable
   .c1 create poly 30 30 30 50 50 30 -fill blue -tag movable -outline black
   .c1 create poly 50 30 30 50 50 50 -fill blue -tag movable -outline black

   .c1 create rect 10 50 30 70 -fill blue -tag movable
   .c1 create poly 30 50 30 70 50 50 -fill red -tag movable -outline black
   .c1 create poly 50 50 30 70 50 70 -fill red -tag movable -outline black

   .c1 create rect 10 70 30 90 -fill blue -tag movable
   .c1 create poly 30 70 30 90 50 90 -fill red -tag movable -outline black
   .c1 create poly 30 70 50 70 50 90 -fill red -tag movable -outline black


   .c1 create rect 10 90 30 110 -fill green -tag movable
   .c1 create poly 30 90 30 110 50 110 -fill yellow -tag movable -outline black
   .c1 create poly 30 90 50 90 50 110 -fill yellow -tag movable -outline black
   .c1 create poly 30 50 30 70 50 50 -fill red -tag movable -outline black
   .c1 create poly 50 50 30 70 50 70 -fill red -tag movable -outline black

   .c1 create rect 10 110 30 130 -fill green -tag movable
   .c1 create poly 30 110 30 130 50 130 -fill yellow -tag movable -outline black
   .c1 create poly 30 110 50 110 50 130 -fill yellow -tag movable -outline black

   .c1 create rect 10 130 30 150 -fill yellow -tag movable
   .c1 create poly 30 130 30 150 50 130 -fill green -tag movable -outline black
   .c1 create poly 50 130 30 150 50 150 -fill green -tag movable -outline black

   .c1 create rect 10 150 30 170 -fill yellow -tag movable
   .c1 create poly 30 150 30 170 50 150 -fill green -tag movable -outline black
   .c1 create poly 50 150 30 170 50 170 -fill green -tag movable -outline black

   .c1 create rect 10 170 30 190 -fill lightgreen -tag movable
   .c1 create rect 30 170 50 190 -fill lightblue -tag movable

   .c1 create rect 10 190 30 210 -fill black -tag movable
   .c1 create rect 30 190 50 210 -fill white -tag movable -outline black

   .c1 create rect 10 210 30 230 -fill brown -tag movable
   .c1 create rect 30 210 50 230 -fill orange -tag movable -outline black

   .c1 create rect 10 230 30 250 -fill black -tag movable
   .c1 create rect 30 230 50 250 -fill white -tag movable -outline black

   .c1 create rect 10 250 30 270 -fill brown -tag movable
   .c1 create rect 30 250 50 270 -fill orange -tag movable -outline black

   .c1 create rect 10 270 30 290 -fill cyan -tag movable
   .c1 create rect 30 270 50 290 -fill grey -tag movable -outline black

   .c1 create rect 10 290 30 310 -fill magenta -tag movable
   .c1 create rect 30 290 50 310 -fill purple -tag movable -outline black


   .c1 create oval 10 310 30 330 -fill brown -tag movable
   .c1 create oval 30 310 50 330 -fill orange -tag movable -outline black

   .c1 create oval 10 330 30 350 -fill red -tag movable
   .c1 create oval 30 330 50 350 -fill blue -tag movable -outline black
   }
   .f1.b1 configure -state disabled
   }

   button .f1.b2 -text "Clear All" -command {
   .c1 delete all
   .f1.b1 configure -state normal
   }

   button .f1.b3 -text "MakePngImage" -command {
   set photoimage [CanvasToPic .c1]
   puts $photoimage
   puts "Writing photoimage in PNG format: photoimage.png"
   $photoimage write photoimage.png -format PNG
   }

   pack .f1.b1 -side left
   pack .f1.b2 -side left
   pack .f1.b3 -side left
   grid .f1 -row 2 -column 1

   proc CanvasMarkIt { x y can } {
   global canvas
   $can raise current
   set x [$can canvasx $x]
   set y [$can canvasy $y]
   set canvas($can,obj) [ $can find closest $x $y ]
   set canvas($can,x) $x
   set canvas($can,y) $y
   }

   proc CanvasDragIt { x y can } {
   global canvas
   set x [$can canvasx $x]
   set y [$can canvasy $y]
   set dx [expr $x - $canvas($can,x)]
   set dy [expr $y - $canvas($can,y)]
   $can move $canvas($can,obj) $dx $dy
   set canvas($can,x) $x
   set canvas($can,y) $y
   }

   .c1 bind movable <Button-1>  {CanvasMarkIt %x %y %W}
   .c1 bind movable <B1-Motion> {CanvasDragIt %x %y %W}