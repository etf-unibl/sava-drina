onerror {quit -code 1}
source "C:/Users/AMG_Computers/Desktop/Faks/PDS_projekat/sava-drina/hardware/vunit_out/test_output/tb_lib.sub1_tb.test_substracti304cf14f602f76164913dda51749053b34d69ed0/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
