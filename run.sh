if [ $# -ne 1 ]; then
    ./lib/tkcon.tcl -load Tk app.tcl
else
    ./lib/tkcon.tcl -load Tk app_introspac.tcl
fi
