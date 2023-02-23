library ieee;
use ieee.std_logic_1164.all;

entity loop_back_tb is
end loop_back_tb;

architecture arch of loop_back_tb is

  -- Modelsim test signals
  -- I2C ports
  signal CLOCK_50  : std_logic := '0';
  signal reset     : std_logic := '0';
  signal I2C_SCLK  : std_logic;
  signal I2C_SDAT  : std_logic;
	
  -- audio codec port
  signal AUD_XCK   : std_logic;

  component loop_back is
    port(
      CLOCK_50_i  : in    std_logic;
      reset_i     : in    std_logic;
      -- I2C ports
      I2C_SCLK_o  : out   std_logic;
      I2C_SDAT_b  : inout std_logic;
      AUD_XCK_o   : out   std_logic
    );
  end component;

begin
  uut : loop_back
    port map(
      CLOCK_50_i  => CLOCK_50,
      reset_i     => reset,
      I2C_SCLK_o  => I2C_SCLK,
      I2C_SDAT_b  => I2C_SDAT,
      AUD_XCK_o   => AUD_XCK
    );

  -- simulation stimulus
  clk_stim : process
  begin
    -- wait 1/2 clock cycle (50MHz clock)
    wait for 10 ns;
    CLOCK_50 <= not CLOCK_50;
  end process clk_stim;
	
  -- temporary reset at start
  rst_stim : process
  begin
    -- active high reset
    reset <= '1';
    -- 1 clock cycle
    wait for 20 ns;
    reset <= '0';
    -- wait forever
    wait;
  end process rst_stim;	
end arch;
