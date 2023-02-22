onerror {quit -code 1}
source "C:/Users/AMG_Computers/Desktop/Faks/PDS_projekat/sava-drina/hardware/vunit_out/test_output/tb_lib.dual_edge_detector_tb.d308aa0979c8d27d8d0942db939ac9e7d15baa134/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
