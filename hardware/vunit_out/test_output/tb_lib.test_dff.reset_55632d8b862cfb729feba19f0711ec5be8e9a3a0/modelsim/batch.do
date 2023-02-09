onerror {quit -code 1}
source "C:/Users/AMG_Computers/Desktop/Faks/PDS_projekat/sava-drina/hardware/vunit_out/test_output/tb_lib.test_dff.reset_55632d8b862cfb729feba19f0711ec5be8e9a3a0/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
