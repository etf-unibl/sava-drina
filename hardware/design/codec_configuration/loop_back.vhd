-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina/
-----------------------------------------------------------------------------
--
-- unit name:    loop_back
--
-- description:
--
--  This unit is top level entity.
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
--! @file loop_back.vhd
--! @brief This unit creates codec configuration for loopback operation.
--! @details The loopback operation refers to a process where an analog audio signal is converted
--! to digital by an ADC (Analog-to-Digital Converter), processed or manipulated digitally, and then converted back
--! to analog by a DAC (Digital-to-Analog Converter) for output.

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! @brief Entity description codec configuration for loop_back.
--! @details Entity contains input for 50MHz clock. I2C_SCLK_O and I2C_SDAT_b are signals for I2C protocol.
--! Signal "AUD_XCK_o" is MCLK of audio codec.
entity loop_back is
  port(
    CLOCK_50_i     : in    std_logic;
    reset_i        : in    std_logic;
    --! I2C ports
    I2C_SCLK_o     : out   std_logic;
    I2C_SDAT_b     : inout std_logic;
    --! Audio codec port
    AUD_XCK_o      : out   std_logic
  );
end loop_back;

--! @brief Architecture definition of codec configuration for loop_back.
--! @details The architecture enables codec configuration using components whose roles will be described below.
--! clockBuffer component is PLL component from MegaWizard. Both input and output are 50MHz.
--! audioPLLClock component gives 18.42105 MHz from 50 MHz MCLK.
--! audioCodecController is i2C controller to drive the Wolfson codec.
architecture arch of loop_back is

--! clockBuffer component
  component clockBuffer is
    port
    (
      refclk    : in  std_logic  := '0';
      rst       : in  std_logic  := '0';
      outclk_0  : out std_logic
    );
  end component;

--! audioPLLClock component
  component audioPLLClock is
    port(
      --! Active high reset
      refclk   : in  std_logic  := '0';
      rst      : in  std_logic  := '0';
      outclk_0 : out std_logic
    );
  end component;

--! audiCodecController component
  component audioCodecController is
    port(
      clock50MHz_i        : in std_logic;
      reset_i             : in std_logic;
      I2C_SCLK_Internal_o : out std_logic;
      -- must be inout to allow FPGA to read the ack bit
      I2C_SDAT_Internal_o : out std_logic;
      SDAT_Control_o      : out std_logic;
      -- for testing
      clock50KHz_o        : out std_logic
    );
  end component;

  --! Clock signal from the PLL clockBuffers
  signal clock50MHz    : std_logic;

  --! 18MHz PLL output signal
  signal clock18MHz     : std_logic;

  --! I2C data and clock lines
  signal i2cData         : std_logic;
  signal i2cClock        : std_logic;

  --! Tri-state buffer control
  signal i2cDataControl  : std_logic;
  signal i2cDataTriState : std_logic;

  --! For testing
  signal clock50KHz     : std_logic;

begin

  --! PLLs
  clockBufferInstance : clockBuffer port map(refclk   => CLOCK_50_i,
                                             rst      => reset_i,
                                             outclk_0 => clock50MHz);

  audioPLLClockMap : audioPLLClock port map(refclk   => CLOCK_50_i,
                                            rst      => reset_i,
                                            outclk_0 => clock18MHz);

  --! I2C
  I2CControllerInstance : audioCodecController port map(clock50MHz_i        => clock50MHz,
                                                        reset_i             => reset_i,
                                                        I2C_SCLK_Internal_o => i2cClock,
                                                        I2C_SDAT_Internal_o => i2cData,
                                                        SDAT_Control_o      => i2cDataControl,
                                                        clock50KHz_o        => clock50KHz);

  --! Tri-state data output
  i2cDataTriState <= i2cData when i2cDataControl = '1' else 'Z';

  --! I2C output ports
  I2C_SCLK_o <= i2cClock;
  I2C_SDAT_b <= i2cDataTriState;

  --! Audio codec ouput port
  AUD_XCK_o <= clock18MHz;
end arch;
