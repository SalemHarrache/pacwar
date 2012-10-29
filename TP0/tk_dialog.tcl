#!/bin/sh
# restart using wish \
exec tclsh "$0" "$@"

proc dialog { {message "hello"} {title "dialog"} {buttons {ok}} } {
    toplevel .dialog
    label .dialog.message -text $message
    pack .dialog.message -side top -fill both -expand true
    foreach name $buttons {
        button .dialog.$name -text $name
        bind .dialog.$name <1> { puts "Clic gauche" }
        bind .dialog.$name <2> { puts "Clic milieu" }
        bind .dialog.$name <3> { puts "Clic droit" }
        pack .dialog.$name -side right -padx 10 -pady 10
    }

    tkwait window.dialog
}

dialog