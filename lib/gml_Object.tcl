set found_Gmlobject 0
foreach loaded_dll [info loaded] {
    if {[lindex $loaded_dll 1] == "Gmlobject"} {set found_Gmlobject 1; break}
}

if {!$found_Gmlobject} {
    if {[catch {load gmlObject.dll} err]} {
	if {[catch {load libgiltclobject.so} err]} {
	    puts "Impossible to load any binary version of gmlObject, trying to load the TCL version..."
	    source gml_Object.old_tcl
	} else {
	    proc gmlObject args { eval [concat gilObject $args]}
	    puts "Linux binary gml lib loaded"
	}
    } else {puts "Windows binary version of gmlObject loaded"}
} 