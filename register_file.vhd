-- =====================================================
-- | Lab 2 : Register File |
-- =====================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
	generic (
		N : integer;	-- item size
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
		ReadA  	: in  std_logic; -- enable Read A
		ReadB  	: in  std_logic; -- enable Read B
		
		QA		: out std_logic_vector(N-1 downto 0);	-- A datum read
		QB		: out std_logic_vector(N-1 downto 0)	-- B datum read
	);
end entity register_file;

architecture RTL of register_file is
	type reg_t is array(2**M - 1 downto 0) of std_logic_vector(N-1 downto 0);
	signal reg_file_q : reg_t := (others => (others => '0'));
	
begin
	
	-- =======================
	-- | Register file logic |
	-- =======================
	register_logic : process(clk, rst) is
	begin
		if rst = '1' then
			reg_file_q <= (others => (others => '0'));	
		elsif rising_edge(clk) then
			if Write = '1' then
				reg_file_q(to_integer(unsigned(WAddr))) <= WD;
			end if;	
		end if;

	end process register_logic;
	

	QA <= reg_file_q(to_integer(unsigned(RA))) when ReadA = '1' else (others => '0');
	QB <= reg_file_q(to_integer(unsigned(RB))) when ReadB = '1' else (others => '0');

end architecture RTL;

