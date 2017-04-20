
-- Description:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; -- for function "CONV_INTEGER"
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

use work.math_pkg.all;
use work.gtl_pkg.all;

entity calo_calo_correlation_condition_v2_mass_cuts_same_obj_bx_TB is
end calo_calo_correlation_condition_v2_mass_cuts_same_obj_bx_TB;

architecture rtl of calo_calo_correlation_condition_v2_mass_cuts_same_obj_bx_TB is

    constant LHC_CLK_PERIOD  : time :=  25 ns;

    signal lhc_clk : std_logic;
        
--     constant same_bx : boolean := false;
    constant same_bx : boolean := true;
    
    constant deta_cut : boolean := false;
    constant dphi_cut : boolean := false;
    constant mass_cut : boolean := true;
--     constant mass_type : natural := 0;
--     constant mass_type : natural := INVARIANT_MASS_PT_TYPE;
    constant mass_type : natural := INVARIANT_MASS_TYPE;
--     constant mass_type : natural := TRANSVERSE_MASS_TYPE;
--     constant mass_type : natural := TRANSVERSE_MASS_PT_TYPE;
--     constant mass_type : natural := 4;
    
    constant MASS_PRECISION : positive := JET_JET_INV_MASS_PRECISION;
    constant PT_VECTOR_WIDTH : positive := JET_PT_VECTOR_WIDTH;
    constant MASS_COSH_COS_PRECISION : positive := JET_JET_COSH_COS_PRECISION;
    constant COSH_COS_VECTOR_WIDTH : positive := JET_JET_COSH_COS_VECTOR_WIDTH;	

    constant calo1_object_low: natural := 0;
    constant calo1_object_high: natural := 2;
    constant et_ge_mode_calo1: boolean := true;
    constant obj_type_calo1: natural := JET_TYPE;
    constant et_threshold_calo1: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0) := X"0020";
    constant eta_full_range_calo1: boolean := true;
    constant eta_w1_upper_limit_calo1: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0) := X"0000";
    constant eta_w1_lower_limit_calo1: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0) := X"0000";
    constant eta_w2_ignore_calo1: boolean := true;
    constant eta_w2_upper_limit_calo1: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0) := X"0000";
    constant eta_w2_lower_limit_calo1: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0) := X"0000";
    constant phi_full_range_calo1: boolean := true;
    constant phi_w1_upper_limit_calo1: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0) := X"0000";
    constant phi_w1_lower_limit_calo1: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0) := X"0000";
    constant phi_w2_ignore_calo1: boolean := true;
    constant phi_w2_upper_limit_calo1: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0) := X"0000";
    constant phi_w2_lower_limit_calo1: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0) := X"0000";
    constant iso_lut_calo1: std_logic_vector(2**MAX_CALO_ISO_BITS-1 downto 0) := X"F";

    constant calo2_object_low: natural := calo1_object_low;
    constant calo2_object_high: natural := calo1_object_high;
    constant et_ge_mode_calo2: boolean := true;
    constant obj_type_calo2: natural := obj_type_calo1;
    constant et_threshold_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0) := X"0010";
    constant eta_full_range_calo2: boolean := true;
    constant eta_w1_upper_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0):= X"0000";
    constant eta_w1_lower_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0):= X"0000";
    constant eta_w2_ignore_calo2: boolean := true;
    constant eta_w2_upper_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0):= X"0000";
    constant eta_w2_lower_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0):= X"0000";
    constant phi_full_range_calo2: boolean := true;
    constant phi_w1_upper_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0):= X"0000";
    constant phi_w1_lower_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0):= X"0000";
    constant phi_w2_ignore_calo2: boolean := true;
    constant phi_w2_upper_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0):= X"0000";
    constant phi_w2_lower_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0):= X"0000";
    constant iso_lut_calo2: std_logic_vector(2**MAX_CALO_ISO_BITS-1 downto 0) := X"F";
        
    constant dr_upper_limit : dr_squared_range_real := 1.0;
    constant dr_lower_limit : dr_squared_range_real := 0.0;
        
    constant mass_upper_limit : real := 200.1;
    constant mass_lower_limit : real := 3.0;

    constant pt_sq_threshold : real := 2805.0;
--     constant pt_sq_threshold : real := 80.0;
        
-- ************************************************************************************************

    signal jet, jet_bx_p2, jet_temp, jet_bx_0: calo_objects_array(0 to NR_JET_OBJECTS-1) := (others => X"00000000");
