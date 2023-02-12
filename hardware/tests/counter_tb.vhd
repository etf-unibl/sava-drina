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

entity counter_tb is
  generic (runner_cfg : string := runner_cfg_default);
end entity;

architecture tb of counter_tb is
    signal clk_tst : std_logic := '0';
    signal reset_tst : std_logic := '0';
    signal enable_tst : std_logic := '0';
    signal count_tst : std_logic_vector(23 downto 0) := "000000000000000000000000";
    signal tmp : unsigned (23 downto 0);
begin
  invdut : entity design_lib.counter
    port map (clk => clk_tst,
              reset => reset_tst,
              enable => enable_tst,
              count => count_tst);

clk : process
  begin
    clk_tst <= '0';
    wait for 10 ns;
    clk_tst <= '1';
    wait for 10 ns;
  end process;

main : process
begin
 test_runner_setup(runner, runner_cfg);
   while test_suite loop
     tmp <= (others => '0');
           if run("test_counting") then
            enable_tst <= '1';
            reset_tst <= '1';
            wait for 2 ns;
            reset_tst <= '0';
            wait for 10 ns;
            while tmp < 30 loop
            wait until rising_edge(clk_tst);
            wait for 2 ns;
            tmp <= tmp + 1;
            wait for 2 ns;
            end loop;
            if(tmp > 24) then
              check(unsigned(count_tst) = tmp - 24);
            elsif(tmp < 24) then
              check(unsigned(count_tst) = 24 - tmp);
            elsif(tmp = 24) then
              check(unsigned(count_tst) = tmp);
            end if;

           elsif run("reset") then
            wait for 100 ns;
            reset_tst <= '1';
            wait for 2 ns;
            check(count_tst = "000000000000000000000000");
          end if;
         wait for 3 ns;
     end loop;
	
test_runner_cleanup(runner);
end process;
end architecture;
