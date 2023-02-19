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

entity buffer_r_l_tb is
  generic (runner_cfg : string := runner_cfg_default);
end entity;

architecture tb of buffer_r_l_tb is
    signal write_enable_tst : std_logic := '0';
    signal clk_tst          : std_logic;
    signal data_in_tst : std_logic_vector (23 downto 0) := (others => '0');
    signal data_out_tst : std_logic_vector (23 downto 0) := (others => '0');
    signal start_stimuli : boolean := false;
    signal tmp : integer := 0;
    signal tmp_v : std_logic_vector (23 downto 0) := (others => '0');
begin
  invdut : entity design_lib.buffer_r_l
    port map (write_enable => write_enable_tst,
              data_in      => data_in_tst,
              data_out     => data_out_tst,
              clk_i        => clk_tst);
clk: process
  begin
    clk_tst<= '1';
    wait for 10 ns;
	 while start_stimuli loop
	   clk_tst<= not(clk_tst);
		  wait for 10 ns;
         end loop;
  end process;

write_enable: process
  begin
    write_enable_tst <= '1';
    wait for 20 ns;
	 while start_stimuli loop
	   write_enable_tst <= not(write_enable_tst);
		  wait for 300 ns;
         end loop;
  end process;

main : process
begin
 test_runner_setup(runner, runner_cfg);
   while test_suite loop
     tmp <= 0;
     while tmp < 10 loop
           if run("enabled_output") then
            start_stimuli <= true;
            data_in_tst <= "000000110111010111010011";
            wait for 3 ns;
            data_in_tst <= data_in_tst xor tmp_v;
            wait for 10 ns;
            wait until rising_edge(clk_tst);
            wait for 3 ns;
            wait until write_enable_tst = '1';
            wait for 5 ns;
            check(data_out_tst = data_in_tst, "Test passed!");
            wait for 10 ns;
          end if;
         tmp <= tmp + 1;
         tmp_v <= tmp_v(21 downto 0) & "10";
         wait for 3 ns;
       end loop;
     end loop;
	
test_runner_cleanup(runner);
end process;
end architecture;
