--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|	xb_<port name>       	= off-chip bidirectional port ( _pads file )
--|	xi_<port name>       	= off-chip input port     	( _pads file )
--|	xo_<port name>       	= off-chip output port    	( _pads file )
--|	b_<port name>        	= on-chip bidirectional port
--|	i_<port name>        	= on-chip input port
--|	o_<port name>        	= on-chip output port
--|	c_<signal name>      	= combinatorial signal
--|	f_<signal name>      	= synchronous signal
--|	ff_<signal name>     	= pipeline stage (ff_, fff_, etc.)
--|	<signal name>_n      	= active low signal
--|	w_<signal name>      	= top level wiring signal
--|	g_<generic name>     	= generic
--|	k_<constant name>    	= constant
--|	v_<variable name>    	= variable
--|	sm_<state machine type>  = state machine type definition
--|	s_<signal name>      	= state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
	port(
    	-- inputs
    	clk 	:   in std_logic; -- native 100MHz FPGA clock
    	sw  	:   in std_logic_vector(15 downto 0);
    	btnU	:   in std_logic; -- master_reset
    	btnC	:   in std_logic; -- clk_reset
   	 
    	-- outputs
    	led :   out std_logic_vector(15 downto 0);
    	-- 7-segment display segments (active-low cathodes)
    	seg :   out std_logic_vector(6 downto 0);
    	-- 7-segment display active-low enables (anodes)
    	an  :   out std_logic_vector(3 downto 0)
	);
end top_basys3;

architecture top_basys3_arch of top_basys3 is
    -- declare components and signals
    component controller_fsm is
    	Port (
       	i_reset   : in  STD_LOGIC;
       	i_adv 	: in  STD_LOGIC;
       	o_cycle   : out STD_LOGIC_VECTOR (3 downto 0)      	 
     	);
	end component controller_fsm;

    component ALU is
    	Port (
       	i_A   	: in  STD_LOGIC_VECTOR (7 downto 0);
       	i_B   	: in  STD_LOGIC_VECTOR (7 downto 0);
       	i_op  	: in  STD_LOGIC_VECTOR (2 downto 0);
       	o_result  : out STD_LOGIC_VECTOR (7 downto 0);
       	o_flags   : out STD_LOGIC_VECTOR (2 downto 0)      	 
     	);
	end component ALU;
    
	component clock_divider is
    	generic ( constant k_DIV : natural := 2	); -- How many clk cycles until slow clock toggles
    	port (
        	i_clk	: in std_logic;
        	i_reset  : in std_logic;       	-- asynchronous
        	o_clk	: out std_logic       	-- divided (slow) clock
    	);
	end component clock_divider;
    
	component twoscomp_decimal is
    	port (
        	i_binary: in std_logic_vector(7 downto 0);
        	o_negative: out std_logic;
        	o_hundreds: out std_logic_vector(3 downto 0);
        	o_tens: out std_logic_vector(3 downto 0);
        	o_ones: out std_logic_vector(3 downto 0)
    	);
	end component twoscomp_decimal;
    
	component TDM4 is
	   generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
        Port ( i_clk        : in  STD_LOGIC;
               i_reset        : in  STD_LOGIC; -- asynchronous
               i_sign         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_hund         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_tens         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_ones         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_data        : out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_sel        : out STD_LOGIC_VECTOR (3 downto 0)    -- selected data line (one-cold)
        );
	end component TDM4;
	 
	component sevenSegDecoder is
     	port (
     	i_D : in std_logic_vector(3 downto 0); -- make into vectors
     	o_S : out std_logic_vector(6 downto 0)
     	);
 	end component sevenSegDecoder;    

	signal w_clk : std_logic;
	signal w_A: std_logic_vector (7 downto 0);
	signal w_B: std_logic_vector (7 downto 0);
	signal w_cycle: std_logic_vector (3 downto 0);
	signal w_result: std_logic_vector (7 downto 0);
    signal w_mux: std_logic_vector (7 downto 0);

	signal w_D3: std_logic;
	signal w_D2: std_logic_vector (3 downto 0);
	signal w_D1: std_logic_vector (3 downto 0);
	signal w_D0: std_logic_vector (3 downto 0);
	signal w_data: std_logic_vector (3 downto 0);
	signal w_sel: std_logic_vector (3 downto 0);
	
	signal w_regA : std_logic_vector(7 downto 0);
	signal w_regB : std_logic_vector(7 downto 0);
    
    
 
begin
    -- PORT MAPS ----------------------------------------
    controller_fsm_inst : controller_fsm
   	port map(
   	i_reset => btnU,
   	i_adv   => btnC,
   	o_cycle => w_cycle
   	);

	clkdiv_inst : clock_divider    	 --instantiation of clock_divider to take
   	generic map ( k_DIV => 50000000 ) -- 1 Hz clock from 100 MHz
   	port map(                     	 
   	i_clk   => clk,
   	i_reset => btnU, -- check if this should be btnU
   	o_clk   => w_clk
   	);    
    
	twoscomp_decimal_inst : twoscomp_decimal
    	port map (
    	i_binary => w_mux,
    	o_negative => w_D3,
    	o_hundreds => w_D2,
    	o_tens => w_D1,
    	o_ones => w_D0
    	);
   	 
    
	sevenSeg_inst : sevenSegDecoder
   	port map (
   	i_D => w_data,
   	o_S(0) => seg(0),
   	o_S(1) => seg(1),
   	o_S(2) => seg(2),
   	o_S(3) => seg(3),
   	o_S(4) => seg(4),
   	o_S(5) => seg(5),
   	o_S(6) => seg(6)
   	);    
  	 
	TDM_inst : TDM4
	generic map ( k_WIDTH => 4 )
   	port map(  	 
   	i_clk => w_clk,
   	i_reset => btnU,
   	i_sign(3) => w_D3,
   	i_sign(2) => '0',
   	i_sign(1) => w_D3,
   	i_sign(0) => '0',
   	i_hund => w_D2,
   	i_tens => w_D1,
   	i_ones => w_D0,
   	o_data => w_data,
   	o_sel => w_sel
   	);
  	 
	ALU_inst : ALU
   	port map(
   	i_A     	=> w_A,
   	i_B     	=> w_B,
   	i_op(0) 	=> sw(0),
   	i_op(1) 	=> sw(1),
   	i_op(2) 	=> sw(2),
   	o_result	=> w_result,
   	o_flags(0)  => led(13),
   	o_flags(1)  => led(14),
   	o_flags(2)  => led(15)
   	);
    -- CONCURRENT STATEMENTS ----------------------------
    
    w_A <= sw(7 downto 0) when (w_cycle = "0001");
	w_B <= sw(7 downto 0) when (w_cycle = "0010");
          	 
    w_mux  <= w_A when w_cycle = "0001" else
          	  w_B when w_cycle = "0010" else
          	  w_result when w_cycle = "0100" else
          	  "00000000";
         	 
	led(12 downto 4) <= (others => '0');
         	 

    
end top_basys3_arch;
