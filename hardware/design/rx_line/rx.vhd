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
    bclk_i : in std_logic;
    ws_i : in std_logic;
    sd_i : in std_logic;
    data_l_o : out std_logic_vector(23 downto 0);
    count_o : out std_logic_vector(23 downto 0);
    data_r_o : out std_logic_vector(23 downto 0)
  );
end rx;

--! @brief Architecture definition sending data from input to side for processing data .
--! @details There are the following steps to send data to shift register,
--! and after that data are sending to two baffer. We have to baffer.

architecture arch of rx is
component buffer_r_l
  port (write_enable : in std_logic;
        data_in : in std_logic_vector (23 downto 0);
        data_out : out std_logic_vector (23 downto 0)
       );
end component;
component counter
  port (clk, reset, enable : in std_logic;
        count : out std_logic_vector (23 downto 0)
       );
end component;
component shift_register
  port (clk : in  STD_LOGIC;
        enable : in  STD_LOGIC;
        data_in : in  STD_LOGIC;
        data_out : out  STD_LOGIC_VECTOR (23 downto 0)
       );
end component;
  signal data, count_c, data_l, data_r : std_logic_vector(23 downto 0) := (others => '0');
  signal counter_s_s : std_logic := '0';
  signal enable_e : std_logic := '0';
  signal reset_r : std_logic := '1';
  signal enable_l, enable_r : std_logic;
begin

process(ws_i)
begin
  if(falling_edge(ws_i) and enable_e = '1') then
    enable_e <= '0';
    reset_r <= '0';
  end if;
end process;

counter_s_s <= '1' when (count_c = "000000000000000000010111") else
               '0';
enable_l <= (not ws_i) and counter_s_s;
enable_r <= ws_i and counter_s_s;
shift_reg : shift_register
  port map(clk => bclk_i, enable => enable_e, data_in => sd_i, data_out => data);
counter_count : counter
  port map(clk => bclk_i, reset => reset_r, enable => enable_e, count => count_c);
left_buffer : buffer_r_l
  port map(write_enable => enable_l, data_in => data, data_out => data_l);
right_buffer : buffer_r_l
  port map(write_enable => enable_r, data_in => data, data_out => data_r);
--Outputs
data_l_o <= data_l;
data_r_o <= data_r;
count_o <= count_c;
end arch;
