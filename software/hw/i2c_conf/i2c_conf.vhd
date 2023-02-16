-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2022
-- https://github.com/knezicm/sava-drina/
-----------------------------------------------------------------------------
--
-- unit name:     i2c_conf
--
-- description:
--
--   This unit is top-level entity.
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

entity i2c_conf is
  port(
    clock_50_i  : in     std_logic;
    -- reset_i  : in     std_logic;
    aud_xck_o   : out    std_logic;
    i2c_sda_b   : inout  std_logic_vector(0 downto 0);
    gpio_sda_b  : inout  std_logic_vector(0 downto 0);
    i2c_sclk_i  : in     std_logic;
    gpio_sclk_o : out    std_logic
  );
end i2c_conf;

architecture arch of i2c_conf is

  component pll is
    port(
      refclk     : in  std_logic     := '0'; -- clk
      rst        : in  std_logic     := '0'; -- reset
      outclk_0   : out std_logic;            -- clk
      locked     : out std_logic
    );
  end component pll;
  
  component input_buf is
    port 
    ( 
      datain  : in  std_logic_vector (0 downto 0);
      dataout : out std_logic_vector (0 downto 0)
    ); 
  end component input_buf;
  
  component output_buf is 
    port 
    ( 
      datain  : in  std_logic_vector (0 downto 0);
      dataout : out std_logic_vector (0 downto 0);
      oe      : in  std_logic_vector (0 downto 0) := (others => '1')
    ); 
  end component output_buf;
  
  component edge_det
    port(
      clk_i    : in  std_logic;
      input_i  : in  std_logic;
      edge_o   : out std_logic
    );
  end component edge_det;

  type t_fsm_state is (idle, s1, s2);
  signal state_reg    : t_fsm_state;
  signal state_next   : t_fsm_state;

  signal locked       : std_logic;
  signal clock_12     : std_logic;

  signal codec_edge   :	std_logic;
  signal gpio_edge    :	std_logic;

  signal i1           : std_logic_vector(0 downto 0);
  signal i2           : std_logic_vector(0 downto 0);
  signal t1           : std_logic_vector(0 downto 0);
  signal t2           : std_logic_vector(0 downto 0);
  signal o1           : std_logic_vector(0 downto 0);
  signal o2           : std_logic_vector(0 downto 0);

  signal i2c_sda_sig  : std_logic_vector(0 downto 0);
  signal gpio_sda_sig : std_logic_vector(0 downto 0);

begin

  u0 : component pll
    port map (
      refclk   => clock_50_i,
      rst      => '0', -- reset_i,
      outclk_0 => clock_12,
      locked   => locked
  );

  codec_in_buf : component input_buf 
    port map (
      datain  => i2c_sda_sig,
		dataout => i1
  );

  codec_out_buf : component output_buf 
    port map (
      datain  => o1,
      dataout => i2c_sda_sig,
      oe      => t1
  );

  gpio_in_buf : component input_buf 
    port map (
      datain  => gpio_sda_sig,
		dataout => i2
  );

  gpio_out_buf : component output_buf 
    port map (
      datain  => o2,
      dataout => gpio_sda_sig,
      oe      => t2
  );

  codec_edge_det : edge_det
    port map (
      clk_i   => clock_50_i,
      input_i => i1(0),
      edge_o  => codec_edge
  );
			  
  gpio_edge_det : edge_det
    port map (
      clk_i   => clock_50_i,
      input_i => i2(0),
      edge_o  => gpio_edge
  );
 
  o1 <= (others => '0');
  o2 <= (others => '0');

  i2c_sda_sig <= i2c_sda_b;
  gpio_sda_sig <= gpio_sda_b;
 
  -- state register
  process(clock_50_i) is
  begin
    if rising_edge(clock_50_i) then
      state_reg <= state_next;
    end if;
  end process;
 
  -- next state logic
  process(state_reg,gpio_edge,codec_edge) is
  begin
    case state_reg is
      when idle =>
        if gpio_edge = '1' then
          state_next <= s1;
        elsif codec_edge = '1' then
          state_next <= s2;
        else
          state_next <= idle;
        end if;
      when s1 =>
        if gpio_edge = '1' then
          state_next <= idle;
        else
          state_next <= s1;
        end if;
      when s2 =>
        if codec_edge = '1' then
          state_next <= idle;
        else
          state_next <= s2;
        end if;
    end case;
  end process;

  -- output logic
  process(state_reg) is
  begin
    case state_reg is
      when idle =>
        t1 <= (others => '1');
        t2 <= (others => '1');
      when s1 =>
        t1 <= (others => '0');
        t2 <= (others => '1');
      when s2 =>
        t1 <= (others => '1');
        t2 <= (others => '0');
    end case;
  end process;

  aud_xck_o <= clock_12;
  gpio_sclk_o <= i2c_sclk_i;
end arch;
