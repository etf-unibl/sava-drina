-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina/
-----------------------------------------------------------------------------
--
-- unit name:    delayCounter
--
-- description:
--
--  This unit implements 40ms delay.
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

-- after reset clears, waits for 40ms, then asserts a reset signal at the output
-- input is the 50MHz clock from the clockBuffer
-- 40ms(50MHz) = 2x10^6 counts
-- integer type can hold -(2^31-1) -> (2^31-1)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delayCounter is
  port(
    clock_i    : in  std_logic;
    reset_i    : in  std_logic;
    -- active high reset
    resetAdc_o : out std_logic
  );
end delayCounter;

architecture arch of delayCounter is
  -- count up to 2x10^6
  signal count  : integer range 0 to 1999999;
  -- active-high output signal
  signal output : std_logic;
begin
  delay : process(clock_i,reset_i,output)
  begin
    -- asynchronous active-high reset
    -- stop counting after setting the output
    if reset_i = '0' then
      -- synchronous count
      if rising_edge(clock_i) then
        if output = '0' then
          if count = 1999999 then
            count <= 0;
            -- count has reached 2x10^6 (40ms), assert resetAdc_o
            output <= '1';
          else
            count <= count + 1;
          end if;
        end if;
      end if;
    else
      -- in reset
      count <= 0;
      -- resetAdc_o is not asserted
      output <= '0';
    end if;
  end process delay;
  -- assign output signal
  resetAdc_o <= output;
end arch;
