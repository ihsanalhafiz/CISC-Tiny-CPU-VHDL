library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;
use work.micro_assembly_code.all;

entity cpu is
	generic ( N : integer := 16;
			  M : integer := 3 );
	port	( clk,reset:IN std_logic;
			  Din:IN std_logic_vector(N-1 downto 0);
			  address:OUT std_logic_vector(N-1 downto 0);
			  Dout:OUT std_logic_vector(N-1 downto 0);
			  rden, wren:OUT std_logic);
end cpu;

architecture behave of cpu is
	component datapath is
	generic (
		N : integer;										-- Register size
		M : integer										-- 2**M registers
	);
	port (
		clk			: in std_logic;							-- Clock
		rst			: in std_logic;							-- Reset
		IE			: in std_logic;							-- Input Enable. If '1' input from external pin, else from output SUM
		WAddr		: in std_logic_vector(M-1 downto 0);	-- Write address
		Write		: in std_logic;							-- Write enable
		Input_data	: in std_logic_vector(N-1 downto 0);	-- Data to be written
		RA			: in std_logic_vector(M-1 downto 0);	-- A read address
		RB			: in std_logic_vector(M-1 downto 0);	-- B read address
		ReadA  		: in std_logic; 						-- enable Read A
		ReadB  		: in std_logic; 						-- enable Read B
		OE			: in std_logic;							-- Output Enable, if '1' then output, else then 'Z'
		OP			: in std_logic_vector(2 downto 0);
		
		offset		: in std_logic_vector(N-1 downto 0);
		bypassA		: in std_logic;
		bypassB 	: in std_logic;
		
		
		Output_data	: out std_logic_vector(N-1 downto 0);	-- Output data
		Z_Flag		: out std_logic;						-- Zero flag
		N_Flag		: out std_logic;						-- Negative flag
		O_Flag		: out std_logic						-- Overflow flag
	);
	end component;
	
	component microcode_fsm is
    port(
		uOP		: in std_logic_vector(3 downto 0);
		ZNO_flag: in std_logic;
		uPC		: in std_logic_vector(1 downto 0);
	
        IE		: out std_logic;
		bypass_A: out std_logic;
		bypass_B: out std_logic;
		RW		: out std_logic;
		write_out	: out std_logic;
		ReadA	: out std_logic;
		ReadB	: out std_logic;
		OE		: out std_logic;
        OP_out	: out std_logic_vector(2 downto 0);
		Flag 	: out std_logic_vector(1 downto 0);
		LE 		: out std_logic_vector(3 downto 0)
    );
	end component;

	signal uPC : std_logic_vector(1 downto 0) := "00";
	signal instruction_reg : std_logic_vector(N-1 downto 0);
	
	signal Data_out : std_logic_vector(N-1 downto 0);
	
	signal IE_buf,OE_buf,Write_buf,ReadA_buf,ReadB_buf : std_logic;
	signal bypassA_buf, bypassB_buf : std_logic;
	signal OP_buf : std_logic_vector(2 downto 0);
	signal LE : std_logic_vector(3 downto 0);
	
	signal Z_Flag_buf, N_Flag_buf, O_Flag_buf : std_logic := '0';
	signal ZNO_flag_buf : std_logic := '0';
	signal flag_buf : std_logic_vector(1 downto 0);
	signal offset_buf : std_logic_vector(N-1 downto 0);
	signal input_sign : std_logic_vector(8 downto 0);
	signal sign_ext	: std_logic_vector(6 downto 0);
	signal input_sign_extended : std_logic_vector(N-1 downto 0);
	signal WAddr_buf : std_logic_vector(M-1 downto 0);
	
	signal RW : std_logic;
	
	--define register flag
	signal Z_Flag_reg, N_Flag_reg, O_Flag_reg : std_logic := '0';
begin

	uPC_process : process(clk, reset)
	begin
		if(reset = '1') then
			uPC <= (others=> '0');
		elsif rising_edge(clk) then
			uPC <= std_logic_vector(unsigned(uPC)+1);
		end if;
	end process uPC_process;
	
	LE_process : process(clk, reset)
	begin
		if(reset = '1') then
			address <= (others => '0');
			--ZNO_flag_buf <= '0';
		elsif rising_edge(clk) then
			case LE is
			when L_IR => 
				instruction_reg <= Din;
			when L_Addr => 
				address <= Data_out;
			when L_DATA => 
				Dout <= Data_out;
			when L_FLAG => 
				Z_Flag_reg <= Z_Flag_buf;
				N_Flag_reg <= N_Flag_buf;
				O_Flag_reg <= O_Flag_buf;
			when others => null;
			end case;
			
			--Z_Flag_reg <= Z_Flag_buf;
			--N_Flag_reg <= N_Flag_buf;
			--O_Flag_reg <= O_Flag_buf;
		end if;
	end process LE_process;
	
	--ZNO_flag_buf <= Z_Flag_buf or N_Flag_buf or O_Flag_buf;
	offset_buf <= std_logic_vector(resize(signed(instruction_reg(11 downto 0)), offset_buf'length));
	
	--input_sign <= Din(8 downto 0);
	--sign_ext <= (others=>'0') when (input_sign(8)='0') else (others=>'1');
	--input_sign_extended <= sign_ext&input_sign;
	
	with instruction_reg(15 downto 12) select input_sign_extended <=
		Din when "1000",
		std_logic_vector(resize(signed(instruction_reg(8 downto 0)), N)) when "1010",
		(others => '0') when others;
	
	datapath_port : datapath
	generic map (
		N => N,										-- Register size
		M => M										-- 2**M registers
	)
	port map(
		clk 		=> clk,							-- Clock
		rst			=> reset,						-- Reset
		IE			=> IE_buf,						-- Input Enable. If '1' input from external pin, else from output SUM
		WAddr		=> instruction_reg(11 downto 9),-- Write address
		Write		=> Write_buf,					-- Write enable
		Input_data	=> input_sign_extended,			-- Data to be written
		RA			=> instruction_reg(8 downto 6),	-- A read address
		RB			=> instruction_reg(5 downto 3),	-- B read address
		ReadA  		=> ReadA_buf,					-- enable Read A
		ReadB  		=> ReadB_buf,					-- enable Read B
		OE			=> OE_buf,						-- Output Enable, if '1' then output, else then 'Z'
		OP			=> OP_buf,
		
		offset		=> offset_buf,
		bypassA		=> bypassA_buf,
		bypassB 	=> bypassB_buf,
		
		Output_data	=> Data_out,						-- Output data
		Z_Flag		=> Z_Flag_buf,						-- Zero flag
		N_Flag		=> N_Flag_buf,						-- Negative flag
		O_Flag		=> O_Flag_buf						-- Overflow flag
	);
	
	ZNO_flag_buf <=
		Z_Flag_reg when flag_buf="00" else
		N_Flag_reg when flag_buf="01" else
		O_Flag_reg when flag_buf="10" else 'X';
	
	microcode_fsm_port : microcode_fsm
	port map(
		uOP			=> instruction_reg(15 downto 12),
		ZNO_flag	=> ZNO_flag_buf,
		uPC			=> uPC,
	 
        IE			=> IE_buf,
		bypass_A	=> bypassA_buf,
		bypass_B	=> bypassB_buf,
		RW 			=> RW,
		write_out	=> Write_buf,
		ReadA		=> ReadA_buf,
		ReadB		=> ReadB_buf,
		OE			=> OE_buf,
        OP_out		=> OP_buf,
		Flag 		=> flag_buf,
		LE 			=> LE
    );
    
   rden<=RW;
   wren<=not(RW);
	
end behave;
