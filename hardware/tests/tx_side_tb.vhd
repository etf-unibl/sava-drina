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
signal bclk_tst      : std_logic;
signal ws_tst        : std_logic;
signal l_data_tst    : std_logic_vector(23 downto 0) := (others => '0');
signal r_data_tst    : std_logic_vector(23 downto 0) := (others => '0');
signal start_stimuli : boolean := false;

begin
  invdut : entity design_lib.tx_side
    port map(
	          sd_o      => sd_tst,
		  bclk_i    => bclk_tst,
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
				 
bclk_proc : process
begin
  bclk_tst <= '0';
  wait for 10 ns;
    while start_stimuli loop
	   bclk_tst <= not (bclk_tst);
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
   variable tmp   : integer := 0;
   variable tmp_v : std_logic_vector(23 downto 0) := (others => '0');
   while test_suite loop

	  if run("left_channel") then
	    start_stimuli <= true;
            l_data_tst <= "101010101010101010101010";
            while i < 3 loop
            l_data_tst <= l_data_tst xor tmp_v;
            while tmp < 24 loop
            wait for 3 ns;
            wait until ws_tst = '0';
            wait for 3 ns;
            check(sd_tst = l_data_tst(tmp), "Podatak se prosljedjuje sa lijevog kanala");
            wait for 5 ns;
            tmp = tmp + 1;
            end loop;
            tmp_v <= tmp_v(18 downto 0) & "10110"
            end loop;

          elsif run("right_channel") then
	    start_stimuli <= true;
            l_data_tst <= "101010101010101010101010";
            while i < 3 loop
            l_data_tst <= l_data_tst xor tmp_v;
            while tmp < 24 loop
            wait for 3 ns;
            wait until ws_tst = '1';
            wait for 3 ns;
            check(sd_tst = r_data_tst(tmp), "Podatak se prosljedjuje sa desnog kanala");
            wait for 5 ns;
            tmp = tmp + 1;
            end loop;
            tmp_v <= tmp_v(18 downto 0) & "10110"
            end loop;
            wait for 500 ns;
          end if;
       end loop;

test_runner_cleanup(runner);
end process;
end architecture;
