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
--  This unit is loopback top level entity.
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
--! @brief This unit creates loopback operation.
--! @details The loopback operation refers to a process where an analog audio signal is converted
--! to digital by an ADC (Analog-to-Digital Converter), processed or manipulated digitally, and then converted back
--! to analog by a DAC (Digital-to-Analog Converter) for output.

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! @brief Entity description for loop_back.
--! @details Entity contains inputs for key and 50MHz MCLK clock. I2C_SCLK_O and I2C_SDAT_b are signals for I2C protocol.
--! Signals with prefix "AUD_" are signals for audio codec.
entity loop_back is
  port(
    KEY_i          : in    std_logic_vector(0 downto 0);
    CLOCK_50_i     : in    std_logic;
    --! I2C ports
    I2C_SCLK_o     : out   std_logic;
    I2C_SDAT_b     : inout std_logic;
    --! Audio codec ports
    AUD_ADCDAT_i   : in    std_logic;
    AUD_ADCLRCK_o  : out   std_logic;
    AUD_DACLRCK_o  : out   std_logic;
    AUD_DACDAT_o   : out   std_logic;
    AUD_XCK_o      : out   std_logic;
    AUD_BCLK_o     : out   std_logic;
    --! Output for logic analyzer
    GPIO_0_b       : inout std_logic_vector (7 downto 0);
    LEDR_o         : out   std_logic_vector (0 downto 0)
  );
end loop_back;

--! @brief Architecture definition for loop_back.
--! @details The architecture enables loopback operation using components whose roles will be described below.
--! clockBuffer component is PLL component from MegaWizard. Both input and output are 50MHz.
--! audioPLLClock component gives 18.42105 MHz from 50 MHz MCLK.
--! audioCodecController is O2C controller to drive the Wolfson codec.
--! delayCounter waits 40ms, then asserts high output.
--! AdcDacController generates digital audio interface clock signals, starts after delayCounter asserts (40ms).
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

--! delayCounter component
  component delayCounter is
    port(
      clock_i    : in  std_logic;
      reset_i    : in  std_logic;
      --! Active high reset
      resetAdc_o : out std_logic
    );
  end component;

--! AdcDacController component
  component AdcDacController is
    port(
      --! Reset signal starts '0', then goes to '1' after 40 ms => active-low
      resetn_i      : in std_logic;
      --! From 50MHz PLL at toplevel
      clock18MHz_i  : in std_logic;
      --! Line-in on the DE1
      adcData_i     : in std_logic;
      --! Line-out on the DE1
      dacData_o     : out std_logic;
      bitClock_o    : out std_logic;
      dacLRSelect_o : out std_logic;
      adcLRSelect_o : out std_logic
    );
  end component;

  --! Clock signal from the PLL clockBuffers
  signal clock50MHz    : std_logic;

  --! 18MHz PLL output signal
  signal clock18MHz     : std_logic;

  --! Asynchronous reset for the whole project
  signal reset          : std_logic;

  --! I2C data and clock lines
  signal i2cData         : std_logic;
  signal i2cClock        : std_logic;

  --! Tri-state buffer control
  signal i2cDataControl  : std_logic;
  signal i2cDataTriState : std_logic;

  --! Assert signal from delay counter
  signal codecResetn     : std_logic;

  --! Audio codec signals
  signal adcDat_sig     : std_logic;
  signal adcLRCK_sig    : std_logic;
  signal dacLRCK_sig    : std_logic;
  signal dacDat_sig     : std_logic;
  signal bck_sig        : std_logic;

  --! For testing
  signal clock50KHz     : std_logic;

begin

  --! Keys are active low
  reset <= not KEY_i(0);

  --! PLLs
  clockBufferInstance : clockBuffer port map(refclk   => CLOCK_50_i,
                                             rst      => reset,
                                             outclk_0 => clock50MHz);

  audioPLLClockMap : audioPLLClock port map(refclk   => CLOCK_50_i,
                                            rst      => reset,
                                            outclk_0 => clock18MHz);

  --! I2C
  I2CControllerInstance : audioCodecController port map(clock50MHz_i        => clock50MHz,
                                                        reset_i             => reset,
                                                        I2C_SCLK_Internal_o => i2cClock,
                                                        I2C_SDAT_Internal_o => i2cData,
                                                        SDAT_Control_o      => i2cDataControl,
                                                        clock50KHz_o        => clock50KHz);

  --! Delay counter
  delayCounterMap : delayCounter port map(clock_i    => clock50MHz,
                                          reset_i    => reset,
                                          resetAdc_o => codecResetn);

  --! Codec Controller
  AdcDacControllerMap : AdcDacController port map(resetn_i      => codecResetn,
                                                  clock18MHz_i  => clock18MHz,
                                                  adcData_i     => adcDat_sig,
                                                  dacData_o     => dacDat_sig,
                                                  bitClock_o    => bck_sig,
                                                  dacLRSelect_o => dacLRCK_sig,
                                                  adcLRSelect_o => adcLRCK_sig);

  --! Tri-state data output
  i2cDataTriState <= i2cData when i2cDataControl = '1' else 'Z';

  --! I2C output ports
  I2C_SCLK_o <= i2cClock;
  I2C_SDAT_b <= i2cDataTriState;

  --! Audio codec input port
  adcDat_sig <= AUD_ADCDAT_i;

  --! Audio codec ouput ports
  AUD_ADCLRCK_o <= adcLRCK_sig;
  AUD_DACLRCK_o <= dacLRCK_sig;
  AUD_DACDAT_o <= dacDat_sig;
  AUD_XCK_o <= clock18MHz;
  AUD_BCLK_o <= bck_sig;

  GPIO_0_b(0) <= adcDat_sig;
  GPIO_0_b(1) <= adcLRCK_sig;
  GPIO_0_b(2) <= dacLRCK_sig;
  GPIO_0_b(3) <= dacDat_sig;
  GPIO_0_b(6) <= clock18MHz;
  GPIO_0_b(7) <= bck_sig;

  GPIO_0_b(4) <= reset;
  GPIO_0_b(5) <= codecResetn;

  LEDR_o(0) <= reset;
end arch;
