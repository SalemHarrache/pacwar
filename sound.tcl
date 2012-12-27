
# generate pac agent without abstraction
generate_pac_agent "Sound" 1 0 1
generate_pac_accessors "Sound" main_sound
generate_pac_accessors "Sound" battle_sound
generate_pac_accessors "Sound" end_sound

# ==> left volume
generate_pac_accessors "Sound" mode
generate_pac_accessors "Sound" volume




method SoundAbstraction init {} {
    this set_main_sound [snack::sound main_sound -file [abspath ressources sound main.mp3]]
    this set_battle_sound [snack::sound battle_sound -file [abspath ressources sound battle.mp3]]
    this set_end_sound [snack::sound end_sound -file [abspath ressources sound end.mp3]]
    this set_mode "main"
    this unmute
}

method SoundAbstraction stop_all {} {
    $this(main_sound) stop
    $this(battle_sound) stop
    $this(end_sound) stop
}

method SoundAbstraction switch_mode {mod} {
    this stop_all
    this set_mode $mod
    if {$mod=="main"} {
        loop_sound $this(main_sound)
    } else {
        if {$mod=="battle"} {
            loop_sound $this(battle_sound)
        } else {
            if {$mod=="end"} {
                $this(end_sound) play
            }
        }
    }
}

method SoundAbstraction mute {} {
    this stop_all
    this set_volume 0
}

method SoundAbstraction unmute {} {
    this switch_mode $this(mode)
    this set_volume 100
}


method SoundControl toggle_sound {} {
    if {[this get_volume] == 0} {
        $this(abstraction) unmute
    } else {
        $this(abstraction) mute
    }
}

method SoundControl system_change_volume { v } {
    $this(parent) sound_changed $v
}