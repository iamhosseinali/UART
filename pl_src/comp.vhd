library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity comp is
generic(
tDATA_Width : integer := 8
);
    Port ( 
            S_AXIS_tDATA    : in STD_LOGIC_VECTOR (tDATA_Width-1 downto 0);
            S_AXIS_tVALID   : in STD_LOGIC;
            M_AXIS_tDATA    : out STD_LOGIC_VECTOR (tDATA_Width-1 downto 0);
            M_AXIS_tVALID   : out STD_LOGIC;
            clk             : in STD_LOGIC
          );
end comp;

architecture Behavioral of comp is

begin
process(clk)
begin 
    if rising_edge(clk) then 
        if(S_AXIS_tVALID = '1') then 
            M_AXIS_tDATA  <= S_AXIS_tDATA; 
        end if; 
        M_AXIS_tVALID   <= S_AXIS_tVALID;
    end if; 
end process;   
end Behavioral;
