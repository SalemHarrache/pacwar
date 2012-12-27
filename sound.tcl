
# generate pac agent without abstraction
generate_pac_agent "Sound" 1 0 1
generate_pac_accessors "Sound" main_sound
generate_pac_accessors "Sound" battle_sound
generate_pac_accessors "Sound" end_sound

# ==> left volume
generate_pac_accessors "Sound" volume
generate_pac_accessors "Sound" rightvol


method SoundAbstraction init {} {
    this set_main_sound [snack::sound main_sound -file [abspath ressources sound main.mp3]]
    this set_battle_sound [snack::sound battle_sound -file [abspath ressources sound battle.mp3]]
    this set_end_sound [snack::sound end_sound -file [abspath ressources sound end.mp3]]

    this unmute
    loop_sound $this(main_sound)

    snack::mixer volume Vol $this(volume) $this(rightvol)
}

method SoundAbstraction mute {} {
    this set_rightvol 0
    this set_volume 0
}

method SoundAbstraction unmute {} {
    this set_rightvol 100
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

# method SoundControl system_change_volume {} {
#     puts "a implementer"
# }

# method SoundControl toggle_sound {} {

# }