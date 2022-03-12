library ieee;
use ieee.std_logic_1164.all;

entity GPIO is
	generic(N:integer := 8);
	port(Din : in std_logic_vector(N-1 downto 0);
		clk, reset, IE, OE : in std_logic;
		Dout_GPIO : out std_logic_vector(N-1 downto 0));
end GPIO;

architecture behave of GPIO is
	signal mux, regbuf, Doutbuf : std_logic_vector(N-1 downto 0);
begin
	process(clk, reset)
	begin
		if(reset = '1') then
			regbuf <= (others=>'0');
		elsif rising_edge(clk) then
			--if (IE='1') then
			--	regbuf <= Din;
			--else regbuf <= Doutbuf;
			--end if;
			regbuf <= mux;
		end if;
	end process;
	
	mux <= Din when IE = '1' else Doutbuf;
	Doutbuf <= regbuf when OE = '1' else (others=>'Z');
	
	Dout_GPIO <= Doutbuf;
	
end behave;
