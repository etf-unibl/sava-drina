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
    signal clk_tst      : std_logic;
    signal reset_tst    : std_logic;
    signal enable_tst   : std_logic;
    signal data_in_tst  : std_logic_vector (23 downto 0) := "101010101010101010101010";
    signal data_out_tst : std_logic;
    signal tmp_v        : std_logic_vector (23 downto 0) := (others => '0');

begin
  invdut : entity design_lib.shift_register
    port map (clk_i      => clk_tst,
              reset_i    => reset_tst,
              enable_i   => enable_tst,
              data_i     => data_in_tst,
              data_o     => data_out_tst);

clk : process
  begin
    clk_tst <= '0';
    wait for 10 ns;
    clk_tst <= '1';
    wait for 10 ns;
  end process;

main : process
 variable idx, tmp : integer  := 0;
begin
 test_runner_setup(runner, runner_cfg);
   while test_suite loop
     tmp_v <= (others => '0');
           if run("test_output") then
            reset_tst <= '1';
            wait for 2 ns;
            check(data_out_tst = '0', "Reset testing", line_num => 53, file_name => "shift_register_tb.vhd");
            wait for 2 ns;
            reset_tst <= '0';
            enable_tst <= '1';
            wait for 2 ns;
            while idx < 5 loop
            data_in_tst <= data_in_tst xor tmp_v;
            wait for 2 ns;
            while tmp < data_in_tst'length - 1 loop
            wait until rising_edge(clk_tst);
            wait for 1 ns;
            check(data_out_tst = data_in_tst(tmp), "Data shifting check", line_num => 64, file_name => "shift_register_tb.vhd");
            tmp := tmp + 1;
            end loop;
            wait for 20 ns;
            tmp := 0;
            wait for 2 ns;
            idx := idx + 1;
            tmp_v <= tmp_v(18 downto 0) & "11010";
            wait for 2 ns;
            end loop;

            elsif run ("hold_state") then
            reset_tst <= '1';
            wait for 2 ns;
            check(data_out_tst = '0', "Reset testing", line_num => 78, file_name => "shift_register_tb.vhd");
            wait for 2 ns;
            reset_tst <= '0';
            enable_tst <= '0';
            wait for 2 ns;
            data_in_tst <= "101010101010101010101010";
            tmp := 0;
            wait for 2 ns;
            while tmp < 23 loop
            wait until rising_edge(clk_tst);
            wait for 2 ns;
            check(data_out_tst = '0', "Data is not shifting to output", line_num => 89, file_name => "shift_register_tb.vhd");
            tmp := tmp + 1;
            wait for 2 ns;
            end loop;
            wait for 100 ns;
          end if;
         wait for 3 ns;
     end loop;
	
test_runner_cleanup(runner);
end process;
end architecture;
