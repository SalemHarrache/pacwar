#!/bin/sh
# restart using tclsh \
exec wish "$0" "$@"

# load utilities
source [file join [file dirname [info script]] question6.tcl]

FormuleControl agent_central

TemperatureControlCelsius agent_temp_c agent_central
PressureControl agent_press agent_central
VolumeControl agent_volume agent_central
Introspact introspact agent_central