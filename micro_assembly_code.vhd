library ieee;
use ieee.std_logic_1164.all;
use work.all;

package micro_assembly_code is
	subtype instruction_code is std_logic_vector(3 downto 0);
	subtype opcode is std_logic_vector(2 downto 0);
	subtype immediate is std_logic_vector(8 downto 0);
	subtype flag is std_logic_vector(1 downto 0);
	subtype latching is std_logic_vector(3 downto 0);
	subtype reg_code is std_logic_vector(2 downto 0);
	subtype Instruction is std_logic_vector(15 downto 0);	
	
	type u_instruction is record
		IE:std_logic;
		bypassA:std_logic;
		bypassB:std_logic;
		WA_en:std_logic;
		RA_en:std_logic;
		RB_en:std_logic;
		ALU:opcode;
		OE:std_logic;
		RW:std_logic;
		Flag:std_logic_vector(1 downto 0);
		LE:std_logic_vector(3 downto 0);
		end record;
	
	Type u_program is array (3 downto 0) of u_instruction;
	
	-- Operations for ALU
	constant opADD : opcode := "000";
	constant opSUB : opcode := "001";
	constant opAND : opcode := "010";
	constant opOR  : opcode := "011";
	constant opXOR : opcode := "100";
	constant opNOT : opcode := "101";
	constant opMovA : opcode := "110";
	constant opINCR : opcode := "111";
	
	-- INSTRUCTION SET
    constant ADD:instruction_code := "0000";
    constant iSUB:instruction_code := "0001";
    constant iAND:instruction_code := "0010";
    constant iOR:instruction_code := "0011";
    constant iXOR:instruction_code := "0100";
    constant iNOT:instruction_code := "0101";
    constant MOV:instruction_code := "0110";
    constant NOP:instruction_code := "0111";
    constant LD:instruction_code := "1000";
    constant ST:instruction_code := "1001";
    constant LDI:instruction_code := "1010";
    constant NOT_USED:instruction_code := "1011";
    constant BRZ:instruction_code := "1100";
    constant BRN:instruction_code := "1101";
    constant BRO:instruction_code := "1110";
    constant BRA:instruction_code := "1111";
	
	-- LE
	constant NONE : latching := "0000";
	constant L_IR : latching := "0001";
	constant L_Addr : latching := "0010";
	constant L_DATA : latching := "0100";
	constant L_FLAG : latching := "1000";			
	
	constant READ : std_logic := '1';
	constant WRITE : std_logic := '0';
	
	-- flag
	constant ZERO : flag := "00";
	constant NEG : flag := "01";
	constant OVF : flag := "10";
	
	-- register macros
    constant Rx:reg_code :="000";
    constant R0:reg_code :="000";
    constant R1:reg_code :="001";
    constant R2:reg_code :="010";
    constant R3:reg_code :="011";
    constant R4:reg_code :="100";
    constant R5:reg_code :="101";
    constant R6:reg_code :="110";
    constant R7:reg_code :="111";
	
	constant Tail3:reg_code :="000";
	
end micro_assembly_code;
