

# source app.tcl
# Pour l'instant on affiche juste celui du tp 1 pour voir
source [file join [file dirname [info script]] .. lib init.tcl]
source [file join [file dirname [info script]] .. TP1 question6.tcl]

# executed only if the file is the main script
FormuleControl agent_central

TemperatureControlCelsius agent_temp_c agent_central
PressureControl agent_press agent_central
VolumeControl agent_volume agent_central

Introspact introspact agent_central