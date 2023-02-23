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
--   This file implements delay for 40ms and then asserts a reset signal at the output.
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
--! @file delayCounter.vhd
--! @brief This file implements delayCounter.

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
--! Use numeric elements
use ieee.numeric_std.all;

--! @brief Entity description for delayCounter.
--! @details After reset clears, waits for 40ms, then asserts a reset signal at the output.
--! Input is the 50MHz clock from the clockBuffer.
--! 40ms(50MHz) = 2x10^6 counts
--! integer type can hold -(2^31-1) -> (2^31-1)
entity delayCounter is
  port(
    clock    : in  std_logic;
    reset    : in  std_logic;
--! Active high reset
    resetAdc : out std_logic
    );
end delayCounter;

--! @brief Architecture definition for delayCounter.
--! @details A detailed implementation of the architecture is commented below.
architecture arch of delayCounter is

  --! Count up to 2x10^6
  signal count : integer range 0 to 1999999;
  --! Active-high output signal
  signal output : std_logic;

begin

  u1 : process(clock,reset,output)
  begin
  --! Asynchronous active-high reset
  --! Stop counting after setting the output
    if reset = '0' then
    --! Synchronous count
      if rising_edge(clock) then
        if output = '0' then
          if count = 1999999 then --! 1999 for 40us
            count <= 0;
          --! Count has reached 2x10^6 (40ms), assert resetAdc
            output <= '1';
          else
            count <= count + 1;
          end if;
        end if;
      end if;
    else
    --! In reset
      count <= 0;
    --! ResetAdc is not asserted
      output <= '0';
    end if;
  end process u1;

  --! Assign output signal
  resetAdc <= output;

end arch;
