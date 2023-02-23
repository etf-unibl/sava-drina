-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina/
-----------------------------------------------------------------------------
--
-- unit name: tx_line
--
-- description:
--
--   This file implements I2S transmitter
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
--! @file
--! @brief tx
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tx is

        port
        (
         data_left_i  : in std_logic_vector (23 downto 0); --! Input buffer for left channel
         data_right_i : in std_logic_vector (23 downto 0); --! Input buffer for right channel
         clk_i        : in std_logic; --! Input clock signal
         bclk_i       : in std_logic; --! Input i2s clock signal
         ws_i         : in std_logic; --! Input word select signal
         data_o       : out std_logic); --! Output serial data signal
end tx;


architecture arch of tx is

signal en_tran       : std_logic := '0';
signal en_data       : std_logic := '0';
signal counter_limit : std_logic := '0';
signal reset_r       : std_logic := '1';
signal en_left_line  : std_logic;
signal en_right_line : std_logic;
signal count_c       : std_logic_vector(23 downto 0) := (others => '0');
signal sd_l_o        : std_logic := '0';
signal sd_r_o        : std_logic := '0';
signal data_l        : std_logic_vector(23 downto 0) := (others => '0');
signal data_r        : std_logic_vector(23 downto 0) := (others => '0');

component buffer_l_r
  port(
       write_enable     : in std_logic;
       clk_i            : in std_logic;
       data_i           : in std_logic_vector(23 downto 0);
       data_o           : out std_logic_vector(23 downto 0));
end component;


component counter
  port(
       clk_i    : in std_logic;
       reset_i  : in std_logic;
       enable_i : in std_logic;
       count_o  : out std_logic_vector (23 downto 0));
end component;



component dual_edge_detector
    port (
          clk_i    : in std_logic;
          rst_i    : in std_logic;
          strobe_i : in std_logic;
          p_o      : out std_logic);
end component;


component shift_register
  port (clk_i     : in std_logic;
        reset_i   : in std_logic;
        enable_i  : in std_logic;
        data_i    : in std_logic_vector(23 downto 0);
        data_o    : out std_logic);
end component;


begin
ws_detector : dual_edge_detector
  port map(
           clk_i    => clk_i,
           rst_i    => '0',
           strobe_i => ws_i,
           p_o      => en_tran);

bclk_detector : dual_edge_detector
  port map(
           clk_i      => clk_i,
           rst_i      => '0',
           strobe_i   => bclk_i,
           p_o        => en_data);


reset_to_low : process (clk_i, en_tran)
  begin
    if en_tran = '1' then
      reset_r <= '0';
    end if;
end process;

counter_limit <= '1' when (count_c = "000000000000000000010111") else
                 '0';
en_left_line  <= (not ws_i) and en_data;
en_right_line <= (ws_i) and en_data;

left_line : buffer_l_r
  port map(
           write_enable => en_left_line,
           clk_i        => clk_i,
           data_i       => data_left_i,
           data_o       => data_l);

right_line : buffer_l_r
  port map(
           write_enable => en_right_line,
           clk_i        => clk_i,
           data_i       => data_right_i,
           data_o       => data_r);


shift_reg_l : shift_register
  port map(
          clk_i      => clk_i,
          reset_i    => reset_r,
          enable_i   => en_left_line,
          data_i     => data_l,
          data_o     => sd_l_o);

shift_reg_r : shift_register
  port map(
          clk_i    => clk_i,
          reset_i  => reset_r,
          enable_i => en_right_line,
          data_i   => data_r,
          data_o   => sd_r_o);

counter_count : counter
  port map(
           clk_i    => clk_i,
           reset_i  => reset_r,
           enable_i => en_data,
           count_o  => count_c);

data_o <= sd_l_o when en_left_line = '1' else
          sd_r_o when en_right_line = '1';

end arch;
