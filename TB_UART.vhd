
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity TB_UART is 
end TB_UART;

architecture behavior of TB_UART is

component UART 
port(
		clock: 		in std_logic;
		reset:		in std_logic;
		TX:			out std_logic;
		TXValue: 	out std_logic;
		RX:			in std_logic; 
		RXValue: 	in std_logic;
		LED:		out std_logic;
		TXLED:		out std_logic;
		RXLED:		out	std_logic;
		ncts:	 	in std_logic;
		nrts: 		out std_logic
	);
end component;
	constant 	clk_period 		: 	time := 1 ns;
	signal 		clk 			: 	std_logic :='0';
	signal		LEDT 			:	std_logic;
	signal		LEDR 			: 	std_logic;
	signal		LEDRunning		: 	std_logic;
	signal		T 	 			: 	std_logic;
	signal		R   			: 	std_logic;
	signal		RValue			:	std_logic;
	signal		TValue			:	std_logic;
	signal 		reset			:	std_logic:='1';
	signal		nrts1			:	std_logic;
	signal		ncts1			:	std_logic;



begin
	uut:UART 
	port map(
		clock 		=>clk,
		reset 		=>reset,
		TX 			=>T,
		TXValue		=>TValue,
		RX 			=>R,
		RXValue 	=>RValue,
		LED 		=>LEDRunning,
		TXLED 		=>LEDT,
		RXLED 		=>LEDR,
		ncts 		=>ncts1,
		nrts 		=>nrts1
		);


	process
	begin
		clk <= not clk after clk_period/2;
		if reset='1' then
			reset <= '0';			
		end if ;		
	end process ; -- Feeder




end behavior; -- behavior

