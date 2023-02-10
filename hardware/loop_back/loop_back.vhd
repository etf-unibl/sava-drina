LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity loop_back is
	port(
		KEY: in std_logic_vector(0 downto 0);
		CLOCK_50: in std_logic;
		--I2C ports
		I2C_SCLK: out std_logic;
		I2C_SDAT: inout std_logic;
		--audio codec ports
		AUD_ADCDAT: in std_logic;
		AUD_ADCLRCK: out std_logic;
		AUD_DACLRCK: out std_logic;
		AUD_DACDAT: out std_logic;
		AUD_XCK: out std_logic;
		AUD_BCLK: out std_logic;
		--output for logic analyzer
		GPIO_0: inout std_logic_vector (7 downto 0);
		LEDR: out std_logic_vector (0 downto 0)
	);
end loop_back;

architecture arch of loop_back is

	--PLL component from MegaWizard
	--both input and output are 50MHz
	component clockBuffer IS
		PORT
		(
			refclk	 : IN STD_LOGIC  := '0';
			rst		 : IN STD_LOGIC  := '0';
			outclk_0	 : OUT STD_LOGIC 
		);
	END component;
	
	--18.42105 MHz MCLK
	component audioPLLClock IS
		PORT
		(
			--active high reset
			refclk	 : IN STD_LOGIC  := '0';
			rst		 : IN STD_LOGIC  := '0';
			outclk_0	 : OUT STD_LOGIC 
		);
	END component;
	
	--I2C controller to drive the Wolfson codec
	component audioCodecController is
	port(
		clock50MHz,reset: in std_logic;
		I2C_SCLK_Internal: out std_logic;
		--must be inout to allow FPGA to read the ack bit
		I2C_SDAT_Internal: out std_logic;
		SDAT_Control: out std_logic;
		--for testing
		clock50KHz_Out: out std_logic
	);
	end component;
	
	--waits 40ms, then asserts high output
	component delayCounter is
		port(
			clock,reset: in std_logic;
			--active high reset
			resetAdc: out std_logic
		);
	end component;
	
	--generates digital audio interface clock signals
	--starts after delayCounter asserts (40ms)
	component AdcDacController is
		port(
			--reset signal starts '0', then goes to '1' after 40 ms => active-low
			resetn: in std_logic;
			--from 50MHz PLL at toplevel
			clock18MHz_in: in std_logic;
			--line-in on the DE1
			adcData: in std_logic;
			--line-out on the DE1
			dacData: out std_logic;
			bitClock: out std_logic;
			dacLRSelect: out std_logic;
			adcLRSelect: out std_logic
		);
	end component;
	
	--clock signal from the PLL clockBuffers
	signal clock50MHz: std_logic;
	
	--18MHz PLL output signal
	signal clock18MHz: std_logic;
	
	--asynchronous reset for the whole project
	signal reset: std_logic;
 
	--I2C data and clock lines
	signal i2cData, i2cClock: std_logic;
	
	--tri-state buffer control
	signal i2cDataControl: std_logic;
	signal i2cDataTriState: std_logic;
	
	--assert signal from delay counter
	signal codecResetn: std_logic;
	
	--audio codec signals
	signal adcDat_sig: std_logic;
	signal adcLRCK_sig: std_logic;
	signal dacLRCK_sig: std_logic;
	signal dacDat_sig: std_logic;
	signal bck_sig: std_logic;
	
	--for testing
	signal clock50KHz: std_logic;
	
begin

	--keys are active low
	reset <= not KEY(0);
	
	--PLLs
	clockBufferInstance: clockBuffer port map(CLOCK_50,reset,clock50MHz);
	audioPLLClockMap: audioPLLClock port map(CLOCK_50, reset, clock18MHz);
	
	--I2C
	I2CControllerInstance: audioCodecController port map(clock50MHz, reset, i2cClock, i2cData,
		i2cDataControl, clock50KHz);
		
	--Delay counter
	delayCounterMap: delayCounter port map(clock50MHz, reset, codecResetn);
	
	--Codec Controller
	AdcDacControllerMap: AdcDacController port map(codecResetn, clock18MHz, adcDat_sig, dacDat_sig,
		bck_sig, dacLRCK_sig, adcLRCK_sig);
	
	--tri-state data output
	i2cDataTriState <= i2cData when i2cDataControl = '1' else 'Z';
	
	--I2C output ports
	I2C_SCLK <= i2cClock;
	I2C_SDAT <= i2cDataTriState;
	
	--audio codec input port
	adcDat_sig <= AUD_ADCDAT;
	
	--audio codec ouput ports
	AUD_ADCLRCK <= adcLRCK_sig;
	AUD_DACLRCK <= dacLRCK_sig;
	AUD_DACDAT <= dacDat_sig;
	AUD_XCK <= clock18MHz;
	AUD_BCLK <= bck_sig;
	
	GPIO_0(0) <= adcDat_sig;
	GPIO_0(1) <= adcLRCK_sig;
	GPIO_0(2) <= dacLRCK_sig;
	GPIO_0(3) <= dacDat_sig;
	GPIO_0(6) <= clock18MHz;
	GPIO_0(7) <= bck_sig;
	
	GPIO_0(4) <= reset;
	GPIO_0(5) <= codecResetn;
	
	LEDR(0) <= reset;

end arch;