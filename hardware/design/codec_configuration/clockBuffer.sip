set_global_assignment -entity "clockBuffer" -library "lib_clockBuffer" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "clockBuffer" -library "lib_clockBuffer" -name IP_TOOL_VERSION "16.1"
set_global_assignment -entity "clockBuffer" -library "lib_clockBuffer" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_clockBuffer" -name SPD_FILE [file join $::quartus(sip_path) "clockBuffer.spd"]

set_global_assignment -library "lib_clockBuffer" -name MISC_FILE [file join $::quartus(sip_path) "clockBuffer_sim/clockBuffer.vho"]
