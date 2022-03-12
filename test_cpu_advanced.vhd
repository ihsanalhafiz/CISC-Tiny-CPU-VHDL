library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;    -- defines "+", "-" and "*" for std_logic_vectors to be unsigned
use ieee.std_logic_arith.all;       -- defines conv_std_logic_vector and conv_integer
use std.TEXTIO.all;
library modelsim_lib;
use modelsim_lib.util.all;          -- defines the spy_signal procedure
use work.micro_assembly_code.all; -- defines all assembly instruction codes used by the processor

entity test_cpu is
end test_cpu;

architecture test_cpu_advanced of test_cpu is
  component cpu
    generic(N:integer;
            M:integer);
    port(clk,reset:IN std_logic;
         Din:IN std_logic_vector(N-1 downto 0);
         address:OUT std_logic_vector(N-1 downto 0);
         Dout:OUT std_logic_vector(N-1 downto 0);
         rden,wren:OUT std_logic);
  end component;
  constant N:integer:=16;
  constant M:integer:=3;
  signal clk,reset:std_logic:='0';
  signal Din:std_logic_vector(N-1 downto 0);
  signal address:std_logic_vector(N-1 downto 0);
  signal Dout,mem_Dout:std_logic_vector(N-1 downto 0);
  signal RW:std_logic;
  signal rden,wren:std_logic;
  
  -- global test procedures
   procedure wait_for(N:integer) is
   begin
     for i in 1 to N loop
       wait on clk until clk='1';
     end loop;
   end wait_for;
   procedure i(signal instr:OUT instruction; op:instruction_code;wr_reg,rd_reg1,rd_reg2:reg_code) is
   begin
      Instr<=op & wr_reg & rd_reg1 & rd_reg2 & "000";
      wait_for(4);
   end i;
   procedure i(signal instr:OUT instruction; op:instruction_code;wr_reg:reg_code;imm:immediate) is
   begin
      Instr<=op & wr_reg & imm;
      wait_for(4);
   end i;
    -- branch instructions
   procedure i(signal instr:OUT instruction; op:instruction_code; immediate:integer) is
   begin
      Instr<=op & conv_std_logic_vector(immediate,12);
      wait_for(4);
   end i;
       
    -- test_signals in Modelsim (i.e., spy_signals)
  signal t_upc:std_logic_vector(1 downto 0);
  type rf_type is array(2**M - 1 downto 0) of std_logic_vector(N-1 downto 0);
  signal t_rf_mem:rf_type;
  signal t_z,t_n,t_o:std_logic;
  

  
  --for debug
  signal t_uop : std_logic_vector(3 downto 0);
  signal t_WAddr,t_RA,t_RB : std_logic_vector(M-1 downto 0);
  signal t_WD, t_instruction : std_logic_vector(N-1 downto 0);
  signal t_Write, t_ReadA, t_ReadB, t_IE, t_OE, t_zno : std_logic;
  signal t_OP : std_logic_vector(2 downto 0);
  signal t_offset : std_logic_vector(N-1 downto 0); --offset_buf
  signal t_output_alu : std_logic_vector(N-1 downto 0); --offset_buf
  signal t_flagbuf : std_logic_vector(1 downto 0); --flag_buf
  
begin
   -- Clock and reset generation
   clk<=not(clk) after 10 ns;
   reset<='0', '1' after 5 ns, '0' after 16 ns;
   
