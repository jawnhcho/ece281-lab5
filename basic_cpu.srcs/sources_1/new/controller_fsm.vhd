----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 05/02/2024 10:10:37 AM
-- Design Name:
-- Module Name: controller_fsm - Behavioral
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

entity controller_fsm is
    Port (
  	 i_reset   : in  STD_LOGIC;
  	 i_adv     : in  STD_LOGIC;
  	 o_cycle   : out STD_LOGIC_VECTOR (3 downto 0); 
  	 i_clk : in std_logic		 
	 );
end controller_fsm;

architecture Behavioral of controller_fsm is
   	 signal f_Q: std_logic_vector(3 downto 0) := "0001";
   	 signal f_Q_next: std_logic_vector(3 downto 0) := "0001";
begin
   	 f_Q_next <= "0010" when (f_Q = "0001" and i_adv = '1') else
  	             "0100" when (f_Q = "0010" and i_adv = '1') else
  	             "1000" when (f_Q = "0100" and i_adv = '1') else
  	             "0001" when (f_Q = "1000" and i_adv = '1') else
  	             f_Q;
  	 o_cycle <= f_Q;
  	 
	register_proc : process (i_reset, i_clk)
           begin
                  if(rising_edge(i_clk)) then
                  if(i_reset = '1') then
                       f_Q <= "0001";
                      else
                          f_Q <= f_Q_next;
                  end if;
                  end if;
                      
       end process register_proc;    
end behavioral;
