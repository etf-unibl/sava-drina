library ieee;
use ieee.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.ALL;


library vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.run_pkg.all;
use vunit_lib.check_pkg.all;

library common_lib;

entity D_FF_tb is
    generic (runner_cfg : STRING := runner_cfg_default);
end entity;

architecture beh of D_FF_tb is
    
signal clk_i_tst     : std_logic := '0';
signal reset_i_tst   : std_logic := '0';
signal D_i_tst       : std_logic := '0';
signal Q_o_tst    : std_logic;
signal start_stimuli : boolean := false;

begin
  invdut : entity common_lib.D_FF
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
                  check(D_i_tst = '1');
                  info("na ulazu je dovedena 1");
                  wait for 2 ns;
                  check(Q_o_tst = NOT D_i_tst);
                  info("Dok ne dodje do aktivne ivice CLK, DFF cuva prethodno stanje na izlazu");
                  wait for 200 ns;

        elsif run("input") then
          start_stimuli <= true;
          reset_i_tst   <= '0';
          D_i_tst       <= '0';
            wait until rising_edge(clk_i_tst);
              wait for 5 ns;
              check(Q_o_tst = D_i_tst);
              info("Nula je upisana na aktivnu ivicu");
              D_i_tst <= '1';
              wait until rising_edge(clk_i_tst);
              wait for 2 ns;
              check(Q_o_tst = D_i_tst);
              info("Upisana 1");
              wait for 200 ns;

        elsif run("reset") then
          start_stimuli <= true;
          reset_i_tst   <= '0';
          D_i_tst       <= '1';
            wait until rising_edge(clk_i_tst);
              wait for 2 ns;
              check(Q_o_tst = '1');
              info("Izlaz je na 1, slijedi provjera reseta");
              wait for 2 ns;
              reset_i_tst <= '1';
              wait for 2 ns;
              check(Q_o_tst = '0');
              info("Test za reset prolazi");
              wait for 200 ns;
        end if;
end loop;
test_runner_cleanup(runner);
end process;

end architecture;
