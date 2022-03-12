-- =======================
-- | Lab 1 Task 2 |
-- =======================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use ieee.std_logic_unsigned.all;

entity ALU is
	generic (N: integer);
	port (
		OP	: in  std_logic_vector(2 downto 0);		-- Operation selector
		A 	: in  std_logic_vector(N-1 downto 0);	-- First operand
		B	: in  std_logic_vector(N-1 downto 0);	-- Second operand
		
		Z_Flag	: out std_logic;						-- Zero flag
		O_Flag	: out std_logic;						-- Overflow flag
		N_Flag	: out std_logic;						-- Sign flag
		
		Sum	: out std_logic_vector(N-1 downto 0)	-- Result
	);
end entity ALU;

architecture behavioural of ALU is
  
	-- =======================
	-- | signals assignments |
	-- =======================
		
	signal sub_cov	: std_logic_vector(N-1 downto 0); -- subtraction convertion for ripple carry adder
	signal B_sub	: std_logic_vector(N-1 downto 0); -- B value for subtraction
	signal y_i		: std_logic_vector(N-1 downto 0);	-- Global result buffer
	signal ofc_add	: std_logic_vector(2 downto 0);	-- overflow calculation for addition buffer
	signal ofc_sub	: std_logic_vector(2 downto 0);	-- overflow calculation for subtraction buffer
	signal Cin_add : std_logic:='0'; -- Carry In for addition
	signal Cin_sub : std_logic:='1'; -- Carry In for subtraction
	signal Cout_add: std_logic; -- Carry Out for addition
	signal Cout_sub: std_logic; -- Carry Out for subtraction
	signal ofo_add: std_logic; -- overflow buffer for addition
	signal ofo_sub: std_logic; -- overflow buffer for subtraction

	signal ofc_incr			: std_logic_vector(2 downto 0);	-- overflow calculation for incrementer - lab3
	signal ofo_incr: std_logic; -- overflow buffer for subtraction - lab3
	--signal one : integer := 1;
	--signal increment : std_logic_vector(N-1 downto 0) := (0 => '1', others => '0');  --incrementing signal - lab3
	signal increment : std_logic_vector(N-1 downto 0);
	

begin
	 
	increment <= std_logic_vector(to_unsigned(1, increment'length));
	
	-- =============
	-- | ALU logic |
	-- =============
		
-- ALU operations logic
	operation : process(OP(2 downto 0), A, B) is
	begin
		case OP(2 downto 0) is
		  when "000" =>
				y_i <= A + B;
			when "001" =>
				y_i <= A - B;	 
			when "010" =>
				y_i <= A and B;
			when "011" =>
				y_i <= A or B;
			when "100" =>
				y_i <= A xor B;
			when "101" =>
				y_i <= not A;
			when "110" =>
				y_i <= A;
			when "111" =>
				-- zero function is replaced with increment operation for lab3
				-- y_i <= (y_i'range => '0');
				y_i <= A + increment;
			when others => 
				null;
		end case;
	end process operation;

 	-- ========================
 	-- | overflow calculation |
 	-- ========================
	
	ofc_add <= A(N-1) & B(N-1) & y_i(N-1);
	ofo_add <= '1' when ofc_add = "001" else
			   '1' when ofc_add = "110" else '0';
	
	ofc_sub <= A(N-1) & B(N-1) & y_i(N-1);
	ofo_sub <= '1' when ofc_sub = "011" else
			   '1' when ofc_sub = "100" else '0';

	ofc_incr <= A(N-1) & increment(N-1) & y_i(N-1);					-- added overflow detection for increment operation - lab3
	ofo_incr <= '1' when ofc_incr = "001" else
				'1' when ofc_incr = "110" else '0';

	-- ================
	-- | Output logic |
	-- ================
	
	-- Result ALU
	Sum <= y_i;
	
	-- Overflow flag
    O_Flag <= ofo_add when OP = "000" else
              ofo_sub when OP = "001" else
			  ofo_incr when OP = "111" else '0';
	
	-- Sign flag
	N_Flag <= y_i(N-1);
	
	-- Zero flag
	Z_Flag <= '1' when y_i = (y_i'range => '0') else '0';

end architecture behavioural;

