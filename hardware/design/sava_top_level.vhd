-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina-pds-2022/
-----------------------------------------------------------------------------
--
-- unit name: top_level_module
--
-- description:
--
--   This file implements top module for TX, RX, codec configuration and modulator.
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

-------------------------------------------------------
--!@file
--!@brief top_level_module
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--!@brief sava_top_level entity
--!@details This entity represent global entity for digital processing audio signal
--!@details Input signals sd_i, ws_i, clk_i, scl_i, sd_o
--!@details output signal sd_o

entity sava_top_level is
  port (
    sd_i       : in    std_logic;  --! Input serial data signal
    ws_i       : in    std_logic;  --! Input word select signal
    clk_i      : in    std_logic;  --! Input clock signal
    sck_i      : in    std_logic;  --! Input i2s clock signal
    sd_o       : out   std_logic;  --! Output serial data signal
    ws_o       : out   std_logic;  --! Output word select signal
    reset_i    : in    std_logic;  --! Input reset signal
    i2c_sclk_o : out   std_logic; --! Output i2c clock signal
    i2c_sdat_b : inout std_logic; --! Input/Output i2c data signal
    aud_xck_o  : out   std_logic  --! Codec MCLK signal
  );
end sava_top_level;

--!@brief  Architecture description of sava_drina_top_level
--!@details This architecture describe digital processing audio signal
--!@details With word select signal we choose witch channel we want (left or right)

architecture arch of sava_top_level is

  signal data_left, data_right : std_logic_vector(23 downto 0) := (others => '0');

  component loop_back is
    port(
    CLOCK_50_i     : in    std_logic; --! Input 50MHz clock signal
    reset_i        : in    std_logic; --! Input reset signal
    I2C_SCLK_o     : out   std_logic; --! Output i2c clock signal
    I2C_SDAT_b     : inout std_logic; --! Input/Output i2c data signal
    AUD_XCK_o      : out   std_logic  --! Codec MCLK signal
    );
  end component;

  component rx_line
    port (
      sd_i     : in  std_logic; --! Input serial data signal
      ws_i     : in  std_logic; --! Input word select signal
      clk_i    : in  std_logic; --! Input clock signal
      sck_i    : in  std_logic; --! Input i2s clock signal
      data_l_o : out std_logic_vector(23 downto 0); --! Output signal for left channel
      data_r_o : out std_logic_vector(23 downto 0)  --! Output signal for right channel
    );
  end component;

  component tx_line
    port (
      ws_i         : in  std_logic; --! Input word select signal
      data_left_i  : in  std_logic_vector(23 downto 0); --! Input buffer for left channel
      data_right_i : in  std_logic_vector(23 downto 0); --! Input buffer for right channel
      clk_i        : in  std_logic; --! Input clock signal
      scl_i        : in  std_logic; --! Input i2s clock signal
      sd_o         : out std_logic  --! Output serial data signal
    );
  end component;

  component modulation
    port(


    );
  end component;

begin
  codec_conf : loop_back
  port map(CLOCK_50_i   => clk_i,
           reset_i      => reset_i,
           I2C_SCLK_o   => i2c_sclk_o,
           I2C_SDAT_b   => i2c_sdat_b,
           AUD_XCK_o    => aud_xck_o);
		   
  receiver : rx_line
  port map(sd_i         => sd_i,
           ws_i         => ws_i,
           clk_i        => clk_i,
           sck_i        => sck_i,
           data_left_o  => data_left,
           data_right_o => data_right);

  transmitter : tx_line
  port map(ws_i         => ws_i,
           clk_i        => clk_i,
           sck_i        => sck_i,
           data_left_i  => data_left,
           data_right_i => data_right,
           sd_o         => sd_o);
		   
  modulator : modulation
  port map(


  );

  ws_o <= ws_i;
end arch;
