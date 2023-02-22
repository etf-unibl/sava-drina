onerror {quit -code 1}
source "C:/Users/AMG_Computers/Desktop/Faks/PDS_projekat/sava-drina/hardware/vunit_out/test_output/tb_lib.shift_register_tb.test_bc360b455ecc99f7a57541c311fdfd6cf444319a/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
