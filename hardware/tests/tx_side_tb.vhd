----------------------------------------------------------------------------
-- LIBRARY DECLARATION.
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.run_pkg.all;
use vunit_lib.check_pkg.all;

library design_lib;

entity tx_side_tb is
  generic (runner_cfg : string := runner_cfg_default);
end entity;

architecture tb of tx_side_tb is
signal sd_tst        : std_logic;
signal clk_tst       : std_logic;
signal sclk_tst      : std_logic;
signal ws_tst        : std_logic;
signal l_data_tst    : std_logic_vector(23 downto 0) := (others => '0');
signal r_data_tst    : std_logic_vector(23 downto 0) := (others => '0');
signal start_stimuli : boolean := false;

begin
  invdut : entity design_lib.tx_side
    port map(
	          sd_o      => sd_tst,
		  sclk_i    => sclk_tst,
		  ws_i      => ws_tst,
		  l_data_i    => l_data_tst,
                  clk_i     => clk_tst,
		  r_data_i    => r_data_tst);

clk_proc : process
begin
  clk_tst <= '0';
  wait for 1 ns;
    while start_stimuli loop
	   clk_tst <= not (clk_tst);
		  wait for 1 ns;
	 end loop;
end process;
				 
sclk_proc : process
begin
  sclk_tst <= '0';
  wait for 10 ns;
    while start_stimuli loop
	   sclk_tst <= not (sclk_tst);
		  wait for 10 ns;
	 end loop;
end process;

ws: process
  begin
    ws_tst <= '1';
    wait for 200 ns;
	 while start_stimuli loop
	   ws_tst <= not(ws_tst);
		  wait for 200 ns;
         end loop;
  end process;

main : process
begin
 test_runner_setup(runner, runner_cfg);
 
   while test_suite loop
	
	  if run("left_channel") then
	    start_stimuli <= true;
            l_data_tst <= "101010001101011100101010";
            wait for 3 ns;
            wait until ws_tst = '0';
            wait for 3 ns;
            check(sd_tst = l_data_tst(0), "Podatak se prosljedjuje sa lijevog kanala");
		  
          elsif run("right_channel") then
	    start_stimuli <= true;
            r_data_tst <= "011010101110010101010110";
            wait for 3 ns;
            wait until ws_tst = '1';
            wait for 3 ns;
            check(sd_tst = r_data_tst(0), "Podatak se prosljedjuje sa desnog kanala");
            wait for 500 ns;
            
          end if;
       end loop;
	
test_runner_cleanup(runner);
end process;
end architecture;
