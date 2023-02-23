-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina/
-----------------------------------------------------------------------------
--
-- unit name:    clock50KHz
--
-- description:
--
--   This file implements divider of 50MHz clock by 1000.
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
--! @file clock50KHz.vhd
--! @brief This unit implements 50KHz clock for I2C module (I2C SCLK)

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
--! @brief Entity description for clock50KHz.
--! @details Input is 50MHz clock from PLL clockBuffer.
--! Output is 50KHz clock.
entity clock50KHz is
  port(
    clock_i       : in  std_logic;
    reset_i       : in  std_logic;
    clock50KHz_o  : out std_logic
  );
end clock50KHz;
--! @brief Architecture definition for clock50KHz.
--! @details 50MHz/1000 = 50KHz => count to 500, then invert the output.
architecture arch of clock50KHz is

  --! Count to half the period (500).
  signal count  : integer range 0 to 499;
  --! Output 50KHz clock signal.
  signal output : std_logic;

begin
  clock_div : process(clock_i,reset_i)
  begin
    --! Asynchronous active-high reset.
    if reset_i = '0' then
      --! Synchronous count.
      if rising_edge(clock_i) then
        if count = 499 then
          count <= 0;
          --! Count has reached 500(half-period).
          output <= not output;
        else
          count <= count + 1;
        end if;
      end if;
    else
      --! Reset
      count <= 0;
      output <= '0';
    end if;
  end process clock_div;

  --! Assign output signal.
  clock50KHz_o <= output;
end arch;