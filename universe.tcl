
# Génération d'un agent pac multivue : MapUniverse et MiniMapUniverse
generate_pac_agent_multi_view "Universe" [list "Map" "MiniMap"]

# Génération d'un methode pour acceder au canvas_map parent depuis universe.
generate_pac_parent_accessors Universe canvas_map
generate_pac_parent_accessors Universe canvas_mini_map
# Génération d'un methode pour acceder au canvas_map parent depuis les deux
# vues de l'argent universe : MapUniverse et MiniMapUniverse
generate_pac_parent_accessors MapUniverse canvas_map
generate_pac_parent_accessors MiniMapUniverse canvas_mini_map
# Generation des accesseurs pour les attributs
generate_pac_presentation_accessors MapUniverse canvas_map
generate_pac_presentation_accessors MiniMapUniverse canvas_mini_map

proc drag.canvas.item {canWin item newX newY} {
    set xDiff [expr {$newX - $::x}]
    set yDiff [expr {$newY - $::y}]

    set ::x $newX
    set ::y $newY

    puts $xDiff
    puts $yDiff
    $canWin move $item $xDiff $yDiff
}

method MapUniversePresentation init {} {
    global ressources_dir
    this set_canvas_map [$this(control) get_parent_canvas_map]
    $this(canvas_map) configure -width 400 -height 200 -background "#191919"

    set background_file [file join $ressources_dir universe background.png]
    set background [image create photo -file $background_file]
    $this(canvas_map) create image 0 0 -anchor nw -image $background


    $this(canvas_map) create oval 80 80 140 140 \
        -fill yellow \
        -tag mobile

    set cmd "
    $this(canvas_map) create oval 80 80 140 140 -fill yellow -tag mobile"

    append cmd "
    $this(canvas_map) bind mobile <Button-1> {
        set selected \[$this(canvas_map) find closest %x %y\]
        set atx %x
        set aty %y
    }"

    append cmd "
    $this(canvas_map) bind mobile <B1-Motion> {
        set changed_x \[expr %x - \$atx\]
        set changed_y \[expr %y - \$aty\]
        $this(canvas_map) move \$selected \$changed_x \$changed_y
        set atx %x
        set aty %y
    }"
    eval $cmd

}


method MiniMapUniversePresentation init {} {
    global ressources_dir
    this set_canvas_mini_map [$this(control) get_parent_canvas_mini_map]
    $this(canvas_mini_map) configure -width 200 -height 200 -background "#1E1E1E"

    set background_file [file join $ressources_dir universe background_mini.jpg]
    set background [image create photo -file $background_file]
    $this(canvas_mini_map) create image 0 0 -anchor nw -image $background

}