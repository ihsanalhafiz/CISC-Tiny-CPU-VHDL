library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;
use work.micro_assembly_code.all;

entity microcode_fsm is
    port(
		uOP			: in std_logic_vector(3 downto 0);
		ZNO_flag	: in std_logic;
		uPC			: in std_logic_vector(1 downto 0);
		
        IE			: out std_logic;
		bypass_A	: out std_logic;
		bypass_B	: out std_logic;
		RW 			: out std_logic;
		write_out	: out std_logic;
		ReadA		: out std_logic;
		ReadB		: out std_logic;
		OE			: out std_logic;
        OP_out		: out std_logic_vector(2 downto 0);
		Flag 		: out std_logic_vector(1 downto 0);
		LE 			: out std_logic_vector(3 downto 0)
    );
end microcode_fsm;

architecture behave of microcode_fsm is
	Signal iADD:u_program :=(
	-- IE, 	bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- ADD 0000
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','1','1','1',opADD,'0',READ,ZERO,L_FLAG), -- FO
	('0','0','1','1','1','0',opINCR,'1',READ,ZERO,L_Addr), -- EX
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);
	
	Signal iSUB:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- SUB 0001
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','1','1','1',opSUB,'0',READ,ZERO,L_FLAG), -- FO
	('0','0','1','1','1','0',opINCR,'1',READ,ZERO,L_Addr), -- EX
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);
	
	Signal iAND:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- AND 0010
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','1','1','1',opAND,'0',READ,ZERO,L_FLAG), -- FO
	('0','0','1','1','1','0',opINCR,'1',READ,ZERO,L_Addr), -- EX
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);

	Signal iOR:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- OR 0011
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','1','1','1',opOR,'0',READ,ZERO,L_FLAG), -- FO
	('0','0','1','1','1','0',opINCR,'1',READ,ZERO,L_Addr), -- EX
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);		

	Signal iXOR:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- XOR 0100
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','1','1','1',opXOR,'0',READ,ZERO,L_FLAG), -- FO
	('0','0','1','1','1','0',opINCR,'1',READ,ZERO,L_Addr), -- EX
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);	
	
	Signal iNOT:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- NOR 0101
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','1','1','0',opNOT,'0',READ,ZERO,L_FLAG), -- FO
	('0','0','1','1','1','0',opINCR,'1',READ,ZERO,L_Addr), -- EX
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);
	
	Signal iMOV:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- MOV 0110
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','1','1','0',opMovA,'0',READ,ZERO,L_FLAG), -- FO
	('0','0','1','1','1','0',opINCR,'1',READ,ZERO,L_Addr), -- EX
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);
	
	Signal iNOP:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- NOP 0111
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None), -- FO
	('0','0','1','1','1','0',opINCR,'1',READ,ZERO,L_Addr), -- EX
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);	

	Signal iLD:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- LD 1000
	('0','0','0','0','0','0',opINCR,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','0','1','0',opMovA,'1',READ,ZERO,L_Addr), -- FO
	('0','0','1','1','1','0',opINCR,'1',READ,ZERO,L_Addr), -- EX
	('1','0','0','1','1','0',opMovA,'1',READ,ZERO,None) -- WA
	);	
	
	Signal iST:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- ST 1001
	('0','0','0','0','0','0',opMovA,'0',WRITE,ZERO,L_IR), -- LI
	('0','0','0','0','0','1',opADD,'1',READ,ZERO,L_DATA), -- FO
	('0','0','1','1','1','0',opINCR,'1',READ,ZERO,L_Addr), -- EX
	('0','0','0','0','1','0',opMovA,'1',READ,ZERO,L_Addr) -- WA
	);	
	
	Signal iLDI:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- LDI 1010
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('1','0','0','1','0','0',opMovA,'0',READ,ZERO,None), -- FO
	('0','0','1','1','1','0',opINCR,'1',READ,ZERO,L_Addr), -- EX
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);	
		
	Signal iBRZ_NO_Z:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- BRZ 1100 with Z = 0
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','0','0','0',opADD,'0',READ,ZERO, None), -- EX
	('0','0','1','1','1','0',opINCR,'1',READ,ZERO,L_Addr), -- FO
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);	

	Signal iBRZ_Z:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- BRZ 1100 with Z = 1
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','0','0','0',opADD,'0',READ,ZERO, None), -- EX
	('0','0','1','1','1','0',opADD,'1',READ,ZERO,L_Addr), -- FO
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);		
		
	Signal iBRN_NO_N:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- BRN 1101 with N = 0
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','0','0','0',opADD,'0',READ,ZERO, None), -- EX
	('0','0','1','1','1','0',opINCR,'1',READ,NEG,L_Addr), -- FO
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);	
	
	Signal iBRN_N:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- BRN 1101 with N = 1
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','0','0','0',opADD,'0',READ,ZERO, None), -- EX
	('0','0','1','1','1','0',opADD,'1',READ,NEG,L_Addr), -- FO
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);	
	
	Signal iBRO_NO_O:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- BRO 1110 with O = 0
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','0','0','0',opADD,'0',READ,ZERO, None), -- EX
	('0','0','1','1','1','0',opINCR,'1',READ,OVF,L_Addr), -- FO
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);	
	
	Signal iBRO_O:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- BRO 1110 with O = 1
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','0','0','0',opADD,'0',READ,ZERO, None), -- EX
	('0','0','1','1','1','0',opADD,'1',READ,OVF,L_Addr), -- FO
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);	
	
	Signal iBRA:u_program :=(
	-- IE, bypassA, bypassB ,WA_en,RA_en,RB_en, ALU, OE, RW, Flag, LE
	-- BRA 1111
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,L_IR), -- LI
	('0','0','0','0','0','0',opADD,'0',READ,ZERO, None), -- EX
	('0','0','1','1','1','0',opADD,'1',READ,ZERO,L_Addr), -- FO
	('0','0','0','0','0','0',opMovA,'0',READ,ZERO,None) -- WA
	);	
	
	signal run_u_program : u_program;
	signal run_u_instruction : u_instruction;
	signal fusionops_flag : std_logic_vector (4 downto 0);
	
