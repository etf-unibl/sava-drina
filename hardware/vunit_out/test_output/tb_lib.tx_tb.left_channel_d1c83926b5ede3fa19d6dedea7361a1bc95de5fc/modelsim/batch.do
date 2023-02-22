onerror {quit -code 1}
source "C:/Users/AMG_Computers/Desktop/Faks/PDS_projekat/sava-drina/hardware/vunit_out/test_output/tb_lib.tx_tb.left_channel_d1c83926b5ede3fa19d6dedea7361a1bc95de5fc/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
