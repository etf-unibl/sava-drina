-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina/
-----------------------------------------------------------------------------
--
-- unit name:    bclk_counter
--
-- description:
--
--  This unit implements bit clock counter for audio codec.
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

-- bitCount counter for audio codec.  Input is 18MHz clock (master clock) from PLL. Output is
-- 1 period is 12 counts of the master clock => flip the output every 6 counts

library ieee;
use ieee.std_logic_1164.all;

entity bclk_counter is
  port(
    -- active high reset
    reset_i  : in  std_logic;
    mclk_i   : in  std_logic;
    bclk_o   : out std_logic
  );
end bclk_counter;

architecture arch of bclk_counter is

  signal count  : integer range 0 to 5 := 0;
  signal output : std_logic            := '0';

begin
  counter : process(reset_i, mclk_i)
  begin
    if reset_i = '1' then
      count <= 0;
    elsif rising_edge(mclk_i) then
      if count < 5 then
        count <= count + 1;
      else
        output <= not output;
        count <= 0;
      end if;
    end if;
  end process counter;
  bclk_o <= output;
end arch;
