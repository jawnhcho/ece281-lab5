--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(15 downto 0);
        btnU    :   in std_logic; -- master_reset
        btnC    :   in std_logic; -- clk_reset
        
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
           i_adv     : in  STD_LOGIC;
           o_cycle   : out STD_LOGIC_VECTOR (3 downto 0)           
         );
    end component controller_fsm;

    component regA is
        port (
            i_A    : in STD_LOGIC_VECTOR (7 downto 0);
            i_cycle: in STD_LOGIC_VECTOR (3 downto 0);
            o_A    : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component regA;

    component regB is
        port (
            i_B    : in STD_LOGIC_VECTOR (7 downto 0);
            i_cycle: in STD_LOGIC_VECTOR (3 downto 0);
            o_B    : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component regB;
    
	component ALU is
        Port ( 
           i_A       : in  STD_LOGIC_VECTOR (7 downto 0);
           i_B       : in  STD_LOGIC_VECTOR (7 downto 0);
           i_op      : in  STD_LOGIC_VECTOR (3 downto 0);
           o_result  : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags   : out STD_LOGIC_VECTOR (2 downto 0)           
         );
    end component ALU;
    
    component clock_divider is
        generic ( constant k_DIV : natural := 2    ); -- How many clk cycles until slow clock toggles
        port (
            i_clk    : in std_logic;
            i_reset  : in std_logic;           -- asynchronous
            o_clk    : out std_logic           -- divided (slow) clock
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
        Port ( i_clk        : in  STD_LOGIC;
               i_reset      : in  STD_LOGIC; -- asynchronous
               i_sign       : in  STD_LOGIC_VECTOR (3 downto 0);
               i_hund       : in  STD_LOGIC_VECTOR (3 downto 0);
               i_tens       : in  STD_LOGIC_VECTOR (3 downto 0);
               i_ones       : in  STD_LOGIC_VECTOR (3 downto 0);
               o_data       : out STD_LOGIC_VECTOR (3 downto 0);
               o_sel        : out STD_LOGIC_VECTOR (3 downto 0)    -- selected data line (one-cold)
        );
    end component TDM4;
     
    component sevenSegDecoder is
         port (
         i_D : in std_logic_vector(3 downto 0); -- make into vectors
         o_S : out std_logic_vector(6 downto 0)
         );
     end component sevenSegDecoder;    
    --type sm_floor is (s_floor1, s_floor2, s_floor3, s_floor4);
    signal w_clk : std_logic;
    signal w_A: std_logic_vector (7 downto 0);
    signal w_B: std_logic_vector (7 downto 0); 
    signal w_data: std_logic_vector (3 downto 0);
    signal w_cycle: std_logic_vector (3 downto 0);
    
  
begin
	-- PORT MAPS ----------------------------------------
	controller_fsm_inst : controller_fsm
	   port map(
	   i_reset => btnU,
	   i_adv   => btnC,
	   o_cycle => w_cycle
	   );
	
	regA_inst : regA
       port map(
       i_A(0) => sw(0),
       i_A(1) => sw(1),
       i_A(2) => sw(2),
       i_A(3) => sw(3),
       i_A(4) => sw(4),
       i_A(5) => sw(5),
       i_A(6) => sw(6),
       i_A(7) => sw(7),
       o_A(0) => w_A(0),
       o_A(1) => w_A(1),
       o_A(2) => w_A(2),
       o_A(3) => w_A(3),
       o_A(4) => w_A(4),
       o_A(5) => w_A(5),
       o_A(6) => w_A(6),
       o_A(7) => w_A(7),
       i_cycle => w_cycle
       );
       
    regB_inst : regB
       port map(
       i_B(0) => sw(0),
       i_B(1) => sw(1),
       i_B(2) => sw(2),
       i_B(3) => sw(3),
       i_B(4) => sw(4),
       i_B(5) => sw(5),
       i_B(6) => sw(6),
       i_B(7) => sw(7),
       o_B(0) => w_B(0),
       o_B(1) => w_B(1),
       o_B(2) => w_B(2),
       o_B(3) => w_B(3),
       o_B(4) => w_B(4),
       o_B(5) => w_B(5),
       o_B(6) => w_B(6),
       o_B(7) => w_B(7),
       i_cycle => w_cycle   
       );
       
    clkdiv_inst : clock_divider 		--instantiation of clock_divider to take 
       generic map ( k_DIV => 50000000 ) -- 1 Hz clock from 100 MHz
       port map(                          
       i_clk   => clk,
       i_reset => btnU, -- check if this should be btnU
       o_clk   => w_clk
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
       port map(       
       i_clk => w_clk,
       --i_reset => btnU, do we use this?
       i_sign => w_D3,
       i_hund => w_D2,
       i_tens => w_D1,
       i_ones => w_D0,
       o_data => w_data,
       o_sel => w_sel
       
	-- CONCURRENT STATEMENTS ----------------------------
	
	
	
end top_basys3_arch;
