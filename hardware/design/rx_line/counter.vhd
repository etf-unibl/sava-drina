-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/pds-2022/
-----------------------------------------------------------------------------
--
-- unit name: counter
--
-- description:
--
--   This file implements counter
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

--entity with imputs and outputs
entity counter is
    port (clk, reset, enable : in std_logic;
          count : out std_logic_vector (23 downto 0));
end counter;
--architecture
architecture arch of counter is
  signal count_pom : unsigned (23 downto 0);
begin
    process (clk, reset)
    begin
        if (reset = '1') then
            count_pom <= (others => '0');
        elsif (clk'event and clk = '1' and enable = '1') then
		if(count_pom = 24) then
			count_pom <= (others => '0');
		else
			count_pom <= count_pom + 1;
		end if;
        end if;
    end process;
		count <= std_logic_vector(count_pom);
end arch;
					
