
# generate pac agent without abstraction
generate_pac_agent Sound
generate_pac_accessors Sound battle_sound
generate_pac_accessors Sound end_sound

generate_pac_accessors Sound mode
generate_pac_accessors Sound volume_level

generate_pac_presentation_accessors Sound frame


# Abstraction
method SoundAbstraction init {} {
    this set_battle_sound [snack::sound battle_sound -file [abspath .. ressources sound battle.mp3]]
    this set_end_sound [snack::sound end_sound -file [abspath .. ressources sound end.mp3]]
    set this(mode) "battle"
    set this(volume_level) 0
}

method SoundAbstraction set_mode {value} {
    set this(mode) $value
    if {$this(volume_level) == 100} {
        this play
    }
}

method SoundAbstraction stop_all {} {
    $this(battle_sound) stop
    $this(end_sound) stop
}

method SoundAbstraction play {} {
    this stop_all
    if {$this(mode)=="battle"} {
        loop_sound $this(battle_sound)
    } elseif {$this(mode)=="end"} {
        $this(end_sound) play
    }
}

method SoundAbstraction mute {} {
    this stop_all
    this set_volume_level 0
}

method SoundAbstraction unmute {} {
    this play
    this set_volume_level 100
}


# Control
method SoundControl init {} {
    $this(parent) set_sfx_manager $objName
    bind . <Control-Key-s> "$objName toggle_sound"
}

method SoundControl toggle_sound {} {
    if {[this get_volume_level] == 0} {
        $this(abstraction) unmute
    } else {
        $this(abstraction) mute
    }
}

# Presentation
method SoundPresentation init {} {
    this set_frame [$this(control) get_parent_value frame_panel_sound]
    set this(volume_label) [label $this(frame).volume_label -justify center -text "Volume : [this get_volume_level]"]
    pack $this(volume_label) -expand 1 -fill both
}

method SoundPresentation set_volume_level {v} {
    $this(volume_label) configure -text "Volume :  $v"
}