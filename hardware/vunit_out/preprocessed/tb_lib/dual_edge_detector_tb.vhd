library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use vunit_lib.run_pkg.all;
use vunit_lib.check_pkg.all;

library design_lib;

entity dual_edge_detector_tb is
  generic (runner_cfg : string);
end entity;

architecture arch of dual_edge_detector_tb is

-- signals
signal p_test      : std_logic;
signal p_comp      : std_logic;
signal clk_test    : std_logic;
signal rst_test    : std_logic;
signal strobe_test : std_logic;
signal tmp         : integer := 0;

type t_mealy_test_vector is record
  strobe_v : std_logic;
  p_v      : std_logic;
end record t_mealy_test_vector;

type t_mealy_test_vector_array is array (natural range <>) of t_mealy_test_vector;

constant c_MEALY_TEST_VECTORS : t_mealy_test_vector_array := (('0', '0'),
                                                              ('1', '1'),
                                                              ('1', '0'),
                                                              ('1', '0'),
                                                              ('1', '0'),
                                                              ('0', '1'),
                                                              ('0', '0'));

begin
  invdut : entity design_lib.dual_edge_detector
    port map(
      clk_i     =>  clk_test,
      rst_i     =>  rst_test,
      strobe_i  =>  strobe_test,
      p_o       =>  p_test
    );

clk : process
begin
    clk_test <= '0';
    wait for 10 ns;
    clk_test <= '1';
    wait for 10 ns;
    --if indeks = c_MEALY_TEST_VECTORS'length then
      --wait;
    --end if;
end process;

reset : process
begin
    rst_test <= '1';
    wait for 10 ns;
    rst_test <= '0';
    --wait;
end process;

main : process

variable indeks : integer := 0;
begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      if run("detect_edge") then
      Info("Starting first test for dual edge detector - detecting edge");
        wait for 50 ns;
        report "The value of length is " & integer'image(c_MEALY_TEST_VECTORS'length);
        if indeks < c_MEALY_TEST_VECTORS'length then
          report "The value of indeks is " & integer'image(indeks);
          strobe_test <= c_MEALY_TEST_VECTORS(indeks).strobe_v;
          wait for 1 ns;
          p_comp <= c_MEALY_TEST_VECTORS(indeks).p_v;
          wait for 2 ns;
	  Info("Starting first test for dual edge detector - detecting edge");
          wait until clk_test'event;
          wait for 3 ns;
          check(p_test = p_comp, "Test completed", line_num => 90, file_name => "dual_edge_detector_tb.vhd");
          wait for 2 ns;
          indeks := indeks + 1;
          wait for 2 ns;
        end if;
      wait for 100 ns;
    end if;
    end loop;

  test_runner_cleanup(runner);
end process;
end arch;