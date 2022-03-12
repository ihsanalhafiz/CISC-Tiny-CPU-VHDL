-- ======================================
-- | Lab 2 : Datapath |
-- ======================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity datapath is
	generic (
		N : integer ;										-- Register size
		M : integer											-- 2**M registers
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
		bypassB		: in std_logic;
		
		Output_data	: out std_logic_vector(N-1 downto 0);	-- Output data
		Z_Flag		: out std_logic;						-- Zero flag
		N_Flag		: out std_logic;						-- Negative flag
		O_Flag		: out std_logic						-- Overflow flag
	);
end entity datapath;

architecture RTL of datapath is

  component ALU is
	generic (N: integer);
	port (
		OP		: in std_logic_vector(2 downto 0);		-- Operation selector
		A 		: in std_logic_vector(N-1 downto 0);	-- First operand
		B		: in std_logic_vector(N-1 downto 0);	-- Second operand

		Z_Flag	: out std_logic;						-- Zero flag
		O_Flag	: out std_logic;						-- Overflow flag
		N_Flag	: out std_logic;						-- Sign flag
		
		Sum		: out std_logic_vector(N-1 downto 0)		-- Result
	);
	end component;
  
  component register_file is
	generic (
		N : integer;	-- Register size
		M : integer		-- 2**M registers
	);
	port (
		clk		: in  std_logic;						-- Clock
		rst		: in  std_logic;						-- Reset
		
		Write	: in  std_logic;						-- Write enable
		WD		: in  std_logic_vector(N-1 downto 0);	-- Data to be written
		WAddr	: in  std_logic_vector(M-1 downto 0);	-- Write address
		
		RA		: in  std_logic_vector(M-1 downto 0);	-- A read address
		RB		: in  std_logic_vector(M-1 downto 0);	-- B read address
		ReadA  	: in  std_logic; 						-- enable Read A
		ReadB  	: in  std_logic; 						-- enable Read B
		QA		: out std_logic_vector(N-1 downto 0);	-- A datum read
		QB		: out std_logic_vector(N-1 downto 0)	-- B datum read
	);
  end component;
  
  	-- include register component
	component register_ent generic(N:integer);
	port(	D	: in std_logic_vector(N-1 downto 0);
            clk	: in std_logic;
			rst	: in std_logic;
            Q	: out std_logic_vector(N-1 downto 0)
			);
	end component;

signal input_reg 	: std_logic_vector(N-1 downto 0);		-- input for register from mux input
signal outputA_reg 	: std_logic_vector(N-1 downto 0);
signal outputB_reg	: std_logic_vector(N-1 downto 0);
signal output_alu	: std_logic_vector(N-1 downto 0);
signal buf_output_alu	: std_logic_vector(N-1 downto 0);
signal bufout		: std_logic_vector(N-1 downto 0);
signal clk_1s		: std_logic;

signal ReadA_buf, ReadB_buf, Write_buf : std_logic;
signal RA_buf, RB_buf, WAddr_buf : std_logic_vector(M-1 downto 0);

signal A,B 			: std_logic_vector(N-1 downto 0);

begin

	REG : register_file
		generic map(N => N,
					M => M)
		port map(	clk   	=> clk,
					rst   	=> rst,
					Write	=> Write_buf,
					WD		=> input_reg,
					WAddr	=> WAddr_buf,
					RA   	=> RA_buf,
					RB    	=> RB,
					ReadA 	=> ReadA,
					ReadB 	=> ReadB,
					QA   	=> outputA_reg,
					QB 		=> outputB_reg);	
				 
	ALUPort	: ALU
		generic map(N => N)
		port map(	OP		=> OP,
					A 		=> outputA_reg,
					B		=> B,
					Z_Flag	=> Z_Flag,
					O_Flag	=> O_Flag,
					N_Flag	=> N_Flag,
					Sum		=> output_alu);

	
	input_reg <= Input_data when (IE='1') else output_alu;
	Output_data <= output_alu when (OE = '1') else (others=> 'Z');
	
	--A <= offset when (bypassA='1') else outputA_reg;
	B <= offset when (bypassB='1') else outputB_reg;
	
	ReadA_buf <= '1' when (bypassB = '1') else ReadA;
	RA_buf <= (others=>'1') when (bypassB = '1') else RA;

	--ReadB_buf <= '1' when (bypassB = '1') else ReadB;
	--RB_buf <= (others=>'1') when (bypassB = '1') else RB;
	
	Write_buf <= '1' when (bypassB = '1') else Write;
	WAddr_buf <= (others=>'1') when (bypassB = '1') else WAddr;
	
end architecture RTL;
