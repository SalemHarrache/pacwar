if [ $# -ne 1 ]; then
    wish ./lib/tkcon.tcl -load Tk app.tcl
else
    wish ./lib/tkcon.tcl -load Tk app_introspac.tcl
fi
