
----------------------------------------------------------------------------
-- LIBRARY DECLARATION.
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


LIBRARY vunit_lib;
context vunit_lib.vunit_context;


entity sub1_tb is
  generic (runner_cfg : string := runner_cfg_default);
end entity;


architecture tb of sub1_tb is

signal test1_in, test2_in, test_out : std_logic_vector(15 downto 0);
signal start_stimuli, stimuli_done : boolean := false;
signal ctrl_in : std_logic_vector(1 downto 0);
component sub1


	port (
     a_i    : in  std_logic_vector(15 downto 0);
     b_i    : in  std_logic_vector(15 downto 0);
     c_i    : in  std_logic_vector(1 downto 0);
     y_o    : out std_logic_vector(15 downto 0));

end component;


begin
	 ut: sub1
	   port map( 
		  a_i    => test1_in,
		  b_i    => test2_in,
		  c_i    => ctrl_in,
		  y_o    => test_out);

  test_runner : process
  begin
    test_runner_setup(runner, runner_cfg);
	 
      while test_suite loop
		
        if run("test_incrementation") then
          start_stimuli <= true; 
	  wait until stimuli_done;
	  check(ctrl_in="10", "Checking that incrementation is choosen");
	  info("Checking incrementation");
	  check(to_integer(unsigned(test_out))=to_integer(unsigned(test1_in) + 1), "Incrementation failed");
     
        elsif run("test_decrementation") then
          start_stimuli <= true; 
	  wait until stimuli_done;
	  check(ctrl_in="11", "Checking that decrementation is choosen");
	  info("Checking decrementation");
	  check(to_integer(unsigned(test_out))=to_integer(unsigned(test1_in) - 1), "Decrementation failed");

        elsif run("test_addition") then
          start_stimuli <= true; 
	  wait until stimuli_done;
	  check(ctrl_in="00", "Checking that addition is choosen");
	  info("Checking addition");
	  check(to_integer(unsigned(test_out))=to_integer(unsigned(test1_in) + unsigned(test2_in)), "Addition failed");
        elsif run("test_substraction") then
          start_stimuli <= true; 
	  wait until stimuli_done;
	  check(ctrl_in="01", "Checking that substraction is choosen");
	  info("Checking substraction");
	  check(to_integer(unsigned(test_out))=to_integer(unsigned(test1_in) - unsigned(test2_in)), "Addition failed");
        end if;

      end loop ;
	  
    test_runner_cleanup(runner);
  end process test_runner;
  
  
  
  stimuli_generator: process is
  begin
       	 wait until start_stimuli;
	 if running_test_case = "test_incrementation" then
	   info("Applaying stimuli");
	   ctrl_in <= "10";
	   test1_in <= "0000000000000001";
	   test2_in <= "0000000000000001";
	 elsif running_test_case = "test_decrementation" then
           info("Applaying stimuli");
	   ctrl_in <= "11";
	   test1_in <= "0000000000000001";
	   test2_in <= "0000000000000001";
	 elsif running_test_case = "test_substraction" then
           info("Applaying stimuli");
	   ctrl_in <= "01";
	   test1_in <= "0000000000000011";
	   test2_in <= "0000000000000001";

         elsif running_test_case <= "test_addition" then
           info("Applaying stimuli");
	   ctrl_in <= "00";
	   test1_in <= "0000000000000010";
	   test2_in <= "0000000000000001";
         end if;
         wait for 10ns;
	 stimuli_done <= true;
  
  end process stimuli_generator;
  
end architecture;
