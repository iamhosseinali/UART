library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity UART_Rx is
    generic
    (
        IP_INPUT_FREQUENCY  : integer  := 100000000;
        BaudRate            : integer  := 9600
    );
    Port ( 
				clk 		    : in  	STD_LOGIC;
				nRST			: in    std_logic ;
				AXI_m_tDATA		: out  	std_logic_vector 	(7 downto 0);
				AXI_m_tVALID	: out  	STD_LOGIC;
				Rx			 	: in  	STD_LOGIC);
end UART_Rx;

architecture Behavioral of UART_Rx is

	signal	Data_Out_Int			:	unsigned	(15 downto 0)				:=	(others=>'0');
	signal	Valid_Int				:	std_logic								:=	'0';
	signal	Rx_Int					:	std_logic								:=	'0';
	signal	Rx_Prev					:	std_logic								:=	'0';
	
	signal	Data_Bit_Count			:	unsigned	(3 downto 0)				:=	(others=>'0');
	signal	Parity_Bit				:	std_logic								:=	'0';
	signal	Packet_Detection		:	std_logic								:=	'0';
	signal	Find_Bit_Center_State   :	std_logic								:=	'0';
	
	constant	Baud_Rate			      :	integer				:=	(IP_INPUT_FREQUENCY/BaudRate);
	constant	Half_Baud_Rate            :	integer				:=	Baud_Rate/2;
	signal	    Bit_Width_Count		      :	unsigned	(15 downto 0)				:=	(others=>'0');
	
begin

	AXI_m_tDATA								<=		std_logic_vector(Data_Out_Int(7 downto 0));
	AXI_m_tVALID							    <=		Valid_Int;

	process(clk)
	begin
		if rising_edge(clk) then
			if(nRST='0') then 
				Bit_Width_Count			<= (others=>'0');
				Data_Bit_Count			<= (others=>'0');
				Find_Bit_Center_State	<= '0'; 
				Packet_Detection		<= '0'; 
			else 
			
				Rx_Int						<=		Rx;
				Rx_Prev						<=		Rx_Int;
				Valid_Int					<=		'0';
					
				Bit_Width_Count			    <=		Bit_Width_Count + 1;
				if (Bit_Width_Count = to_unsigned(Baud_Rate,16)) then
				
					Bit_Width_Count		<=		(others=>'0');
					Data_Bit_Count			<=		Data_Bit_Count + 1;
					Data_Out_Int(to_integer(Data_Bit_Count))<=	Rx_Int;
				
				end if;
				
				if (Data_Bit_Count = to_unsigned(8,4) and Packet_Detection = '1') then
					
					Valid_Int				<=		'1';
					Packet_Detection		<=		'0';
					
				end if;
							
				if (Rx_Int = '0' and Rx_Prev = '1' and Packet_Detection = '0') then
					
					Packet_Detection		<=		'1';
					Find_Bit_Center_State	<=		'1';
					Data_Bit_Count			<=		(others=>'0');						
					Bit_Width_Count			<=		(others=>'0');
					
				end if;
				
				if (Bit_Width_Count = to_unsigned(Half_Baud_Rate,16) and Find_Bit_Center_State = '1') then
				
					Find_Bit_Center_State	<=		'0';			
					Bit_Width_Count			<=		(others=>'0');						
					
				end if;
				
			end if;	
		end if; 
	end process;

end Behavioral;

