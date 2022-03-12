library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_memory is
end test_memory;

architecture behave of test_memory is
	component memory IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rden		: IN STD_LOGIC ;
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
	END component;
	
	signal clk : std_logic := '0';
	signal rden_buf, wren_buf : std_logic;
	signal memorydataout : std_logic_vector(15 downto 0);
	signal cpudataout : std_logic_vector(15 downto 0);
	signal address8bit : std_logic_vector(7 downto 0);

begin

	memory_port : entity work.memory(fake) 
		port map (	address => address8bit,
					clock => clk,
					data => cpudataout,
					rden => rden_buf,
					wren => wren_buf,
					q => memorydataout);
					
	clk <= not(clk) after 5 ns;
	rden_buf <= '1';
	
	write_address : process 
		variable i : integer;
	begin
		for i in 0 to 25 loop
			wait until rising_edge(clk);
			address8bit <= std_logic_vector(to_unsigned(i, 8));
		end loop;
	end process;
		
end behave;
