----------------------------------------------------------------------------
-- LIBRARY DECLARATION.
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY vunit_lib;
context vunit_lib.vunit_context;


entity rx_line_tb is
  generic (runner_cfg : string := runner_cfg_default);
end entity;

architecture tb of rx_line_tb is
signal sd_tst        : std_logic_vector(15 downto 0);
signal sck_tst       : std_logic;
signal ws_tst        : std_logic;
signal wsd_tst_l     : std_logic_vector(15 downto 0);
signal wsd_tst_r     : std_logic_vector(15 downto 0);
signal start_stimuli : boolean := false;



component rx_line_tb 

  port(
                 sd        : in std_logic_vector(15 downto 0);
		 sck       : in std_logic;
		 ws        : in std_logic;
                 wsd_left  : out std_logic(15 downto 0)
		 wsd_right : out std_logic (15 downto 0));
		 
end component;

begin

  ut: rx_line_tb
    port map(
	          sd        => sd_tst;
		  sck       => sck_tst;
		  ws        => ws_tst;
		  wsd_left  => wsd_tst_l
		  wsd_right => wsd_tst_r);
				 
sck_proc : process

begin
  sck_tst <= '0';
  wait for 500ns;
    while start_stimuli loop
	   sck_tst <= not (sck_tst);
		  wait for 500ns;
	 end loop;
	 
end process;

rx_proc : process

begin

 test_runner_setup(runner, runner_cfg);
 
   while test_suite loop
	
	  if("left_channel") then
	    start_simuli => true;
            sd_tst <= "0000000000000000";
	    ws_tst <= '0';
		 
            wait until rising_edge(sck_tst);
            wait for 2 ns;
            info(" Provide data on left channel");
	    sd_tst <= "0000000000000111";
	    ws_tst <= '0';
            wait for 2 ns;
            check( ws_tst = '0')
	    check( wsd_test_l = sd_tst, " Error, data not present on left output buffer")
	    wait for 100 ns;
		  
          elsif ("right_channel") then
	    start_simuli => true;
            info(" Provide data on right channel");
	    sd_tst <= "0000000000011100";
            ws_tst <= '1';
            wait for 2ns;
            check(ws_tst = '1')
	    check(wsd_tst_r = sd_tst, " Error, data not present on right output buffer")
	    wait for 100 ns;
          end if;
       end loop;
	
test_runner_cleanup(runner);
end process;
end architecture;
