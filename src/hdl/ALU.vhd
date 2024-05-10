--+----------------------------------------------------------------------------
--| Documentations Statement: refered to this website https://nandland.com/shift-left-shift-right/
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>  		 = off-chip bidirectional port ( _pads file )
--|    xi_<port name>  		 = off-chip input port		 ( _pads file )
--|    xo_<port name>  		 = off-chip output port   	 ( _pads file )
--|    b_<port name>   		 = on-chip bidirectional port
--|    i_<port name>   		 = on-chip input port
--|    o_<port name>   		 = on-chip output port
--|    c_<signal name> 		 = combinatorial signal
--|    f_<signal name> 		 = synchronous signal
--|    ff_<signal name>		 = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n 		 = active low signal
--|    w_<signal name> 		 = top level wiring signal
--|    g_<generic name>		 = generic
--|    k_<constant name>   	 = constant
--|    v_<variable name>   	 = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name> 		 = state name
--|
--+----------------------------------------------------------------------------
--|
--| ALU OPCODES:
--|
--|     ADD     000
--|
--|
--|
--|
--+----------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
 
 
entity ALU is
    port(
   	 i_A : in std_logic_vector(7 downto 0);
   	 i_B : in std_logic_vector(7 downto 0);
   	 i_op: in std_logic_vector(2 downto 0);
   	 o_flags : out std_logic_vector(2 downto 0);
   	 o_result : out std_logic_vector(7 downto 0)
   	 );
end ALU;
 
architecture behavioral of ALU is
  signal w_sum : std_logic_vector(8 downto 0);
  signal w_diff : std_logic_vector(8 downto 0);
  signal w_and : std_logic_vector(7 downto 0);
  signal w_or : std_logic_vector(7 downto 0);
  signal w_left_shift : std_logic_vector(7 downto 0);
  signal w_right_shift : std_logic_vector(7 downto 0);
  signal w_result : std_logic_vector(7 downto 0);
 
  --signal w_A_unsigned : unsigned(7 downto 0);
  --signal w_B_unsigned : unsigned(7 downto 0);
  signal w_A_signed : signed(7 downto 0);
  signal w_B_signed : signed(7 downto 0);
  signal w_B_decimal : integer;
	-- declare components and signals   
 
 
begin
	-- PORT MAPS ----------------------------------------
 
    
	-- CONCURRENT STATEMENTS ----------------------------
    
	--w_A_unsigned <= unsigned(i_A);
	--w_B_unsigned <= unsigned(i_B);
	w_A_signed <= signed(i_A);
	w_B_signed <= signed(i_B);    
	w_B_decimal <= to_integer(w_B_signed);
    
	w_sum <= std_logic_vector(('0' & w_A_signed) + ('0' & w_B_signed));
	w_diff <= std_logic_vector(('0' & w_A_signed) - ('0' & w_B_signed));
	w_and <= (i_A and i_B);
	w_or <= (i_A or i_B);
	w_left_shift  <= std_logic_vector(shift_left(w_A_signed, w_B_decimal));
	w_right_shift <= std_logic_vector(shift_right(w_A_signed, to_integer(w_B_signed)));
    
	w_result <= (w_sum(7 downto 0)) when i_op = "000" else
            	(w_diff(7 downto 0)) when i_op = "011" else
            	(w_and) when i_op = "001" else
            	(w_or) when i_op = "010" else
            	(w_left_shift) when i_op = "100" else
            	(w_right_shift) when i_op = "110";
    
	o_flags(0) <= '1' when (i_A(7) = '1' and i_B(7) = '1') else '0';
	o_flags(1) <= '1' when (w_result = "00000000") else '0';
	o_flags(2) <= '1' when (w_result(7) = '1') else '0';
    
	o_result <= w_result;
    
	--process(i_A, i_B)
	--variable sum : std_logic_vector(8 downto 0);
	--variable diff : std_logic_vector(8 downto 0);
  	 --begin
  		 --sum := std_logic_vector(unsigned(i_A) + unsigned(i_B));
  		 --w_sum <= sum(7 downto 0);
  		 --o_flags(2) <= sum(8);
  		 --diff := std_logic_vector(unsigned(i_A) - unsigned(i_B));
  		 --w_diff <= diff(7 downto 0);
  		 --o_flags(1) <= diff(8);
 	--end process;
	--o_result <= w_sum when (i_op = "000") else
      		 --w_diff when (i_op = "011");
end behavioral;

