-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina/
-----------------------------------------------------------------------------
--
-- unit name:    ROMcontroller
--
-- description:
--
--  This file selects and returns a 24-bit word from the ROM, using input from the audio codec.
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
--! @file ROMcontroller.vhd
--! @brief This file selects and returns a 24-bit word from the ROM, using input from the audio codec.

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
--! Use numeric elements
use ieee.numeric_std.all;

--! @brief Entity description for ROMcontroller.
--! @details Input is an increment signal, which causes the address of the ROM to increment by one,
--! from 0 to 10 for 10 registers writing.
entity ROMcontroller is
  port(
    --! Asynch active-high reset
    reset_i      : in  std_logic;
    increment_i  : in  std_logic;
    clock50KHz_i : in  std_logic;
    clock50MHz_i : in  std_logic;
    ROMword_o    : out std_logic_vector(23 downto 0)
  );
end ROMcontroller;
--! @brief Architecture definition for ROMcontroller.
--! @details Architecture contains ROM 1-port memory module from MegaIP Wizard.
--! Using input from the audio codec, selects and returns a 24-bit word from the rom.
architecture arch of ROMcontroller is
  component codecROM is
    port
    (
      address : in std_logic_vector(4 downto 0);
      clock   : in std_logic  := '1';
      q       : out std_logic_vector(23 downto 0)
    );
  end component;

  --! Address vector sent to the ROM component
  signal address_vector_5 : std_logic_vector(4 downto 0);
  signal address_integer  : integer range 0 to 9 := 0;
  --! Output data vector from the ROM component
  signal data_vector_24   : std_logic_vector(23 downto 0);

begin

  codecROMInstance : codecROM port map(address => address_vector_5,
                                         clock => clock50MHz_i,
                                             q => data_vector_24);
  inc : process(clock50KHz_i, reset_i)
  begin
    if reset_i = '0' then
      if rising_edge(clock50KHz_i) then
        if increment_i = '1' then
          if address_integer < 9 then
            address_integer <= address_integer + 1;
          else
            address_integer <= 0;
          end if;
        end if;
      end if;
    else
      address_integer <= 0;
    end if;
  end process inc;
  --! Convert address integer into address vector.
  address_vector_5 <= std_logic_vector(to_unsigned(address_integer, 5));
  ROMword_o <= data_vector_24;
end arch;