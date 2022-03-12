library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity computer is
  generic(N : integer := 16;
		  M : integer := 3);
  port(clk, reset, OE : in std_logic;
      PIO : out std_logic_vector(7 downto 0));
end computer;

architecture behave of computer is
  component cpu is
    	generic ( N : integer := 16;
			  M : integer := 3 );
	   port	( clk,reset:IN std_logic;
			  Din:IN std_logic_vector(N-1 downto 0);
			  address:OUT std_logic_vector(N-1 downto 0);
			  Dout:OUT std_logic_vector(N-1 downto 0);
			  rden, wren:OUT std_logic);
	end component;
	
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
	
	component GPIO is
	generic(N:integer);
	port(Din : in std_logic_vector(N-1 downto 0);
		clk, reset, IE, OE : in std_logic;
		Dout_GPIO : out std_logic_vector(N-1 downto 0));
	end component;
	
	signal address16bit : std_logic_vector(15 downto 0) := (others=> '0');
	signal address8bit : std_logic_vector(7 downto 0) := (others=> '0');
	signal memorydataout : std_logic_vector(15 downto 0);
	signal Dout : std_logic_vector(15 downto 0);
	signal Dout_reg : std_logic_vector(15 downto 0);
	signal rden, wren, Wren_in : std_logic;
	signal rden_reg, wren_reg : std_logic;
	signal IE: std_logic;
	
begin
	
	cpu_port : cpu
	    generic map ( 	N => N,
						M => M)
		port map ( 	clk => clk,
					reset => reset,
					Din => memorydataout,
					address => address16bit,
					Dout => Dout,
					rden => rden, 
					wren => wren);
	
	memory_port : entity work.memory(SYN) 
		port map (	address => address8bit,
					clock => clk,
					data => Dout,
					rden => rden,
					wren => wren,
					q => memorydataout);
					
	GPIO_port : GPIO
		generic map (	N => 8)
		port map (	Din => Dout(7 downto 0),
					clk => clk,
					reset => reset, 
					IE => IE, 
					OE => OE,
					Dout_GPIO => PIO);
	
	address8bit <= address16bit(7 downto 0);
	IE <= '1' when address16bit = X"F000" else '0';
	Wren_in<= '0' when (unsigned(address16bit)>255) else wren;
	
end behave;
