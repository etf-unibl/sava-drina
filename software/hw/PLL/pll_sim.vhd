-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina/
-----------------------------------------------------------------------------
--
-- unit name:     pll_sim
--
-- description:
--
--   This file implements PLL for AUD_XCK CODEC input.
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

entity pll_sim is
  port(
    clock_50_i : in  std_logic;
    reset_i    : in  std_logic;
    aud_xck_o  : out std_logic
  );
end pll_sim;

architecture arch of pll_sim is

  component pll is
    port(
      refclk     : in  std_logic     := '0'; -- clk
      rst        : in  std_logic     := '0'; -- reset
      outclk_0   : out std_logic;            -- clk
      locked     : out std_logic
    );
  end component pll;

  signal locked   : std_logic;
  signal clock_12 : std_logic;

begin

  u0 : component pll
    port map (
      refclk   => clock_50_i,
      rst      => reset_i,
      outclk_0 => clock_12,
      locked   => locked
  );
  aud_xck_o <= clock_12;
end arch;
