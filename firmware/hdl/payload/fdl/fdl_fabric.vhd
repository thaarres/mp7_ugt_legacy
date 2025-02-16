
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;
use work.fdl_addr_decode.ALL;

entity fdl_fabric is
  generic(
    NSLV: positive;
    STROBE_GAP: boolean := false
  );
  port(
	 ipb_clk: in STD_LOGIC;
     ipb_rst: in STD_LOGIC;
	 ipb_in: in ipb_wbus;
	 ipb_out: out ipb_rbus;
	 ipb_to_slaves:  out ipb_wbus_array(NSLV-1 downto 0);
	 ipb_from_slaves: in ipb_rbus_array(NSLV-1 downto 0)
	);

end fdl_fabric;

architecture rtl of fdl_fabric is

	attribute keep : boolean;
	signal sel_ipb_slave : integer := 0;
	attribute keep of sel_ipb_slave : signal is true;

	attribute keep of ipb_from_slaves : signal is true;

	type mux_rdata_t is array(NSLV downto 0) of std_logic_vector(31 downto 0);
	signal mux_rdata: mux_rdata_t;
	signal ored_err : std_logic_vector(NSLV downto 0);
	signal ored_ack : std_logic_vector(NSLV downto 0);
	signal qstrobe : std_logic;

begin

	process(ipb_in.ipb_addr)
	begin
		sel_ipb_slave <= fdl_addr_sel(ipb_in.ipb_addr);
	end process;

	mux_rdata(NSLV) <= (others => '0');
	ored_ack(NSLV) <= '0';
	ored_err(NSLV) <= '0';
	
	qstrobe <= ipb_in.ipb_strobe when STROBE_GAP = false else
	 ipb_in.ipb_strobe and not (ored_ack(0) or ored_err(0));

	busgen: for i in NSLV-1 downto 0 generate
		signal qual_rdata: std_logic_vector(31 downto 0);
	begin

		ipb_to_slaves(i).ipb_addr 		<= ipb_in.ipb_addr;
		ipb_to_slaves(i).ipb_wdata 	<= ipb_in.ipb_wdata;
		ipb_to_slaves(i).ipb_strobe 	<= qstrobe when sel_ipb_slave=i else '0';
		ipb_to_slaves(i).ipb_write 	<= ipb_in.ipb_write;

		qual_rdata 		<= ipb_from_slaves(i).ipb_rdata when sel_ipb_slave=i else (others => '0');
		mux_rdata(i) 	<= qual_rdata or mux_rdata(i+1);
		ored_ack(i) 	<= ored_ack(i+1) or ipb_from_slaves(i).ipb_ack;
		ored_err(i) 	<= ored_err(i+1) or ipb_from_slaves(i).ipb_err;		

	end generate;

    ipb_out.ipb_rdata <= mux_rdata(0);
    ipb_out.ipb_ack <= ored_ack(0);
    ipb_out.ipb_err <= ored_err(0);
  
end rtl;

