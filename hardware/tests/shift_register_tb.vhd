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

entity shift_register_tb is
  generic (runner_cfg : string := runner_cfg_default);
end entity;

architecture tb of shift_register_tb is
    signal clk_tst : std_logic := '0';
    signal reset_tst: std_logic;
    signal enable_tst : std_logic;
    signal data_in_tst : std_logic;
    signal data_out_tst : std_logic_vector (23 downto 0);
    signal tmp : unsigned (23 downto 0);
begin
  invdut : entity design_lib.shift_register
    port map (clk => clk_tst,
              reset => reset_tst,
              enable => enable_tst,
              data_in => data_in_tst,
              data_out => data_out_tst);

clk : process
  begin
    clk_tst <= '0';
    wait for 10 ns;
    clk_tst <= '1';
    wait for 10 ns;
  end process;
data : process
  begin
    data_in_tst <= '0';
    wait for 7 ns;
    data_in_tst <= '1';
    wait for 7 ns;
  end process;

main : process
begin
 test_runner_setup(runner, runner_cfg);
   while test_suite loop
     tmp <= (others => '0');
           if run("test_counting") then
            reset_tst <= '1';
            wait for 20 ns;
            reset_tst <= '0';
            enable_tst <= '1';
            wait for 2 ns;
            while tmp < 50 loop
            wait until rising_edge(clk_tst);
            wait for 2 ns;
            tmp <= tmp + 1;
            wait for 2 ns;
            end loop;
          end if;
         wait for 3 ns;
     end loop;
	
test_runner_cleanup(runner);
end process;
end architecture;
