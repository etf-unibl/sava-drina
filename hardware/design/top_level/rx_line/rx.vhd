-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/pds-2022/
-----------------------------------------------------------------------------
--
-- unit name: rx
--
-- description:
--
--   This file implements Rx line
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
--! @brief Preamble generator
-----------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
--! Use numeric elements
use ieee.numeric_std.all;

--! @details The entity describes all the necessary input and
--! output signals needed to realize this complex circuit.


entity rx is
  port(
    bclk_i   : in std_logic;
    clk_i    : in std_logic;
    ws_i     : in std_logic;
    sd_i     : in std_logic;
    data_l_o : out std_logic_vector(23 downto 0);
    count_o  : out std_logic_vector(23 downto 0);
    data_r_o : out std_logic_vector(23 downto 0)
  );
end rx;

-- Architecture of receiver design

architecture arch of rx is
component buffer_r_l
  port (write_enable : in std_logic;
        clk_i        : in std_logic;
        data_in      : in std_logic_vector (23 downto 0);
        data_out     : out std_logic_vector (23 downto 0)
       );
end component;

-- all needed signals
  signal register_out, count_c, left_channel, right_channel : std_logic_vector(23 downto 0) := (others => '0');
  signal en_data, en_receive, counter_limit : std_logic := '0';
  signal reset_r : std_logic := '1';
  signal en_left_line, en_right_line : std_logic;

-- including all components below
component counter
  port (clk, reset, enable : in std_logic;
        count : out std_logic_vector (23 downto 0)
       );
end component;

component shift_register
  port (clk      : in std_logic;
        reset    : in std_logic;
        enable   : in std_logic;
        data_in  : in std_logic;
        data_out : out std_logic_vector(23 downto 0)
       );
end component;

component dual_edge_detector
    port (
      clk_i    : in std_logic;
      rst_i    : in std_logic;
      strobe_i : in std_logic;
      p_o      : out std_logic
    );
end component;

-- We need to provide sending data from input to side for processing data.
-- There are the following steps to send data to shift register and then to left or right buffer.

-- Mapping components to signals in rx design
begin
 ws_detector : dual_edge_detector
  port map(
    clk_i    => clk_i,
    rst_i    => '0',
    strobe_i => ws_i,
    p_o      => en_receive);

  bclk_detector : dual_edge_detector
  port map(clk_i    => clk_i,
           rst_i    => '0',
           strobe_i => bclk_i,
           p_o      => en_data);

reset_to_low : process (clk_i, en_receive)
  begin
    if (en_receive = '1') then
      reset_r <= '0';
    end if;
  end process;

counter_limit <= '1' when (count_c = "000000000000000000010111") else
                 '0';
en_left_line  <= (not ws_i) and counter_limit;
en_right_line <= (ws_i) and counter_limit;

shift_reg : shift_register
  port map(clk      => clk_i,
           reset    => reset_r,
           enable   => en_data,
           data_in  => sd_i,
           data_out => register_out);

counter_count : counter
  port map(clk    => clk_i,
           reset  => reset_r,
           enable => en_data,
           count  => count_c);

left_line : buffer_r_l
  port map(write_enable => en_left_line,
           clk_i        => clk_i,
           data_in      => register_out,
           data_out     => left_channel);

right_line : buffer_r_l
  port map(write_enable => en_right_line,
           clk_i        => clk_i,
           data_in      => register_out,
           data_out     => right_channel);

--Outputs
data_l_o <= left_channel;
data_r_o <= right_channel;
count_o  <= count_c;
end arch;