begin

	run_u_instruction <= run_u_program(3-to_integer(unsigned(uPC)));
	
	OP_out 		<= run_u_instruction.ALU;
	RW			<= run_u_instruction.RW;
	IE 			<= run_u_instruction.IE;
	OE 			<= run_u_instruction.OE;
	ReadA 		<= run_u_instruction.RA_en;
	ReadB 		<= run_u_instruction.RB_en;
	write_out 	<= run_u_instruction.WA_en;
	bypass_A 	<= run_u_instruction.bypassA;
	bypass_B 	<= run_u_instruction.bypassB;
	Flag 		<= run_u_instruction.Flag;
	LE 			<= run_u_instruction.LE;
	
	fusionops_flag <= uOP & ZNO_flag;
		
	run_u_program <=	iADD when fusionops_flag(4 downto 1) = "0000" else
						iSUB when fusionops_flag(4 downto 1)  = "0001" else
						iAND when fusionops_flag(4 downto 1)  = "0010" else
						iOR  when fusionops_flag(4 downto 1)  = "0011" else
						iXOR when fusionops_flag(4 downto 1)  = "0100" else
						iNOT when fusionops_flag(4 downto 1)  = "0101" else
						iMOV when fusionops_flag(4 downto 1)  = "0110" else
						iNOP when fusionops_flag(4 downto 1)  = "0111" else
						iLD  when fusionops_flag(4 downto 1)  = "1000" else
						iST  when fusionops_flag(4 downto 1)  = "1001" else
						iLDI when fusionops_flag(4 downto 1)  = "1010" else
						iBRZ_NO_Z when fusionops_flag = "11000" else
						iBRZ_Z when fusionops_flag = "11001" else
						iBRN_NO_N when fusionops_flag = "11010" else
						iBRN_N when fusionops_flag = "11011" else
						iBRO_NO_O when fusionops_flag = "11100" else
						iBRO_O when fusionops_flag = "11101" else
						iBRA when fusionops_flag(4 downto 1)  = "1111" else iNOP;
end behave;