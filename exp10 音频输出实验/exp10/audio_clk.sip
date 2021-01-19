set_global_assignment -entity "audio_clk" -library "lib_audio_clk" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "audio_clk" -library "lib_audio_clk" -name IP_TOOL_VERSION "17.1"
set_global_assignment -entity "audio_clk" -library "lib_audio_clk" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_audio_clk" -name SPD_FILE [file join $::quartus(sip_path) "audio_clk.spd"]

set_global_assignment -library "lib_audio_clk" -name MISC_FILE [file join $::quartus(sip_path) "audio_clk_sim/audio_clk.vo"]
