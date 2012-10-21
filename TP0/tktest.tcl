

proc dialog { {message "hello"} {title "dialog"} {buttons {ok}} } {
    toplevel .dialog
    label .dialog.message -text $message
    pack .dialog.message -side top -fill both -expand true
    foreach name $buttons {
        button .dialog.$name -text $name
        bind .dialog.$name <1> { puts "$name" }
        bind .dialog.$name <2> { puts "$name$name" }
        pack .dialog.$name -side right -padx 10 -pady 10
    }

    tkwait window.dialog
}


