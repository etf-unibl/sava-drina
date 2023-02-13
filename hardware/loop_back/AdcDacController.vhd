-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina/
-----------------------------------------------------------------------------
--
-- unit name:    AdcDacController
--
-- description:
--
--  This unit creates the ADC and DAC signals needed by the audio codec.
--
-----------------------------------------------------------------------------
-- Copyright (c) 2022 Faculty of Electrical Engineering
-----------------------------------------------------------------------------
-- The MIT License
-----------------------------------------------------------------------------
-- Copyright 2022 Faculty of Electrical Engineering
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom
-- the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE
-----------------------------------------------------------------------------
--! @file AdcDacController.vhd
--! @brief This unit creates the ADC and DAC signal needed by the audio codec.
--! @details Inputs are reset from the delay buffer, 50MHz clock from PLL

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! @brief Entity description for AdcDacController.
--! @details This entity contains clock and reset inputs.
--! Input adcData_i refers to analog signal from line-in, and dacData_o refers to signal who will be on line-out.
entity AdcDacController is
  port(
    resetn_i      : in  std_logic; --! Reset signal starts '0', then goes to '1' after 40 ms => active-low
    clock18MHz_i  : in  std_logic; --! From 50MHz PLL at toplevel
    adcData_i     : in  std_logic; --! Line-in - analog to digital
    dacData_o     : out std_logic; --! Line-out - digital to analog
    bitClock_o    : out std_logic; --! Digital audio bit clock
    dacLRSelect_o : out std_logic; --! Output signal - Left/right channel signal
    adcLRSelect_o : out std_logic  --! Output signal - Left/right channel signal
  );
end AdcDacController;

--! @brief   Architecture definition for AdcDacController.
--! @details Architecture implements loopback operation.
--! @details The loopback operation in ADC to DAC audio refers to a process where an analog audio signal is converted
--! to digital by an ADC (Analog-to-Digital Converter), processed or manipulated digitally, and then converted back
--! to analog by a DAC (Digital-to-Analog Converter) for output.

architecture arch of AdcDacController is
--! BitCount generator. Changes every 12 counts of the MCLK (18MHz)
  component bclk_counter is
    port(
      --! Active high reset
      reset_i : in  std_logic;
      mclk_i  : in  std_logic;
      bclk_o  : out std_logic
    );
  end component;
--! Generates left/right channel signal
  component LRchannelCounter is
    port(
      --! Active high reset
      reset_i     : in  std_logic;
      bclk_i      : in  std_logic;
      --! Left = '1', Right = '0'
      LRchannel_o : out std_logic
    );
  end component;

 --! Active-high reset
  signal reset         : std_logic;
 --! Bit clock
  signal bitClock_sig  : std_logic;
 --! Left/right channnel control signal
  signal LRchannel_sig : std_logic;

begin

 --! Turns active-low reset into active-high
  reset <= not resetn_i;

  bclk_counterMap : bclk_counter port map(reset_i => reset,
                                          mclk_i  => clock18MHz_i,
                                          bclk_o  => bitClock_sig);

  LRchannelCounterMap : LRchannelCounter port map(reset_i     => reset,
                                                  bclk_i      => bitClock_sig,
                                                  LRchannel_o => LRchannel_sig);

 --! Output signals
  bitClock_o <= bitClock_sig;
  dacLRSelect_o <= LRchannel_sig;
  adcLRSelect_o <= LRchannel_sig;

 --! Loop-back
  dacData_o <= adcData_i;
end arch;
