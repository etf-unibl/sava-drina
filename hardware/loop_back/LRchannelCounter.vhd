-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina/
-----------------------------------------------------------------------------
--
-- unit name:    LRchannelCounter
--
-- description:
--
--  This unit implements left and right channel counter for audio codec.
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
--! @file LRchannelCounter.vhd
--! @brief This unit implements left and right channel counter for audio codec.

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
--! @brief Entity description for LRchannelCounter.
--! @details
entity LRchannelCounter is
  port(
    --! Active high reset
    reset_i     : in  std_logic;
    bclk_i      : in  std_logic;
    --! left = '1', right = '0'
    LRchannel_o : out std_logic
  );
end LRchannelCounter;
--! @brief Architecture definition for LRchannelCounter
--! @details Architecture implements left channel, right channel counter for audio codec.
--! The state changes after 16 falling-edge cycles of the bitClock.
architecture arch of LRchannelCounter is

  signal count  : integer range 0 to 15 := 0;
  signal output : std_logic             := '1';

begin
  counter : process(reset_i, bclk_i)
  begin
    if reset_i = '1' then
      output <= '1';
      count <= 0;
    elsif falling_edge(bclk_i) then
      if count < 15 then
        count <= count + 1;
      else
        output <= not output;
        count <= 0;
      end if;
    end if;
  end process counter;
  LRchannel_o <= output;
end arch;
