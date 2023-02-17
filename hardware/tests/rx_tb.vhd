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

entity rx_tb is
  generic (runner_cfg : string := runner_cfg_default);
end entity;

architecture tb of rx_tb is
signal sd_tst        : std_logic;
signal clk_tst       : std_logic;
signal bclk_tst      : std_logic;
signal ws_tst        : std_logic;
signal wsd_tst_l     : std_logic_vector(23 downto 0) := (others => '0');
signal wsd_tst_r     : std_logic_vector(23 downto 0) := (others => '0');
signal start_stimuli : boolean := false;
signal count_o_tst   : std_logic_vector(23 downto 0) := (others => '0');
signal tmp : integer := 0;
signal tmp_v : std_logic_vector (23 downto 0) := (others => '0');

begin
  invdut : entity design_lib.rx
    port map(
	          sd_i      => sd_tst,
                  clk_i     => clk_tst,
		  bclk_i    => bclk_tst,
		  ws_i      => ws_tst,
                  count_o   => count_o_tst,
		  data_l_o  => wsd_tst_l,
		  data_r_o  => wsd_tst_r);
clk : process
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

sd: process
  begin
    sd_tst <= '0';
    wait for 7 ns;
	 while start_stimuli loop
	   sd_tst <= not(sd_tst);
		  wait for 7 ns;
        end loop;
  end process;

ws: process
  begin
    ws_tst <= '1';
    wait for 500 ns;
	 while start_stimuli loop
	   ws_tst <= not(ws_tst);
		  wait for 500 ns;
         end loop;
  end process;

main : process
begin
 test_runner_setup(runner, runner_cfg);
 
   while test_suite loop
	
	  if run("left_channel") then
	    start_stimuli <= true;
            wait for 1100 ns;
            if (tmp < 6) then
            wait until ws_tst = '0';
            info("Provide data on left channel");
	    check( wsd_tst_l /= "000000000000000000000000", " Data present on left output buffer");
            tmp <= tmp + 1;
            wait for 500 ns;
            end if;
		  
          elsif run("right_channel") then
	    start_stimuli <= true;
            info(" Provide data on right channel");
            wait for 1700 ns;
            if (tmp < 6) then
            --wait until ws_tst = '1';
            wait until ws_tst = '1';
	    check( wsd_tst_r /= "000000000000000000000000", "Data present on right output buffer");
	    wait for 500 ns;
            tmp <= tmp + 1;
            end if;
          end if;
       end loop;
	
test_runner_cleanup(runner);
end process;
end architecture;
