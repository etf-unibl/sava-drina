--delayCounter
--after reset clears, waits for 40ms, then asserts a reset signal at the output
--input is the 50MHz clock from the clockBuffer
--40ms(50MHz) = 2x10^6 counts
--integer type can hold -(2^31-1) -> (2^31-1)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delayCounter is
		port(
			clock,reset: in std_logic;
			--active high reset
			resetAdc: out std_logic
		);
end delayCounter;

architecture arch of delayCounter is

	--count up to 2x10^6
	signal count: integer range 0 to 1999999;
	--active-high output signal
	signal output: std_logic;

begin

	process(clock,reset,output)
	begin
		--asynchronous active-high reset
		--stop counting after setting the output 
		if (reset = '0') then
			--synchronous count
			if rising_edge(clock) then
				if output = '0' then
					if count = 1999999 then --1999 for 40us
						count <= 0;
						--count has reached 2x10^6 (40ms), assert resetAdc
						output <= '1';			
					else
						count <= count + 1;
					end if;
				end if;
			end if;
		else
			--in reset
			count <= 0;
			--resetAdc is not asserted
			output <= '0';
		end if;
	end process;
	
	--assign output signal
	resetAdc <= output;
	
end arch;