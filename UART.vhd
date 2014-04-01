library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity UART is 
port ( 	clock: 		in std_logic;
		reset:		in std_logic;
		TX:			out std_logic;
		TXValue: 	out std_logic;
		RX:			in std_logic; 
		RXValue: 	in std_logic;
		LED:		out std_logic;
		TXLED:		out std_logic;
		RXLED:		out	std_logic
		);
end UART;
architecture v of UART is
component sc_uart
	generic (addr_bits : integer;
			 clk_freq : integer;
			 baud_rate : integer;
			 txf_depth : integer; txf_thres : integer;
			 rxf_depth : integer; rxf_thres : integer);
	port (
		clk		: in std_logic;
		reset	: in std_logic;
		address		: in std_logic_vector(addr_bits-1 downto 0);
		wr_data		: in std_logic_vector(31 downto 0);
		rd, wr		: in std_logic;
		rd_data		: out std_logic_vector(31 downto 0);
		rdy_cnt		: out unsigned(1 downto 0);

		txd		: out std_logic;
		rxd		: in std_logic;
		ncts	: in std_logic;
		nrts	: out std_logic
		);
end component;
		--stuff for the finite state machine
		signal		state  		: 	std_logic_vector(2 downto 0)	:="101";
		signal 		counter 	:	unsigned(31 downto 0)			:=to_unsigned(0,32);
		signal 		counter2 	:	integer							:=0;

		constant 	waiting 	: 	std_logic_vector(2 downto 0)	:="000";
		constant 	readWait 	: 	std_logic_vector(2 downto 0)	:="001";
		constant 	writeWait 	: 	std_logic_vector(2 downto 0)	:="010";
		constant 	readingMode	: 	std_logic_vector(2 downto 0)	:="011";
		constant 	writingMode	: 	std_logic_vector(2 downto 0)	:="100";
		constant 	resetMode	: 	std_logic_vector(2 downto 0)	:="101";


		--stuff to get the data out from sc
		signal		TXDataUART	:	std_logic_vector(31 downto 0)	:=std_logic_vector(to_unsigned(0,32));
		signal		RXDataUART	:	std_logic_vector(31 downto 0)	;
		signal		rdUART		:	std_logic 						;
		signal		wrUART		:	std_logic 						:='0';
		signal		rdyCntUART	:	unsigned(1 downto 0)			;
		signal		txdUART		:	std_logic 						;
		signal		rxdUART		:	std_logic 						;
		signal		nctsUART	:	std_logic 						;
		signal		nrtsUART	:	std_logic 						;
		signal		resetUART	:	std_logic   					:='0';

begin


	serial:sc_uart 
	generic map (
		addr_bits => 2,
		clk_freq => 50000000,
		baud_rate => 115200,
		txf_depth => 8,
		txf_thres => 8,
		rxf_depth => 8, 
		rxf_thres => 8
		)
	port map (
		clk			=> 	clock,
		reset		=> 	resetUART,
		address		=>	"01",
		wr_data		=>	TXDataUART,
		rd          =>	rdUART, 
		wr          =>	wrUART, 
		rd_data		=>	RXDataUART,
		rdy_cnt		=> 	rdyCntUART,

		txd			=> 	TXValue,
		rxd			=> 	RXValue,
		ncts		=> 	'0',
		nrts		=>	nrtsUART
		);

	process(clock)
	begin
		if rising_edge(clock) then
			
		

			case( state ) is
		
				when waiting =>
					LED <='1';
					TXLED <='0';
					RXLED <='0';
					wrUART <='1';
					TX   <='1';
					resetUART   <='0';

					if reset = '1' then
						counter2 <=0;
						state <= resetMode;
					end if ;
					counter2 <=counter2+1;
					if counter2>14000 then
						counter2 <=0;
						state <=writingMode;	
					end if;			
					if to_integer(counter)>10 then
						counter <=to_unsigned(0,32);
					end if ;

				when writingMode =>
					

					
					TXDataUART	<= std_logic_vector(counter+48);

					counter		<=counter+1;
					state 		<=waiting;

				when resetMode =>
					wrUART 	    <='0';
					resetUART   <='1';
					counter 	<= to_unsigned(0,32);
					counter2 	<=counter2 +1;
					if counter2 >5 then
						state 	<=waiting;
						counter2<=0;
					else
						state 	<=resetMode;

					end if ;
					
				when others =>
					state <= resetMode;
		
			end case ;
		
		end if ;	



	
	end process;




end v; -- behavior