--     signal calo_inv_mass_bx0: calo_objects_array(0 to (max(NR_JET_OBJECTS, NR_TAU_OBJECTS))-1) := (others => X"00000000");

    signal jet_eta_integer_bx_0: diff_integer_inputs_array(0 to NR_JET_OBJECTS-1) := (others => 0);
    signal jet_phi_integer_bx_0: diff_integer_inputs_array(0 to NR_JET_OBJECTS-1) := (others => 0);

    signal diff_jet_jet_eta_integer_bx_0_bx_0 : dim2_max_eta_range_array(0 to NR_JET_OBJECTS-1, 0 to NR_JET_OBJECTS-1) := (others => (others => 0));      
    signal diff_jet_jet_phi_integer_bx_0_bx_0 : dim2_max_phi_range_array(0 to NR_JET_OBJECTS-1, 0 to NR_JET_OBJECTS-1) := (others => (others => 0));      
    signal diff_jet_jet_eta_vector_bx_0_bx_0 : deta_dphi_vector_array(0 to NR_JET_OBJECTS-1, 0 to NR_JET_OBJECTS-1) := (others => (others => (others => '0')));      
    signal diff_jet_jet_phi_vector_bx_0_bx_0 : deta_dphi_vector_array(0 to NR_JET_OBJECTS-1, 0 to NR_JET_OBJECTS-1) := (others => (others => (others => '0')));      

    signal jet_pt_vector_bx_0: diff_inputs_array(0 to NR_JET_OBJECTS-1) := (others => (others => '0'));
    signal jet_jet_cosh_deta_vector_bx_0_bx_0: calo_cosh_cos_vector_array(0 to NR_JET_OBJECTS-1, 0 to NR_JET_OBJECTS-1) := (others => (others => (others => '0')));
    signal jet_jet_cos_dphi_vector_bx_0_bx_0: calo_cosh_cos_vector_array(0 to NR_JET_OBJECTS-1, 0 to NR_JET_OBJECTS-1) := (others => (others => (others => '0')));
    signal jet_cos_phi_bx_0: calo_sin_cos_integer_array(0 to NR_JET_OBJECTS-1) := (others => 0);
    signal jet_sin_phi_bx_0: calo_sin_cos_integer_array(0 to NR_JET_OBJECTS-1) := (others => 0);

    signal condition_o: std_logic;

--*********************************Main Body of Code**********************************
begin
    
    -- Clock
    process
    begin
        lhc_clk  <=  '1';
        wait for LHC_CLK_PERIOD/2;
        lhc_clk  <=  '0';
        wait for LHC_CLK_PERIOD/2;
    end process;

    process
    begin
        wait for 5 * LHC_CLK_PERIOD; 
        wait for 7 ns; 
        jet <= (("00000"&X"00"&X"01"&("000"&X"38")), ("00000"&X"40"&X"30"&("000"&X"11")), ("00000"&X"42"&X"31"&("000"&X"11")), others => X"00000000");
        wait for LHC_CLK_PERIOD; 
        jet <= (("00000"&X"40"&X"92"&("000"&X"11")), ("00000"&X"89"&X"89"&("000"&X"11")), ("00000"&X"89"&X"89"&("000"&X"11")), others => X"00000000");
        wait for LHC_CLK_PERIOD; 
        jet <= (("00000"&X"00"&X"01"&("000"&X"38")), ("00000"&X"40"&X"30"&("000"&X"30")), ("00000"&X"42"&X"31"&("000"&X"31")), others => X"00000000");
        wait for LHC_CLK_PERIOD; 
        jet <= (("00000"&X"40"&X"92"&("000"&X"11")), ("00000"&X"89"&X"89"&("000"&X"11")), ("00000"&X"89"&X"89"&("000"&X"11")), others => X"00000000");
        wait for LHC_CLK_PERIOD; 
        wait; 
    end process;

 ------------------- Instantiate  modules  -----------------
