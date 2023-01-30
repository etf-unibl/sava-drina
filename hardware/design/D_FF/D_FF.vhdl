library ieee;
use ieee.STD_LOGIC_1164.all;

entity D_FF is
  port( 
       clk_i, reset_i,D_i: in std_logic;
       Q_o: out std_logic
		 );
end D_FF;
architecture beh of D_FF is
begin
  process(clk_i,reset_i)
  begin
    if(reset_i='1')then
       Q_o <='0';
    elsif(rising_edge(clk_i))then
       Q_o <= D_i;
    end if;
  end process;
end beh;