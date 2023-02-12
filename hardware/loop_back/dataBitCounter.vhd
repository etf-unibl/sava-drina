-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina/
-----------------------------------------------------------------------------
--
-- unit name:    dataBitCounter
--
-- description:
--
--   This file counts the data bits (0 to 23) sent to the audio codec.
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

-- synchronous counter using the 50khz clock from the audioCodecController
-- counts the dataBits (0 to 23) sent to the audio codec

library ieee;
use ieee.std_logic_1164.all;

entity dataBitCounter is
  port(
    -- active high count enable
    countEnable_i      : in  std_logic;
    -- active high reset
    reset_i            : in  std_logic;
    clock_i            : in  std_logic;
    currentBitCount_o  : out integer;
    currentWordCount_o : out integer
  );
end dataBitCounter;

architecture arch of dataBitCounter is

  -- output
  signal countBit  : integer range 0 to 23 := 23;
  signal countWord : integer range 0 to 10 := 0;
begin
  -- starts counting when reset is cleared and enable is
  counter : process(clock_i, reset_i, countEnable_i)
  begin
    if reset_i = '0' then
      if rising_edge(clock_i) then
        if countEnable_i = '1' then
          if countBit > 0 then
            countBit <= countBit - 1;
          else
            countBit <= 23;
            if countWord < 10 then
              countWord <= countWord + 1;
            else
              countWord <= 0;
            end if;
          end if;
        end if;
      end if;
    else
      countBit <= 23;
      countWord <= 0;
    end if;
  end process counter;

  currentBitCount_o <= countBit;
  currentWordCount_o <= countWord;
end arch;
