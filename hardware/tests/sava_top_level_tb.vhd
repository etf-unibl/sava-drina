LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.run_pkg.all;
use vunit_lib.check_pkg.all;

library design_lib;

entity sava_top_level_tb is
  generic (runner_cfg : string := runner_cfg_default);
end sava_top_level_tb;

architecture tb_arch of sava_top_level_tb is

-- Signal declarations
  signal sd_i_tst        : std_logic := '0';
  signal ws_i_tst        : std_logic := '0';
  signal clk_i_tst       : std_logic := '0';
  signal sck_i_tst       : std_logic := '0';
  signal sd_o_tst        : std_logic;
  signal ws_o_tst        : std_logic;
  signal reset_i_tst     : std_logic := '0';
  signal i2c_sclk_o_tst  : std_logic;
  signal i2c_sdat_b_tst  : std_logic;
  signal aud_xck_o_tst   : std_logic;
  signal start_stimuli : boolean := false;

begin
-- Component instantiation
  invdut : entity design_lib.sava_top_level
  port map (
    sd_i       => sd_i_tst,
    ws_i       => ws_i_tst,
    clk_i      => clk_i_tst,
    sck_i      => sck_i_tst,
    sd_o       => sd_o_tst,
    ws_o       => ws_o_tst,
    reset_i    => reset_i_tst,
    i2c_sclk_o => i2c_sclk_o_tst,
    i2c_sdat_b => i2c_sdat_b_tst,
    aud_xck_o  => aud_xck_o_tst);

clk: process
  begin
    clk_i_tst<= '1';
    wait for 20 ns;
	 while start_stimuli loop
	   clk_i_tst <= not(clk_i_tst);
		  wait for 20 ns;
         end loop;
end process;

sck: process
  begin
    sck_i_tst <= '1';
    wait for 80 ns;
	 while start_stimuli loop
	   sck_i_tst <= not(sck_i_tst);
		  wait for 80 ns;
         end loop;
end process;

sd: process
  begin
    sd_i_tst <= '0';
    wait for 50 ns;
	 while start_stimuli loop
	   sd_i_tst <= not(sd_i_tst);
		  wait for 50 ns;
         end loop;
  end process;

ws: process
  begin
    ws_i_tst <= '0';
    wait for 1000 ns;
	 while start_stimuli loop
	   ws_i_tst <= not(ws_i_tst);
		  wait for 1000 ns;
         end loop;
  end process;

main : process
  variable tmp : integer := 0;
begin
 test_runner_setup(runner, runner_cfg);
   while test_suite loop

           if run("data_transmission") then
            start_stimuli <= true;
            wait for 10 ns;
            reset_i_tst <= '1';
            wait for 100 ns;
            reset_i_tst <= '0';
            wait for 100 ns;
            while tmp < 30 loop
            wait until rising_edge(clk_i_tst);
            wait for 2 ns;
            check(sd_o_tst = sd_i_tst, "Checking if data is shifted from input to output.");
            wait for 2 ns;
            tmp := tmp + 1;
            wait for 2 ns;
            end loop;
          end if;
         wait for 3 ns;
     end loop;

test_runner_cleanup(runner);
end process;
end architecture;
