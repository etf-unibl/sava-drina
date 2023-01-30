-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/pds-2022/
-----------------------------------------------------------------------------
--
-- unit name:     D_FF
--
-- description:
--
--   This file describe unit that is capable of: D flip flop
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
--!@brief D_FF 
-------------------------------------------------------

library ieee;
use ieee.STD_LOGIC_1164.all;

--!@brief D_FF entity 
--!@details entity with input and output ports 

entity D_FF is
  port(
       clk_i   : in std_logic;
       reset_i : in std_logic;
       D_i     : in std_logic;
       Q_o     : out std_logic);
end D_FF;

--!@details architecture of DFF 

architecture beh of D_FF is

--!@details process depends on clk and reset 

begin
  process(clk_i,reset_i)
  begin
    if(reset_i = '1') then
      Q_o <= '0';
    elsif(rising_edge(clk_i)) then
      Q_o <= D_i;
    end if;
  end process;
end beh;
