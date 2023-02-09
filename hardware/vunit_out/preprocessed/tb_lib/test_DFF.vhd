library ieee;
use ieee.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.ALL;


library vunit_lib;
context vunit_lib.vunit_context;

entity test_DFF is
    generic (runner_cfg : STRING := runner_cfg_default);
end entity;

architecture behavior OF test_DFF IS

component D_FF
  port (
       clk_i   : in std_logic;
       reset_i : in std_logic;
       D_i     : in std_logic;
       Q_o     : out std_logic);
  end component;


signal clk_i_tst     : std_logic := '0';
signal reset_i_tst   : std_logic := '0';
signal D_i_tst       : std_logic := '0';
signal Q_o_tst    : std_logic;
signal start_stimuli : boolean := false;

begin
  uut : D_FF
    port map(
      clk_i   => clk_i_tst,
      reset_i => reset_i_tst,
      D_i     => D_i_tst,
      Q_o     => Q_o_tst);
clk_proc : process
  begin
    clk_i_tst <= '0';
      wait for 10 ns;
        while start_stimuli loop
          wait for 10 ns;
            clk_i_tst <= not clk_i_tst;
        end loop;
end process;
main : process
  begin
    test_runner_setup(runner, runner_cfg);
      while test_suite loop
        if run("hold") then
          start_stimuli <= true;
          reset_i_tst   <= '0';
          D_i_tst       <= '0';
            wait until rising_edge(clk_i_tst);
              wait for 2 ns;
                D_i_tst <= '1';
                  wait for 2 ns;
                  check(D_i_tst = '1', line_num => 58, file_name => "test_DFF.vhd");
                  info("na ulazu je dovedena 1", line_num => 59, file_name => "test_DFF.vhd");
                  check(Q_o_tst = NOT D_i_tst, line_num => 60, file_name => "test_DFF.vhd");
                  info("Dok ne dodje do aktivne ivice CLK, DFF cuva prethodno stanje na izlazu", line_num => 61, file_name => "test_DFF.vhd");

        elsif run("input") then
          start_stimuli <= true;
          reset_i_tst   <= '0';
          D_i_tst       <= '0';
            wait until rising_edge(clk_i_tst);
              wait for 5 ns;
              check(Q_o_tst = D_i_tst, line_num => 69, file_name => "test_DFF.vhd");
              info("Nula je upisana na aktivnu ivicu", line_num => 70, file_name => "test_DFF.vhd");
              D_i_tst <= '1';
              wait until rising_edge(clk_i_tst);
              wait for 2 ns;
              check(Q_o_tst = D_i_tst, line_num => 74, file_name => "test_DFF.vhd");
              info("Upisana 1", line_num => 75, file_name => "test_DFF.vhd");

        elsif run("reset") then
          start_stimuli <= true;
          reset_i_tst   <= '0';
          D_i_tst       <= '1';
            wait until rising_edge(clk_i_tst);
              wait for 2 ns;
              check(Q_o_tst = '1', line_num => 83, file_name => "test_DFF.vhd");
              info("Izlaz je na 1, slijedi provjera reseta", line_num => 84, file_name => "test_DFF.vhd");
              reset_i_tst <= '1';
              wait for 2 ns;
              check(Q_o_tst = '0', line_num => 87, file_name => "test_DFF.vhd");
              info("Test za reset prolazi", line_num => 88, file_name => "test_DFF.vhd");
        end if;
end loop;
test_runner_cleanup(runner);
end process;

end architecture;
