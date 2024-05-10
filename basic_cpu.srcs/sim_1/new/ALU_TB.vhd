----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 05/06/2024 01:09:41 AM
-- Design Name:
-- Module Name: ALU_TB - Behavioral
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

entity ALU_TB is
--  Port ( );
end ALU_TB;

architecture test_bench of ALU_TB is
component ALU is
    port(
   	 i_A : in std_logic_vector(7 downto 0);
   	 i_B : in std_logic_vector(7 downto 0);
   	 i_op: in std_logic_vector(2 downto 0);
   	 o_flags : out std_logic_vector(2 downto 0);
   	 o_result : out std_logic_vector(7 downto 0)
   	 );
end component ALU;

	signal w_clk : std_logic := '0';
	signal w_A : std_logic_vector(7 downto 0) := "00000000";
	signal w_B : std_logic_vector(7 downto 0) := "00000000";
	signal w_op : std_logic_vector(2 downto 0) := "000";
	signal w_flags : std_logic_vector(2 downto 0) := "000";
  	signal w_result : std_logic_vector(7 downto 0) := "00000000";
    
    constant k_clk_period : time := 10 ns;
  	 
   begin
   	-- PORT MAPS ----------------------------------------
  	uut: ALU port map (
  	i_A => w_A,
  	i_B => w_B,
  	i_op => w_op,
  	o_flags => w_flags,
  	o_result => w_result
  	);    
   	-----------------------------------------------------
  	 
   	-- PROCESSES ----------------------------------------    
   	-- Clock process ------------------------------------
   	clk_proc : process
   	begin
       	w_clk <= '0';
       	wait for k_clk_period/2;
       	w_clk <= '1';
       	wait for k_clk_period/2;
   	end process;    
   	-----------------------------------------------------
  	 
   	-- Test Plan Process --------------------------------
   
   	sim_proc: process
   	begin
       	-- sequential timing   	 

    	-- adder zero
         	w_op <= "000"; w_A <= "00000000"; w_B <="00000000"; wait for k_clk_period;
         	wait for 10 ns;
             	assert w_flags = "010" and  w_result = "00000000" report "ADDER ZERO" severity failure;
            wait for 10 ns;
    	   -- adder cout
                         w_op <= "000"; w_A <= "10000000"; w_B <="10000000"; wait for k_clk_period;
                             assert w_flags = "011" and w_result = "00000000" report "Adder COUT" severity failure;
                             wait for k_clk_period/2;
                    -- adder regular
                         w_op <= "000"; w_A <= "00000001"; w_B <="00000001"; wait for k_clk_period;
                             assert w_flags = "000" and w_result = "00000010" report "ADDER REG." severity failure;
                            wait for k_clk_period/2;
                            
                    -- subtract zero
                         w_op <= "011"; w_A <= "00000001"; w_B <="00000001"; wait for k_clk_period;
                              assert w_flags = "010" and w_result = "00000000" report "SUBTRACT ZERO" severity failure;
                            wait for k_clk_period/2;
                    -- subtract cout and sign
                         w_op <= "011"; w_A <= "00000000"; w_B <="00000001"; wait for k_clk_period;
                              assert w_flags = "100" and w_result = "11111111" report "SUB. COUT AND SIGN" severity failure;
                            wait for k_clk_period/2;
                    -- subtract regular
                         w_op <= "011"; w_A <= "00000010"; w_B <="00000001"; wait for k_clk_period;
                              assert w_flags = "000" and w_result = "00000001" report "SUBTRACT REG" severity failure;
                             wait for k_clk_period/2;
                             
                    -- AND regular
                         w_op <= "001"; w_A <= "01010001"; w_B <="11111111"; wait for k_clk_period;
                              assert w_flags = "000" and w_result = "01010001" report "AND REG" severity failure;
                            wait for k_clk_period/2;
                    -- AND zero
                         w_op <= "001"; w_A <= "01000000"; w_B <="00101111"; wait for k_clk_period;
                              assert w_flags = "010" and w_result = "00000000" report "AND ZERO" severity failure;
                            wait for k_clk_period/2;
                    -- AND regular check back later
                         w_op <= "001"; w_A <= "00000010"; w_B <="00000001"; wait for k_clk_period;
                              assert w_flags = "010" and w_result = "00000000" report "AND REG" severity failure;
                            wait for k_clk_period/2;
                            
                    -- OR Regular
                         w_op <= "010"; w_A <= "01010001"; w_B <="00101010"; wait for k_clk_period;
                              assert w_flags = "000" and w_result = "01111011" report "OR REG" severity failure;
                            wait for k_clk_period/2;
                    -- OR Zero
                         w_op <= "010"; w_A <= "00000000"; w_B <="00000000"; wait for k_clk_period;
                              assert w_flags = "010" and w_result = "00000000" report "OR ZERO" severity failure;
                            wait for k_clk_period/2;
                            
                    -- LeftShift regular
                         w_op <= "100"; w_A <= "10101010"; w_B <="00000001"; wait for k_clk_period;
                              assert w_flags = "000" and w_result = "01010100" report "LEFT" severity failure;                            
                            wait for k_clk_period/2;
                    -- RightShift regular
                        w_op <= "110"; w_A <= "10101010"; w_B <="00000001"; wait for k_clk_period;
                             assert w_flags = "100" and w_result = "11010101" report "RIGHT" severity failure;
                             wait for k_clk_period/2;

end process;

end test_bench;

