----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 02/20/2024 09:50:37 AM
-- Design Name:
-- Module Name: sevenSegDecoder - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
--
entity sevenSegDecoder is
	Port ( i_D : in STD_LOGIC_VECTOR (3 downto 0);
       	o_S : out std_logic_vector (6 downto 0));
end sevenSegDecoder;

architecture Behavioral of sevenSegDecoder is
	signal c_Sa, c_Sb, c_Sc, c_Sd, c_Se, c_Sf, c_Sg : std_logic;
	begin
	o_S(0) <= c_Sa;
	o_S(1) <= c_Sb;
	o_S(2) <= c_Sc;
	o_S(3) <= c_Sd;
	o_S(4) <= c_Se;
	o_S(5) <= c_Sf;
	o_S(6) <= c_Sg;    

	c_Sa <= '1' when ((i_D = x"1") or
                  	(i_D = x"A") or
                  	(i_D = x"4")) else '0';
    	 
	c_Sb <= '1' when ((i_D = x"5") or
                  	(i_D = x"A") or
                  	(i_D = x"6") ) else '0';
    	 
	c_Sc <= '1' when ((i_D = x"2") or
                  	(i_D = x"A"))else '0';
                  	 
	c_Sd <= '1' when ( (i_D = x"1") or
                   	(i_D = x"A") or
                   	(i_D = x"4") or
                   	(i_D = x"7") or
                   	(i_D = x"9") ) else '0';
                                     	 
	c_Se <= '1' when ( (i_D = x"1") or
                   	(i_D = x"A") or
                   	(i_D = x"3") or
                   	(i_D = x"4") or
                   	(i_D = x"5") or   
                   	(i_D = x"7") or
                   	(i_D = x"9") ) else '0';   
                    	 
	c_Sf <= '1' when ( (i_D = x"1") or
                   	(i_D = x"A") or
                   	(i_D = x"2") or
                   	(i_D = x"3") or
                   	(i_D = x"7")) else '0';    
                  	 
	c_Sg <= '1' when ( (i_D = x"0") or
                   	(i_D = x"1") or
                   	(i_D = x"7")) else '0';


end Behavioral;

