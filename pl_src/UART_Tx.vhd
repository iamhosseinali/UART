----------------------------------------------------------------------------------
-- Company: IDK
-- Engineer: Hosseinali
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Tx is
generic 
(
        IP_INPUT_FREQUENCY  : integer  := 100000000;
        BaudRate            : integer  := 9600
--        include_Parity      : boolean  := false
);
    Port ( 	 
					Tx 		        : out  	STD_LOGIC;
					M_AXIS_tREADY 	: out  	STD_LOGIC;				
					M_AXIS_tVALID 	: in  	STD_LOGIC;
					M_AXIS_tDATA	: in  	std_logic_vector(7 downto 0);					
					clock  	        : in  	STD_LOGIC
					
			 );
end UART_Tx;

architecture Behavioral of UART_Tx is

	--- registering output signals --- 
	
	signal 	Tx_int	    : std_logic := '0';
	signal	busy_int	: std_logic := '0';
	
	
	
	---reistrering input signals ----

	signal 	send_int		: std_logic := '0';
	signal	data_in_int		: unsigned (7 downto 0) := (others => '0');

	
	
	----internal signals ---
	
	signal 	send_int_prev		: std_logic 	:= '0'; 
	signal 	parity				: std_logic 	:= '0'; 
	signal 	creating_parity	    : std_logic 	:= '0'; 
	signal 	creating_packet	    : std_logic 	:= '0'; 
	signal 	start_sending		: std_logic 	:= '0'; 
	signal 	packet				: unsigned	(10 downto 0) 	:= (others	=> '0'); 
	signal	clock_counter		: unsigned 	(31 downto 0) 	:= (others 	=> '0');
	signal	bit_width_counter	: unsigned 	(3 downto 0) 	:= (others 	=> '0');
	constant   Baud_Rate		:	integer				:=	(IP_INPUT_FREQUENCY/BaudRate);

	

begin

	Tx 	            <= Tx_int;
	M_AXIS_tREADY	<= not busy_int;
	
		process(clock)
		begin 		
			if rising_edge (clock) then
				
				data_in_int			<= unsigned(M_AXIS_tDATA);
				send_int 			<= M_AXIS_tVALID;
--				send_int_prev		<= send_int;
				clock_counter 		<= clock_counter +1;
				Tx_int				<= '1';
				creating_packet	    <= '0';
				
				if  (clock_counter = Baud_Rate ) then 
					
					clock_counter 			<= (others => '0');
					bit_width_counter		<= bit_width_counter +1;
				
				end if; 
				
				
				if (M_AXIS_tVALID = '1' and busy_int ='0') then 
				
					busy_int 			<= '1';
--				    if(include_Parity = true) then 	
--					   parity 				<= data_in_int(0) xor data_in_int(1) xor data_in_int(2) xor data_in_int(3)
--												xor data_in_int(4) xor data_in_int(5) xor data_in_int(6) xor data_in_int(0);
--				    end if; 
					creating_packet	<= '1';
					
				end if ;
				
				
				if (creating_packet = '1') then 
					
					packet 					<= '1' & '1' & data_in_int & '0' ; 
					start_sending			<= '1';
					bit_width_counter		<= (others=> '0');
					clock_counter 			<= (others=> '0');

				
				end if ;
				
				
				if (start_sending = '1') then 
				
					Tx_int		<= packet(to_integer(bit_width_counter));
					
				end if;
				
				
				if (bit_width_counter = to_unsigned (10,4)) then 
				
					bit_width_counter 		<= (others => '0');
					busy_int 					<= '0';
					start_sending 				<= '0';
					
				end if ;
					
			end if;
		end process;
end Behavioral;

