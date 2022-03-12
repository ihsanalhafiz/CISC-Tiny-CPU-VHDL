library ieee;
use ieee.std_logic_1164.all;

entity register_ent is
    generic(N:integer);
    port(   D	: in std_logic_vector(N-1 downto 0);
            clk	: in std_logic;
			rst	: in std_logic;
            Q	: out std_logic_vector(N-1 downto 0));
end register_ent;

architecture behavioral of register_ent is
begin
    process(clk,rst)
    begin
        if rst='1' then
            Q <= (others=>'0');
        elsif rising_edge(clk) then
            --Q <= D;
        end if;
		Q <= D;
    end process;
	
end behavioral;