spy_process: -- Spy process connects signals inside the hierarchy to signals in the test_bench (simulator dependent - only works in Modelsim)
   process
   begin
       init_signal_spy("/test_cpu/dut/microcode_fsm_port/uPC","/t_upc",1); 
	   init_signal_spy("/test_cpu/dut/microcode_fsm_port/uOP","/t_uop",1);
	   init_signal_spy("/test_cpu/dut/microcode_fsm_port/IE","/t_IE",1);
	   init_signal_spy("/test_cpu/dut/microcode_fsm_port/OE","/t_OE",1);
	   init_signal_spy("/test_cpu/dut/ZNO_flag_buf","/t_zno",1);
	   init_signal_spy("/test_cpu/dut/instruction_reg","/t_instruction",1); --instruction_reg
       init_signal_spy("/test_cpu/dut/datapath_port/REG/reg_file_q","/t_rf_mem",1);
	   init_signal_spy("/test_cpu/dut/datapath_port/REG/WAddr","/t_WAddr",1);
	   init_signal_spy("/test_cpu/dut/datapath_port/REG/RA","/t_RA",1);
	   init_signal_spy("/test_cpu/dut/datapath_port/REG/RB","/t_RB",1);
	   init_signal_spy("/test_cpu/dut/datapath_port/REG/WD","/t_WD",1);
	   init_signal_spy("/test_cpu/dut/datapath_port/REG/Write","/t_Write",1);
	   init_signal_spy("/test_cpu/dut/datapath_port/REG/ReadA","/t_ReadA",1);
	   init_signal_spy("/test_cpu/dut/datapath_port/REG/ReadB","/t_ReadB",1);
	   init_signal_spy("/test_cpu/dut/datapath_port/ALUPort/OP","/t_OP",1);
	   init_signal_spy("/test_cpu/dut/datapath_port/ALUPort/Sum","/t_output_alu",1);
	   init_signal_spy("/test_cpu/dut/flag_buf","/t_flagbuf",1); -- flag_buf
       --init_signal_spy("/test/dut/z_flag","/t_z",1);
       --init_signal_spy("/test/dut/n_flag","/t_n",1);
       --init_signal_spy("/test/dut/o_flag","/t_o",1);
	   init_signal_spy("/test_cpu/dut/offset_buf","/t_offset",1);
	   init_signal_spy("/test_cpu/dut/Z_Flag_reg","/t_z",1);
	   init_signal_spy("/test_cpu/dut/N_Flag_reg","/t_n",1);
	   init_signal_spy("/test_cpu/dut/O_Flag_reg","/t_o",1);
       wait;
   end process spy_process;

   DUT:cpu generic map(N=>16,M=>3)
		   port map(clk=>clk,
					reset=>reset,
					Din=>Din,
					address=>address,
					Dout=>Dout,
					rden=>rden,
					wren=>wren);
   --rden<=RW;
   --wren<=not(RW);

