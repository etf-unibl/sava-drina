library ieee;
use ieee.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.ALL;

library vunit_lib;
context vunit_lib.vunit_context;

entity test_DFF is
  generic (runner_cfg : string := runner_cfg_default);
end entity;

architecture behavior of test_DFF is

 component D_FF
     port(clk_i, reset_i, D_i : in std_logic;
          Q_o : out std_logic
			 );
 end component;
 
 --Inputs
 signal clk_i_tst : std_logic := '0';
 signal reset_i_tst : std_logic := '0';
 signal D_i_tst : std_logic := '0';
 --Outputs
 signal Q_o_tst : std_logic;

signal start_stimuli, stimuli_done : boolean := false;
 
begin
  uut: D_FF 
    port map (
	 clk_i   => clk_i_tst,
	 reset_i => reset_i_tst,
	 D_i     => D_i_tst,
	 Q_o     => Q_o_tst);
	 	 


main :process
     begin
	  test_runner_setup(runner, runner_cfg);
	    while test_suite loop
		   if run("hold") then
			 start_stimuli <= true; 
			 wait until stimuli_done;
           		check((reset_i_tst='0'), "Checking"); 
			check_false((Q_o_tst = not D_i_tst), "Checking functionality");

		   elsif run("input") then
                          start_stimuli <= true; 
			 wait until stimuli_done;
			  check(reset_i_tst='0', "Checking");
			  check_false(Q_o_tst = D_i_tst);

	          elsif run("reset") then
                        start_stimuli <= true; 
			 wait until stimuli_done;
			  check(reset_i_tst='1', "Checking reset");
			  check_false(Q_o_tst = '0');
			end if;
		 end loop;
	  test_runner_cleanup(runner);
  end process;
  
 
 clk_proc : process
 begin
   clk_i_tst <= '0';
	wait for 10 ns;
   while start_stimuli loop
     wait for 10 ns;
     clk_i_tst <=not clk_i_tst;
   end loop;
 end process;
 
  stim_proc : process is
  begin

  wait until start_stimuli;
	 
	 if (not rising_edge(clk_i_tst) and running_test_case = "hold") then
	   info("Applaying stimuli");
        	  reset_i_tst  <='0';
		  D_i_tst <= '0'; 
		  
		elsif (rising_edge(clk_i_tst) and running_test_case = "input") then
		  reset_i_tst  <='0'; 
        	  D_i_tst <= '1';
		  
		elsif running_test_case = "reset" then
		  reset_i_tst <= '1';

		end if;
  stimuli_done <= true;	
  end process stim_proc;
end architecture;