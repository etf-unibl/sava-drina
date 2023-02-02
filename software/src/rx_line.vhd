-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/pds-2022/
-----------------------------------------------------------------------------
--
-- unit name: I2S receive side 
--
-- description:
--
--   This file implements receive side in I2S protocol
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



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_rx is
    Port ( bclk_i : in  std_logic;
           ws_i : in  std_logic;
           data_i : in  std_logic_vector (15 downto 0);
           valid_o : out  std_logic;
           data_left_o : out  std_logic_vector (15 downto 0);
           data_right_o : out  std_logic_vector (15 downto 0));
end i2s_rx;

architecture Behavioral of i2s_rx is
    type buffer_type is array (0 to 1) of std_logic_vector (15 downto 0); -- Buffer type (left channel or right channel)
    signal buffer_i : buffer_type := (others => (others => '0'));
    signal buffer_sel : integer range 0 to 1 := 0;
    signal sample : std_logic_vector(15 downto 0) := (others => '0');
	 signal a : integer := 1;

begin
    process (bclk_i, ws_i)  
    begin
        if (bclk_i'event and bclk_i = '1') then
            if (ws_i = '0') then
                sample <= data_i;
            elsif (ws_i = '1') then
                buffer_i(buffer_sel) <= sample; -- sacuvati podatke u jedan od bafera
                buffer_sel <= buffer_sel xor a; -- međusobno iskljucivanje bafera (ili se koristi jedan ili drugi)
            end if;
        end if;
    end process;
    
    data_left_reg : process (bclk_i)
    begin
        if (bclk_i'event and bclk_i = '1') then
            data_left_o <= buffer_i(0);
        end if;
    end process;
    
    data_right_reg : process (bclk_i)
    begin
        if (bclk_i'event and bclk_i = '1') then
            data_right_o <= buffer_i(1);
        end if;
    end process;
    
    valid_o_reg : process (bclk_i, ws_i)
    begin
        if (bclk_i'event and bclk_i = '1') then
            if (ws_i = '1') then
                valid_o <= '1';
            else
                valid_o <= '0';
            end if;
        end if;
    end process;
end Behavioral;
