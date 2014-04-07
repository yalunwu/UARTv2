library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity UARTv2 is 
port ( 	clock: 		in std_logic;
		reset:		in std_logic;
		TXValue: 	out std_logic;
		RXValue: 	in std_logic;
		LEDRX:		out std_logic:='1';
		LED:		out std_logic:='1'
		);
end UARTv2;
architecture v of UARTv2 is
component sc_uart
	generic (addr_bits : integer;
			 clk_freq : integer;
			 baud_rate : integer;
			 txf_depth : integer; txf_thres : integer;
			 rxf_depth : integer; rxf_thres : integer);
	port (
		clk		: in std_logic;
		reset	: in std_logic:='0';
		address		: in std_logic_vector(addr_bits-1 downto 0);
		wr_data		: in std_logic_vector(31 downto 0);
		rd, wr		: in std_logic;
		rd_data		: out std_logic_vector(31 downto 0);
		rdy_cnt		: out unsigned(1 downto 0);

		txd		: out std_logic;
		rxd		: in std_logic;
		ncts	: in std_logic;
		nrts	: out std_logic;
		TXCLK 	: out std_logic;
		RXCLK 	: out std_logic
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
		
		constant	ONER		:	std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(49,32));
		constant	TWOER		:	std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(50,32));

		--stuff to get the data out from sc
		signal		TXDataUART	:	std_logic_vector(31 downto 0)	:=std_logic_vector(to_unsigned(0,32));
		signal		RXDataUART	:	std_logic_vector(31 downto 0)	;
		signal		rdUART		:	std_logic 						;
		signal		wrUART		:	std_logic 						:='0';
		signal		rdyCntUART	:	unsigned(1 downto 0)			;
		signal		nctsUART	:	std_logic 						;
		signal		nrtsUART	:	std_logic 						;
		signal		resetUART	:	std_logic   					:='0';
		signal 		txCLK:	std_logic;
		signal 		rxCLK:	std_logic;
		signal 		addUART: 	std_logic_vector(1 downto 0) :="00";
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
		address		=>	addUART,
		wr_data		=>	TXDataUART,
		rd          =>	'1', 
		wr          =>	'0', 
		rd_data		=>	RXDataUART,
		rdy_cnt		=> 	rdyCntUART,

		txd			=> 	TXValue,
		rxd			=> 	RXValue,
		ncts		=> 	'1',
		nrts		=>	nrtsUART,
		TXCLK  		=> 	txCLK,
		RXCLK		=> 	rxCLK
		);

	process(clock)
	begin
	if rising_edge(clock) then
		case( state ) is
		
			when waiting =>
				resetUART<='0';
				addUART <="00";
				if RXDataUART(1) = '1' then
					addUART <="01";
					state <=readWait;
				end if ;

			when readWait => 
				if rdyCntUART < 1 then
					state <=readingMode;
				end if;
			when readingMode => 
				state <=waiting;
				if RXDataUART = ONER then
					LED <='0';
				elsif RXDataUART = TWOER then
					LED <='1';	
				end if ;
				
			when resetMode => 
				resetUART <='1';
				if counter2<10 then
					state <=resetMode;
					counter2 <= counter2+1;
				else
					state <=waiting;
					counter2 <=0;
				end if ;


		
			when others =>

				state <=resetMode;
		
		end case ;
	end if;

	end process;




end v; -- behavior