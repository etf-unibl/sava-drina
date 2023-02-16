-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina/
-----------------------------------------------------------------------------
--
-- unit name:     edge_det
--
-- description:
--
--   This file implements dual edge detection.
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

entity edge_det is
  port(
    clk_i    : in   std_logic;
    input_i  : in   std_logic;
    edge_o   : out  std_logic
  );
end edge_det;

architecture arch of edge_det is

  type t_state is (zero, one);
  signal state_next, state_reg : t_state;

begin

  -- state register
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      state_reg <= state_next;
    end if;
  end process;

  -- next state logic
  process(state_reg, input_i)
  begin
    case state_reg is
      when zero =>
        if input_i = '1' then
          state_next <= one;
        else
          state_next <= zero;
        end if;
      when one =>
        if input_i = '0' then
          state_next <= zero;
        else
          state_next <= one;
        end if;
    end case;
  end process;

  -- output
  edge_o <= '1' when (state_reg = zero) and (input_i = '1') else
            '1' when (state_reg = one)  and (input_i = '0') else
            '0';
end arch;