pipeline_p: process(lhc_clk, jet)
    begin
        if (lhc_clk'event and lhc_clk = '1') then
           jet_bx_0 <= jet;
        end if;
end process;

jet_l: for i in 0 to NR_JET_OBJECTS-1 generate
  jet_pt_vector_bx_0(i)(JET_PT_VECTOR_WIDTH-1 downto 0) <= CONV_STD_LOGIC_VECTOR(JET_PT_LUT(CONV_INTEGER(jet_bx_0(i)(D_S_I_JET_V2.et_high downto D_S_I_JET_V2.et_low))), JET_PT_VECTOR_WIDTH);
  jet_eta_integer_bx_0(i) <= CONV_INTEGER(signed(jet_bx_0(i)(D_S_I_JET_V2.eta_high downto D_S_I_JET_V2.eta_low)));
  jet_phi_integer_bx_0(i) <= CONV_INTEGER(jet_bx_0(i)(D_S_I_JET_V2.phi_high downto D_S_I_JET_V2.phi_low));
  jet_cos_phi_bx_0(i) <= CALO_COS_PHI_LUT(CONV_INTEGER(jet_bx_0(i)(D_S_I_JET_V2.phi_high downto D_S_I_JET_V2.phi_low)));
  jet_sin_phi_bx_0(i) <= CALO_SIN_PHI_LUT(CONV_INTEGER(jet_bx_0(i)(D_S_I_JET_V2.phi_high downto D_S_I_JET_V2.phi_low)));
end generate;

diff_jet_jet_eta_bx_0_i: entity work.sub_eta_integer_obj_vs_obj
  generic map(NR_JET_OBJECTS, NR_JET_OBJECTS)
  port map(jet_eta_integer_bx_0, jet_eta_integer_bx_0, diff_jet_jet_eta_integer_bx_0_bx_0);      
diff_jet_jet_phi_bx_0_i: entity work.sub_phi_integer_obj_vs_obj
  generic map(NR_JET_OBJECTS, NR_JET_OBJECTS, CALO_PHI_HALF_RANGE_BINS)
  port map(jet_phi_integer_bx_0, jet_phi_integer_bx_0, diff_jet_jet_phi_integer_bx_0_bx_0);

jet_jet_l1: for i in 0 to NR_JET_OBJECTS-1 generate
  jet_jet_l2: for j in 0 to NR_JET_OBJECTS-1 generate
    diff_jet_jet_eta_vector_bx_0_bx_0(i,j) <= CONV_STD_LOGIC_VECTOR(JET_JET_DIFF_ETA_LUT(diff_jet_jet_eta_integer_bx_0_bx_0(i,j)),DETA_DPHI_VECTOR_WIDTH_ALL);
    diff_jet_jet_phi_vector_bx_0_bx_0(i,j) <= CONV_STD_LOGIC_VECTOR(JET_JET_DIFF_PHI_LUT(diff_jet_jet_phi_integer_bx_0_bx_0(i,j)),DETA_DPHI_VECTOR_WIDTH_ALL);
  end generate jet_jet_l2;
end generate jet_jet_l1;

jet_jet_cosh_cos_l1: for i in 0 to NR_JET_OBJECTS-1 generate
  jet_jet_cosh_cos_l2: for j in 0 to NR_JET_OBJECTS-1 generate
    jet_jet_cosh_deta_vector_bx_0_bx_0(i,j) <= CONV_STD_LOGIC_VECTOR(JET_JET_COSH_DETA_LUT(diff_jet_jet_eta_integer_bx_0_bx_0(i,j)), JET_JET_COSH_COS_VECTOR_WIDTH);
    jet_jet_cos_dphi_vector_bx_0_bx_0(i,j) <= CONV_STD_LOGIC_VECTOR(JET_JET_COS_DPHI_LUT(diff_jet_jet_phi_integer_bx_0_bx_0(i,j)), JET_JET_COSH_COS_VECTOR_WIDTH);
  end generate jet_jet_cosh_cos_l2;
end generate jet_jet_cosh_cos_l1;

dut: entity work.calo_calo_correlation_condition_v2
     generic map(
        
        same_bx => same_bx,

        deta_cut => deta_cut,
        dphi_cut => dphi_cut,
        mass_cut => mass_cut,
        mass_type => mass_type,

        calo1_object_low => calo1_object_low,
        calo1_object_high => calo1_object_high,
        et_ge_mode_calo1 => et_ge_mode_calo1,
        obj_type_calo1 => obj_type_calo1,
        et_threshold_calo1 => et_threshold_calo1,
        eta_full_range_calo1 => eta_full_range_calo1,
        eta_w1_upper_limit_calo1 => eta_w1_upper_limit_calo1,
        eta_w1_lower_limit_calo1 => eta_w1_lower_limit_calo1,
        eta_w2_ignore_calo1 => eta_w2_ignore_calo1,
        eta_w2_upper_limit_calo1 => eta_w2_upper_limit_calo1,
        eta_w2_lower_limit_calo1 => eta_w2_lower_limit_calo1,
        phi_full_range_calo1 => phi_full_range_calo1,
        phi_w1_upper_limit_calo1 => phi_w1_upper_limit_calo1,
        phi_w1_lower_limit_calo1 => phi_w1_lower_limit_calo1,
        phi_w2_ignore_calo1 => phi_w2_ignore_calo1,
        phi_w2_upper_limit_calo1 => phi_w2_upper_limit_calo1,
        phi_w2_lower_limit_calo1 => phi_w2_lower_limit_calo1,
	iso_lut_calo1 => iso_lut_calo1,
--
        calo2_object_low => calo2_object_low,
        calo2_object_high => calo2_object_high,
        et_ge_mode_calo2 => et_ge_mode_calo2,
        obj_type_calo2 => obj_type_calo2,
        et_threshold_calo2 => et_threshold_calo2,
        eta_full_range_calo2 => eta_full_range_calo2,
        eta_w1_upper_limit_calo2 => eta_w1_upper_limit_calo2,
        eta_w1_lower_limit_calo2 => eta_w1_lower_limit_calo2,
        eta_w2_ignore_calo2 => eta_w2_ignore_calo2,
        eta_w2_upper_limit_calo2 => eta_w2_upper_limit_calo2,
        eta_w2_lower_limit_calo2 => eta_w2_lower_limit_calo2,
        phi_full_range_calo2 => phi_full_range_calo2,
        phi_w1_upper_limit_calo2 => phi_w1_upper_limit_calo2,
        phi_w1_lower_limit_calo2 => phi_w1_lower_limit_calo2,
        phi_w2_ignore_calo2 => phi_w2_ignore_calo2,
        phi_w2_upper_limit_calo2 => phi_w2_upper_limit_calo2,
        phi_w2_lower_limit_calo2 => phi_w2_lower_limit_calo2,
	iso_lut_calo2 => iso_lut_calo2,
--
	diff_eta_upper_limit => 0.0,
        diff_eta_lower_limit => 0.0, 

        diff_phi_upper_limit => 0.0, 
        diff_phi_lower_limit => 0.0, 
        
        dr_upper_limit => dr_upper_limit,
        dr_lower_limit => dr_lower_limit,
--        
	DETA_DPHI_VECTOR_WIDTH => DETA_DPHI_VECTOR_WIDTH_ALL,
	DETA_DPHI_PRECISION => JET_JET_DETA_DPHI_PRECISION,

        mass_upper_limit => mass_upper_limit,
        mass_lower_limit => mass_lower_limit,

        MASS_PRECISION => MASS_PRECISION,
	pt1_width => PT_VECTOR_WIDTH,
	pt2_width => PT_VECTOR_WIDTH,
	MASS_COSH_COS_PRECISION => MASS_COSH_COS_PRECISION,
	cosh_cos_width => COSH_COS_VECTOR_WIDTH,	
        -- generics for pt**2
        pt_sq_threshold => pt_sq_threshold, 
        sin_cos_width => CALO_SIN_COS_VECTOR_WIDTH, 
        PT_PRECISION => JET_JET_PT_PRECISION, 
        PT_SQ_SIN_COS_PRECISION => JET_JET_SIN_COS_PRECISION

    )
    port map(
        lhc_clk => lhc_clk,
        calo1_data_i => jet_bx_0,
        calo2_data_i => jet_bx_0,
        diff_eta => diff_jet_jet_eta_vector_bx_0_bx_0,
        diff_phi => diff_jet_jet_phi_vector_bx_0_bx_0,
        pt1 => jet_pt_vector_bx_0,
        pt2 => jet_pt_vector_bx_0,
	cosh_deta => jet_jet_cosh_deta_vector_bx_0_bx_0,
	cos_dphi => jet_jet_cos_dphi_vector_bx_0_bx_0,
        cos_phi_1_integer => jet_cos_phi_bx_0, 
        cos_phi_2_integer => jet_cos_phi_bx_0, 
        sin_phi_1_integer => jet_sin_phi_bx_0, 
        sin_phi_2_integer => jet_sin_phi_bx_0,
	condition_o => condition_o
    );

end rtl;

