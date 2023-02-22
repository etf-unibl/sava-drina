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

entity tx_tb is
  generic (runner_cfg : string := runner_cfg_default);
end entity;

architecture tb of tx_tb is
signal sd_tst        : std_logic;
signal clk_tst       : std_logic;
signal bclk_tst      : std_logic;
signal ws_tst        : std_logic;
signal l_data_tst    : std_logic_vector(23 downto 0) := (others => '0');
signal r_data_tst    : std_logic_vector(23 downto 0) := (others => '0');
signal start_stimuli : boolean := false;

begin
  invdut : entity design_lib.tx
    port map(
	          data_o       => sd_tst,
		  bclk_i       => bclk_tst,
		  ws_i         => ws_tst,
		  data_left_i  => l_data_tst,
                  clk_i        => clk_tst,
		  data_right_i => r_data_tst);

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
    ws_tst <= '0';
    wait for 5000 ns;
	 while start_stimuli loop
	   ws_tst <= not(ws_tst);
		  wait for 5000 ns;
         end loop;
  end process;

main : process
   variable tmp, i : integer := 0;
   variable tmp_v : std_logic_vector(23 downto 0) := (others => '0');
begin
 test_runner_setup(runner, runner_cfg);
   while test_suite loop

	  if run("left_channel") then
	    start_stimuli <= true;
            wait for 100 ns;
            while i < 5 loop
            report " Result of  i = " & integer'image(i);
            wait for 1 ns;
            wait until ws_tst = '0';
            wait for 1 ns;
            l_data_tst <= l_data_tst xor tmp_v;
            while tmp < 1 loop
            wait for 1 ns;
            wait until rising_edge(bclk_tst);
            wait for 1 ns;
            check(sd_tst = l_data_tst(tmp), "Shifting data from left channel");
            wait for 1 ns;
            report " Result of tmp = " & integer'image(tmp);
            wait for 1 ns;
            tmp := tmp + 1;
            wait for 1 ns;
            end loop;
            wait for 1 ns;
            tmp := 0;
            wait for 1 ns;
            tmp_v := tmp_v(13 downto 0) & "1011011010";
            i := i + 1;
            wait for 10 ns;
            end loop;

          elsif run("right_channel") then
	    start_stimuli <= true;
            wait for 100 ns;
            wait for 1 ns;
            while i < 5 loop
            report " Result of i = " & integer'image(i);
            wait for 1 ns;
            r_data_tst <= r_data_tst xor tmp_v;
            while tmp < 1 loop
            wait for 1 ns;
            wait until ws_tst = '1';
            wait for 2 ns;
            wait until rising_edge(bclk_tst);
            wait for 2 ns;
            check(sd_tst = r_data_tst(tmp), "Shifting data from right channel");
            wait for 1 ns;
            report " Result of tmp = " & integer'image(tmp);
            wait for 1 ns;
            tmp := tmp + 1;
            wait for 1 ns;
            end loop;
            wait for 1 ns;
            tmp := 0;
            wait for 1 ns;
            tmp_v := tmp_v(17 downto 0) & "110110";
            wait for 1 ns;
            i := i + 1;
            wait for 10 ns;
            end loop;
          end if;
       end loop;

test_runner_cleanup(runner);
end process;
end architecture;
