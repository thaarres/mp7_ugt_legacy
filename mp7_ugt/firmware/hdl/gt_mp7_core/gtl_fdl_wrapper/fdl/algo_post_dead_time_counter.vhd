--------------------------------------------------------------------------------
-- Synthesizer : ISE 14.6
-- Platform    : Linux Ubuntu 10.04
-- Targets     : Synthese
--------------------------------------------------------------------------------
-- This work is held in copyright as an unpublished work by HEPHY (Institute
-- of High Energy Physics) All rights reserved.  This work may not be used
-- except by authorized licensees of HEPHY. This work is the
-- confidential information of HEPHY.
--------------------------------------------------------------------------------
-- $HeadURL: svn://heros.hephy.at/GlobalTriggerUpgrade/firmware/gt_mp7/branches/hb_algo_2_buffer/src/gt_mp7_core/gtl_fdl_wrapper/fdl/algo_rate_counter.vhd $
-- $Date: 2015-06-12 12:26:03 +0200 (Fre, 12 Jun 2015) $
-- $Author: bergauer $
-- $Revision: 4032 $
--------------------------------------------------------------------------------

-- Desription:
-- Rate counter for algorithms in FDL
-- Output synchronized with sys_clk, to prevent wrong counter values when reading via PCIe.
-- This design only works with LHC clock (40 MHz) and PCIe system clock (125 MHz)

-- HB 2015-09-17: inserted "clear counter value in the "output" register for reading by IPBus" with sres_counter = '1'.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.math_pkg.all;

entity algo_post_dead_time_counter is
   generic( 
      COUNTER_WIDTH : integer := 32;
      MAX_DELAY : integer := 128
   );
   port( 
      sys_clk          : in     std_logic;
      lhc_clk          : in     std_logic;
      lhc_rst          : in     std_logic;
      sres_counter     : in     std_logic;
      store_cnt_value  : in     std_logic;
      l1a              : in     std_logic;
      delay            : in     std_logic_vector(log2c(MAX_DELAY)-1 downto 0);
      algo_i           : in     std_logic;
      counter_o        : out    std_logic_vector (COUNTER_WIDTH-1 DOWNTO 0) := (others => '0') -- init value (for simulation)
   );
end algo_post_dead_time_counter;

architecture rtl of algo_post_dead_time_counter is
    constant counter_end : std_logic_vector (COUNTER_WIDTH-1 DOWNTO 0) := (others => '1'); -- counter stops at this value
    signal counter : std_logic_vector (COUNTER_WIDTH-1 DOWNTO 0) := (others => '0');
    signal counter_int : std_logic_vector (COUNTER_WIDTH-1 DOWNTO 0);
    signal limit : std_logic := '0';
    signal store_cnt_value_lhc : std_logic := '0';
    signal store_cnt_value_sys : std_logic := '0';
    
    signal algo : std_logic_vector(0 downto 0);
    signal algo_delayed : std_logic_vector(0 downto 0);
    signal valid_o : std_logic;

begin

    algo(0) <= algo_i;
    
    algo_delay_i: entity work.delay_element
        generic map(
            DATA_WIDTH  => 1,
            MAX_DELAY  => MAX_DELAY
        )
        port map(
            lhc_clk     => lhc_clk,
            lhc_rst     => lhc_rst,
            data_i      => algo,
            data_o      => algo_delayed,
            valid_i     => '1',
            valid_o     => valid_o,
            delay       => delay
        );

   counter_p: process (lhc_clk, sres_counter, store_cnt_value, algo_delayed(0))
   begin
      if lhc_clk'event and lhc_clk = '1' then
        if sres_counter = '1' or store_cnt_value = '1' then
            counter <= (others => '0'); -- clear counter with synchr. reset and store_cnt_value (which is begin of lumi section)
         elsif limit = '1' then
            counter <= counter_end;
         elsif (limit = '0' and algo_delayed(0) = '1' and l1a = '1') then -- count up, only when (delayed) algo AND L1A active
            counter <= counter + 1;
         end if;
      end if;
   end process counter_p;

   compare_p: process (counter)
   begin
      if (counter = counter_end) then
         limit <= '1';
      else
         limit <= '0';
      end if;
   end process compare_p;

   store_int_p: process (lhc_clk, counter, store_cnt_value)
   begin
      if lhc_clk'event and lhc_clk = '1' then
         if store_cnt_value = '1' then
            counter_int <= counter; -- "store" counter value internally for read access with store_cnt_value (which is begin of lumi section)
         end if;
      end if;
   end process store_int_p;

-- Processes for clock domain change for read access via PCIe 
   store_cnt_value_lhc_p: process (lhc_clk, store_cnt_value)
   begin
      if lhc_clk'event and lhc_clk = '1' then
            store_cnt_value_lhc <= store_cnt_value;
      end if;
   end process store_cnt_value_lhc_p;

   store_sync_sys_p: process (sys_clk, store_cnt_value_lhc)
   begin
      if sys_clk'event and sys_clk = '1' then
            store_cnt_value_sys <= store_cnt_value_lhc;
      end if;
   end process store_sync_sys_p;

   store_p: process (sys_clk, counter_int, store_cnt_value_sys)
   begin
      if sys_clk'event and sys_clk = '1' then
-- HB 2015-09-17: inserted "clear counter value in the "output" register for reading by IPBus" with sres_counter = '1'.
         if sres_counter = '1' then
            counter_o <= (others => '0'); -- clear counter value in the "output" register for reading by IPBus
         elsif store_cnt_value_sys = '1' then
            counter_o <= counter_int; -- "store" counter value for read access
         end if;
      end if;
   end process store_p;

end architecture rtl;

