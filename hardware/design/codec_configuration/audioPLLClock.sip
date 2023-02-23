set_global_assignment -entity "audioPLLClock" -library "lib_audioPLLClock" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "audioPLLClock" -library "lib_audioPLLClock" -name IP_TOOL_VERSION "16.1"
set_global_assignment -entity "audioPLLClock" -library "lib_audioPLLClock" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_audioPLLClock" -name SPD_FILE [file join $::quartus(sip_path) "audioPLLClock.spd"]

set_global_assignment -library "lib_audioPLLClock" -name MISC_FILE [file join $::quartus(sip_path) "audioPLLClock_sim/audioPLLClock.vho"]