test_all_instructions:
   process
      procedure test_ST(signal instr:OUT instruction;  wr_reg,rd_reg:integer) is
      begin
         Instr<=ST & Tail3 & conv_std_logic_vector(wr_reg,3) & conv_std_logic_vector(rd_reg,3) & Tail3;
         wait_for(2); 
		 wait for 1 ps;
		 assert(Dout=t_rf_mem(rd_Reg)) report "ST: Dout has the wrong value" severity failure;
		 assert(t_uPC="10") report "ST: Dout is set in the wrong clock cycle" severity failure;
		 wait_for(2); -- skip PC+1
		 wait for 1 ps;
		 assert(Address=t_rf_mem(wr_reg)) report "ST: Address has the wrong value" severity failure;
		 assert(wren='1') report "ST: RW has the wrong value" severity failure;
		 --wait_for(1); -- FI
      end test_ST;
	  procedure test_LD(signal instr:OUT instruction; wr_reg,rd_reg:integer) is
	  begin
         Instr<=LD & Tail3 & conv_std_logic_vector(wr_reg,3) & conv_std_logic_vector(rd_reg,3) & Tail3;
         wait_for(2); 
		 wait for 2 ns;
		 assert(Address=t_rf_mem(wr_Reg)) report "LD: Address has the wrong value" severity failure;
		 assert(t_uPC="10") report "LD: Address is set in the wrong clock cycle" severity failure;
		 assert(rden='1') report "LD: RW has the wrong value" severity failure;
		 wait_for(1);
		 Instr<="1010101010101010"; -- fake memory response
		 wait_for(1); -- skip PC+1
		 wait for 2 ns;
		 assert(t_rf_mem(rd_reg)="1010101010101010") report "LD: Loaded Data has the wrong value" severity failure;
		 --wait_for(1); -- FI
	  end test_LD;
   begin
       wait until reset='1';
       wait until reset='0';
           assert(t_uPC="00") report "Reset does not work" severity failure;
		   assert(address="0000000000000000") report "Memory Address reset does not work" severity failure;
		   assert(false) report "test_reset OK" severity note;
       i(Din,LDI,R0,"000000001");
	       assert(t_rf_mem(0)="000000000000001") report "LDI does not work" severity failure;
		   assert(address="0000000000000001") report "R7 - PC Address increment does not work";
		   report "LDI works OK";
       i(Din,LDI,R1,"100000001");
	       assert(t_rf_mem(1)="1111111100000001") report "LDI sign extension does not work" severity failure;
		   report "LDI sign extension works OK";

       i(Din,ADD,R2,R1,R0);
	       assert(t_rf_mem(2)="1111111100000010") report "ADD does not work" severity failure;
		   report "ADD works OK";
       i(Din,iSUB,R3,R2,R1);
	       assert(t_rf_mem(3)="0000000000000001") report "SUB does not work" severity failure;
		   report "SUB works OK";
       test_ST(Din,1,0);
	   report "ST works OK";

       i(Din,iNOT,R4,R3,R0); 
	       assert(t_rf_mem(4)="1111111111111110") report "NOT does not work" severity failure;
		   report "NOT works OK";
       i(Din,iOR,R5,R4,R3);
	       assert(t_rf_mem(5)="1111111111111111") report "OR does not work" severity failure;
		   report "OR works OK";
       i(Din,iAND,R6,R5,R2);
	       assert(t_rf_mem(6)="1111111100000010") report "AND does not work" severity failure;
		   report "AND works OK";
       i(Din,iXOR,R6,R6,R5);
	       assert(t_rf_mem(6)="0000000011111101") report "XOR does not work" severity failure;
		   report "XOR works OK";
	   test_LD(Din,4,0);
		   report "LD works OK";

	   -- At this point, Z=0, N=0, O=0
	   i(Din,BRZ,-15);
	       assert(t_rf_mem(7)="0000000000001011") report "Z=0:BRZ does not work" severity failure;
		   report "BRZ with Z=0 works OK";
	   i(Din,BRN,15);
	       assert(t_rf_mem(7)="0000000000001100") report "N=0:BRN does not work" severity failure;
		   report "BRN with N=0 works OK";
	   i(Din,BRO,-15);
	       assert(t_rf_mem(7)="0000000000001101") report "O=0:BRO does not work" severity failure;
		   report "BRO with O=0 works OK";

	   -- Create Z=1
	   i(Din,iXOR,R0,R0,R0);
	       assert(t_z='1') report "XOR Setting Z=1 does not work" severity failure;		
		   report "XOR Setting Z=1 works";
	   i(Din,BRZ,-15);
	       assert(t_rf_mem(7)="1111111111111111") report "Z=1:BRZ does not work" severity failure;
		   report "BRZ with negative offset works OK";
	   i(Din,BRZ,+15);
	       assert(t_rf_mem(7)="0000000000001110") report "Z=1:BRZ does not work" severity failure;
		   report "BRZ with posititve offset works OK";

	   -- Create Z=0, N=1
	   i(Din,iXOR,R0,R5,R0);
	       assert(t_n='1') report "Setting N=1 does not work" severity failure;		
		   report "XOR Setting N=1 works";
	   i(Din,BRN,-15);
	       assert(t_rf_mem(7)="0000000000000000") report "N=1:BRN does not work" severity failure;
		   report "BRN with negative address works OK";
	   i(Din,BRN,+15);
	       assert(t_rf_mem(7)="000000000001111") report "N=1:BRN does not work" severity failure;
		   report "BRN with positive address works OK";

       -- Create O=1
	   i(Din,LDI,R0,"011111111");
	   i(Din,ADD,R0,R0,R0);
	   i(Din,ADD,R0,R0,R0);
	   i(Din,ADD,R0,R0,R0);
	   i(Din,ADD,R0,R0,R0);
	   i(Din,ADD,R0,R0,R0);
	   i(Din,ADD,R0,R0,R0);
	   i(Din,ADD,R0,R0,R0);
	   i(Din,ADD,R0,R0,R0);
	      assert(t_o='1') report "ADD setting O=1 does not work";
		  report "ADD setting O=1 works OK";
	   i(Din,BRO,-15);
	       assert(t_rf_mem(7)="0000000000001001") report "O=1:BRO does not work" severity failure;
		   report "BRO with negative address works OK";
	   i(Din,BRO,15);
	       assert(t_rf_mem(7)="0000000000011000") report "O=1:BRO does not work" severity failure;
		   report "BRO with positive address works OK";

	   i(Din,BRA,-15);
	       assert(t_rf_mem(7)="0000000000001001") report "BRA does not work" severity failure;
		   report "BRA with negative address works OK";
	   i(Din,BRA,57);
	       assert(t_rf_mem(7)="0000000001000010") report "BRA does not work" severity failure;
		   report "BRA with positive address works OK";
	   wait on clk until clk='1';
	   report "CPU passes all tests.";
	   assert(false) report "Ending Simulation." severity failure;
   end process;

end test_cpu_advanced;
