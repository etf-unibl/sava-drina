#!/usr/bin/env python3
#-----------------------------------------------------------------------------
#--  % Name        : run.py         %                                       --                                      --
#--  % Version     : 1.0            %                                       --
#--  % Created_By  : SAVA - DRINA %                                       --
#--  % Date_Created: 2023-02-9    %                                       --
#--                                                                         --
#--  Description:                                                           --
#--  python script file to execute testbench via Vunit.                     --
#--                                                                         --
#-----------------------------------------------------------------------------

from pathlib import Path
from vunit import VUnit

# ROOT
ROOT = Path(__file__).resolve().parent

# Sources path for DUT
DUT_PATH = ROOT / "design"/"*"

# Sources path for TB
TEST_PATH = ROOT / "tests"

# create Vunit instance
VU = VUnit.from_argv()
VU.enable_location_preprocessing()



VU.add_library("design_lib").add_source_files(DUT_PATH/"*.vhd")

VU.add_library("tb_lib").add_source_files(TEST_PATH/"*.vhd")


VU.main()
