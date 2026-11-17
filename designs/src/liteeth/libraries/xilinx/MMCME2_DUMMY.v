///////////////////////////////////////////////////////////////////////////////
//     Copyright (c) 1995/2017 Xilinx, Inc.
// 
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /     Vendor      : Xilinx
// \   \   \/      Version     : 2017.1
//  \   \          Description : Xilinx Unified Simulation Library Component
//  /   /                        Advanced Mixed Mode Clock Manager (MMCM)
// /___/   /\      Filename    : MMCME2_ADV.v
// \   \  /  \
//  \___\/\___\
//
///////////////////////////////////////////////////////////////////////////////
//  Revision:
//  07/07/08 - Initial version.
//  09/19/08 - Change CLKFBOUT_MULT to CLKFBOUT_MULT_F
//                    CLKOUT0_DIVIDE to CLKOUT0_DIVIDE_F
//  10/03/08 - Initial all signals.
//  10/30/08 - Clock source switching without reset (CR492263).
//  11/18/08 - Add timing check for DADDR[6:5].
//  12/02/08 - Fix bug of Duty cycle calculation (CR498696)
//  12/05/08 - change pll_res according to hardware spreadsheet (CR496137)
//  12/09/08 - Enable output at CLKFBOUT_MULT_F*8 for fraction mode (CR499322)
//  01/08/09 - Add phase and duty cycle checks for fraction divide (CR501181)
//  01/09/09 - make pll_res same for BANDWIDTH=HIGH and OPTIMIZED (CR496137)
//  01/14/09 - Fine phase shift wrap around to 0 after 56 times;
//           - PSEN to PSDONE change to 12 PSCLK; RST minpusle to 5ns;
//           - add pulldown to PWRDWN pin. (CR503425)
//  01/14/09 - increase clkout_en_time for fraction mode (CR499322)
//  01/21/09 - align CLKFBOUT to CLKIN for fraction mode (CR504602)
//  01/27/09 - update DRP register address (CR505271)
//  01/28/09 - assign clkout_en0 and clkout_en1 to 0 when RST=1 (CR505767)
//  02/03/09 - Fix bug in clkfb fine phase shift.
//          - Add delay to clkout_en0_tmp (CR506530).
//  02/05/09 - Add ps_in_ps calculation to clkvco_delay when clkfb_fps_en=1.
//           - round clk_ht clk_lt for duty_cycle (CR506531)
//  02/11/09 - Change VCO_FREQ_MAX and MIN to 1601 and 399 to cover the rounded
//             error (CR507969)
//  02/25/09 - round clk_ht clk_lt for duty_cycle (509386)
//  02/26/09 - Fix for clkin and clkfbin stop case (CR503425)
//  03/04/09 - Fix for CLOCK_HOLD (CR510820).
//  03/27/09 - set default 1 to CLKINSEL pin (CR516951)
//  04/13/09 - Check vco range when CLKINSEL not connected (CR516951)
//  04/22/09 - Add reset to clkinstopped related signals (CR519102)
//  04/27/09 - Make duty cycle of fraction mode 50/50 (CR519505)
//  05/13/09 - Use period_avg for clkvco_delay calculation (CR521120)
//  07/23/09 - fix bug in clk0_dt (CR527643)
//  07/27/09 - Do divide when period_avg > 0 (CR528090)
//           - Change DIVCLK_DIVIDE to 80 (CR525904)
//           - Add initial lock setting (CR524523)
//           - Update RES CP setting (CR524522)
//  07/31/09  - Add if else to handle the fracion and nonfraction for clkout_en.
//  08/10/09  - Calculate clkin_lost_val after lock_period=1 (CR528520).
//  08/15/09 - Update LFHF (CR524522)
//  08/19/09 - Set clkfb_lost_val initial value (CR531354)
//  08/28/09 - add clkin_period_tmp_t to handle period_avg calculation
//             when clkin has jitter (CR528520)
//  09/11/09 - Change CLKIN_FREQ_MIN to 10 Mhz (CR532774)
//  10/01/09 - Change CLKIN_FREQ_MAX to 800Mhz (CR535076)
//             Add reset check for clock switchover (CR534900)
//  10/08/09 - Change CLKIN_FREQ MAX & MIN, CLKPFD_FREQ
//             MAX & MIN to parameter (CR535828)
//  10/14/09 - Add clkin_chk_t1 and clkin_chk_t2 to handle check (CR535662)
//  10/22/09 - Add period_vco_mf for clkvco_delay calculation (CR536951)
//             Add cmpvco to compensate period_vco rounded error (CR537073)
//  12/02/09 - not stop clkvco_lk when jitter (CR538717)
//  01/08/10 - Change minimum RST pulse width from 5 ns to 1.5 ns
//             Add 1 ns delay to locked_out_tmp when RST=1 (CR543857)
//  01/19/10 - make change to clkvoc_lk_tmp to handle M=1 case (CR544970)
//  02/09/10 - Add global PLL_LOCKG (CR547918)
//  02/23/10 - Not use edge for locked_out_tmp (CR549667)
//  03/04/10 - Change CLKFBOUT_MULT_F range to 5-64 (CR551618)
//  03/22/10 - Change CLKFBOUT_MULT_F default to 5 (554618)
//  03/24/10 - Add SIM_DEVICE attribute
//  04/07/10 - Generate clkvco_ps_tmp2_en correctly when ps_lock_dly rising
//             and clkout_ps=1 case; increase lock_period time to 10 (CR556468)
//  05/07/10 - Use period_vco_half_rm1 to reduce jitter (CR558966)
//  07/28/10 - Update ref parameter values (CR569260)
//  08/17/10 - Add Decay output clocks when input clock stopped (CR555324)
//  09/03/10 - use %f for M_MIN and M_MAX  (CR574247)
//  09/09/10 - Change to bus timing.
//  09/26/10 - Add RST to LOCKED timing path (CR567807)
//  02/22/11 - reduce clkin period check resolution to 0.001 (CR594003)
//  03/08/11 - Support fraction mode phase shifting with phase parameter
//             setting (CR596402)
//  04/26/11 - Support fraction mode phase shifting with DRP(CR607989)
//  05/24/11 - Set frac_wf_f to 1 when divide=2.125 (CR611840)
//  06/06/11 - set period_vco_half_rm2 to 0 when period_vco=0 (CR613021)
//  06/08/11 - Disable clk0 fraction mode when CLKOUT0_DIVIDE_F in range
//             greater than 1 and less than 2. Add DRC check for it (608893)
//  08/03/11 - use clk0_frac instead of clk0_sfrac (CR 618600)
//  10/26/11 - Add DRC check for samples CLKIN period with parameter setting (CR631150)
//             Add spectrum attributes.
//  12/13/11 - Added `celldefine and `endcelldefine (CR 524859).
//  02/22/12 - Modify DRC (638094).
//  03/01/12 - fraction enable for m/d (CR 648429)
//  03/07/12 - added vcoflag (CR 638088, CR 636493)
//  04/19/12 - 654951 - rounding issue with clk_out_para_cal
//  05/03/12 - ncsim issue with clkfb_frac_en (CR 655792)
//  05/03/12 - jittery clock (CR 652401)
//  05/03/12 - incorrect period (CR 654951)
//  05/10/12 - fractional divide calculation issue (CR 658151)
//  05/18/12 - fractional divide calculation issue (CR 660657)
//  06/11/12 - update cp and res settings (CR 664278)
//  06/20/12 - modify reset drc (CR 643540)
//  09/06/12 - 655711 - modify displayed MAX on CLK_DUTY_CYCLE
//  12/12/12 - fix clk_osc process for ncsim (CR 676829)
//  04/04/13 - fix clkvco_frac_en for DRP (CR 709093)
//  04/09/13 - Added DRP monitor (CR 695630).
//  05/03/13 - 670208 Fractional clock alignment issue
//  05/31/13 - 720783 - revert clock alignment fix
//  10/22/2014 808642 - Added #1 to $finish
//  11/26/2014 829050 - remove CLKIN -> CLKOUT* timing paths
//  10/13/25 - ASIC synthesizable.
//  End Revision:
///////////////////////////////////////////////////////////////////////////////

module MMCME2_DUMMY #(
  parameter BANDWIDTH = "OPTIMIZED",
  parameter COMPENSATION = "ZHOLD",
  
  parameter integer CLKFBOUT_MULT_F = 5,
  parameter real CLKFBOUT_PHASE = 0.000,
  parameter CLKFBOUT_USE_FINE_PS = "FALSE",
  
  parameter real CLKIN1_PERIOD = 0.000,
  parameter real CLKIN2_PERIOD = 0.000,
  parameter integer DIVCLK_DIVIDE = 1,
  
  parameter integer CLKOUT0_DIVIDE_F = 1,
  parameter real CLKOUT0_DUTY_CYCLE = 0.500,
  parameter real CLKOUT0_PHASE = 0.000,
  parameter CLKOUT0_USE_FINE_PS = "FALSE",
  
  parameter integer CLKOUT1_DIVIDE = 1,
  parameter real CLKOUT1_DUTY_CYCLE = 0.500,
  parameter real CLKOUT1_PHASE = 0.000,
  parameter CLKOUT1_USE_FINE_PS = "FALSE",
  
  parameter integer CLKOUT2_DIVIDE = 1,
  parameter real CLKOUT2_DUTY_CYCLE = 0.500,
  parameter real CLKOUT2_PHASE = 0.000,
  parameter CLKOUT2_USE_FINE_PS = "FALSE",
  
  parameter integer CLKOUT3_DIVIDE = 1,
  parameter real CLKOUT3_DUTY_CYCLE = 0.500,
  parameter real CLKOUT3_PHASE = 0.000,
  parameter CLKOUT3_USE_FINE_PS = "FALSE",
  
  parameter CLKOUT4_CASCADE = "FALSE",
  parameter integer CLKOUT4_DIVIDE = 1,
  parameter real CLKOUT4_DUTY_CYCLE = 0.500,
  parameter real CLKOUT4_PHASE = 0.000,
  parameter CLKOUT4_USE_FINE_PS = "FALSE",
  
  parameter integer CLKOUT5_DIVIDE = 1,
  parameter real CLKOUT5_DUTY_CYCLE = 0.500,
  parameter real CLKOUT5_PHASE = 0.000,
  parameter CLKOUT5_USE_FINE_PS = "FALSE",
  
  parameter integer CLKOUT6_DIVIDE = 1,
  parameter real CLKOUT6_DUTY_CYCLE = 0.500,
  parameter real CLKOUT6_PHASE = 0.000,
  parameter CLKOUT6_USE_FINE_PS = "FALSE",
  
  parameter [0:0] IS_CLKFBIN_INVERTED = 1'b0,
  parameter [0:0] IS_CLKIN1_INVERTED = 1'b0,
  parameter [0:0] IS_CLKIN2_INVERTED = 1'b0,
  parameter [0:0] IS_CLKINSEL_INVERTED = 1'b0,
  parameter [0:0] IS_PSEN_INVERTED = 1'b0,
  parameter [0:0] IS_PSINCDEC_INVERTED = 1'b0,
  parameter [0:0] IS_PWRDWN_INVERTED = 1'b0,
  parameter [0:0] IS_RST_INVERTED = 1'b0,
  
  parameter real REF_JITTER1 = 0.010,
  parameter real REF_JITTER2 = 0.010,
  parameter SS_EN = "FALSE",
  parameter SS_MODE = "CENTER_HIGH",
  parameter integer SS_MOD_PERIOD = 10000,
  parameter STARTUP_WAIT = "FALSE"
)(
  output CLKFBOUT,
  output CLKFBOUTB,
  output CLKFBSTOPPED,
  output CLKINSTOPPED,
  output CLKOUT0,
  output CLKOUT0B,
  output CLKOUT1,
  output CLKOUT1B,
  output CLKOUT2,
  output CLKOUT2B,
  output CLKOUT3,
  output CLKOUT3B,
  output CLKOUT4,
  output CLKOUT5,
  output CLKOUT6,
  
  output [15:0] DO,
  output DRDY,
  
  output LOCKED,
  output PSDONE,

  input CLKFBIN,
  input CLKIN1,
  input CLKIN2,
  input CLKINSEL,
  
  input [6:0] DADDR,
  input DCLK,
  input DEN,
  input [15:0] DI,
  input DWE,
  
  input PSCLK,
  input PSEN,
  input PSINCDEC,
  
  input PWRDWN,
  input RST
);


  localparam real VCO_MIN_FREQ = 600.0;
  localparam real VCO_MAX_FREQ = 1600.0;
  localparam integer LOCK_CYCLES = 10;
  
  wire clkin_sel;
  wire clkin_int;
  wire clkfb_int;
  wire reset_int;
  wire pwrdwn_int;
  
  reg vco_clk;
  reg vco_enable;
  
  reg pll_locked_int;
  reg [7:0] lock_counter;
  reg [15:0] drp_do_reg;
  reg drp_ready_reg;
  reg ps_done_reg;
  
  reg [15:0] clk0_count, clk1_count, clk2_count, clk3_count;
  reg [15:0] clk4_count, clk5_count, clk6_count, clkfb_count;
  
  reg clkout0_int, clkout1_int, clkout2_int, clkout3_int;
  reg clkout4_int, clkout5_int, clkout6_int, clkfbout_int;
  
  reg clkinstopped_int;
  reg clkfbstopped_int;

  wire clkin1_buf, clkin2_buf, clkfbin_buf, rst_buf, pwrdwn_buf, clkinsel_buf;
  wire dclk_buf, den_buf, dwe_buf, psclk_buf, psen_buf, psincdec_buf;
  wire [6:0] daddr_buf;
  wire [15:0] di_buf;
  
  `ifdef USE_ASAP7_CELLS
    BUFx2_ASAP7_75t_R u_clkin1_buf (.A(CLKIN1), .Y(clkin1_buf));
    BUFx2_ASAP7_75t_R u_clkin2_buf (.A(CLKIN2), .Y(clkin2_buf));
    BUFx2_ASAP7_75t_R u_clkfbin_buf (.A(CLKFBIN), .Y(clkfbin_buf));
    
    BUFx2_ASAP7_75t_R u_rst_buf (.A(RST), .Y(rst_buf));
    BUFx2_ASAP7_75t_R u_pwrdwn_buf (.A(PWRDWN), .Y(pwrdwn_buf));
    BUFx2_ASAP7_75t_R u_clkinsel_buf (.A(CLKINSEL), .Y(clkinsel_buf));
    
    BUFx2_ASAP7_75t_R u_dclk_buf (.A(DCLK), .Y(dclk_buf));
    BUFx2_ASAP7_75t_R u_den_buf (.A(DEN), .Y(den_buf));
    BUFx2_ASAP7_75t_R u_dwe_buf (.A(DWE), .Y(dwe_buf));
    
    BUFx2_ASAP7_75t_R u_psclk_buf (.A(PSCLK), .Y(psclk_buf));
    BUFx2_ASAP7_75t_R u_psen_buf (.A(PSEN), .Y(psen_buf));
    BUFx2_ASAP7_75t_R u_psincdec_buf (.A(PSINCDEC), .Y(psincdec_buf));
  `elsif USE_NANGATE45_CELLS
    CLKBUF_X1 u_clkin1_buf (.A(CLKIN1), .Z(clkin1_buf));
    CLKBUF_X1 u_clkin2_buf (.A(CLKIN2), .Z(clkin2_buf));
    CLKBUF_X1 u_clkfbin_buf (.A(CLKFBIN), .Z(clkfbin_buf));
    
    BUF_X1 u_rst_buf (.A(RST), .Z(rst_buf));
    BUF_X1 u_pwrdwn_buf (.A(PWRDWN), .Z(pwrdwn_buf));
    BUF_X1 u_clkinsel_buf (.A(CLKINSEL), .Z(clkinsel_buf));
    
    BUF_X1 u_dclk_buf (.A(DCLK), .Z(dclk_buf));
    BUF_X1 u_den_buf (.A(DEN), .Z(den_buf));
    BUF_X1 u_dwe_buf (.A(DWE), .Z(dwe_buf));
    
    BUF_X1 u_psclk_buf (.A(PSCLK), .Z(psclk_buf));
    BUF_X1 u_psen_buf (.A(PSEN), .Z(psen_buf));
    BUF_X1 u_psincdec_buf (.A(PSINCDEC), .Z(psincdec_buf));
  `elsif USE_SKY130HD_CELLS
    sky130_fd_sc_hd__clkbuf_1 u_clkin1_buf (.A(CLKIN1), .X(clkin1_buf));
    sky130_fd_sc_hd__clkbuf_1 u_clkin2_buf (.A(CLKIN2), .X(clkin2_buf));
    sky130_fd_sc_hd__clkbuf_1 u_clkfbin_buf (.A(CLKFBIN), .X(clkfbin_buf));
    
    sky130_fd_sc_hd__buf_1 u_rst_buf (.A(RST), .X(rst_buf));
    sky130_fd_sc_hd__buf_1 u_pwrdwn_buf (.A(PWRDWN), .X(pwrdwn_buf));
    sky130_fd_sc_hd__buf_1 u_clkinsel_buf (.A(CLKINSEL), .X(clkinsel_buf));
    
    sky130_fd_sc_hd__buf_1 u_dclk_buf (.A(DCLK), .X(dclk_buf));
    sky130_fd_sc_hd__buf_1 u_den_buf (.A(DEN), .X(den_buf));
    sky130_fd_sc_hd__buf_1 u_dwe_buf (.A(DWE), .X(dwe_buf));
    
    sky130_fd_sc_hd__buf_1 u_psclk_buf (.A(PSCLK), .X(psclk_buf));
    sky130_fd_sc_hd__buf_1 u_psen_buf (.A(PSEN), .X(psen_buf));
    sky130_fd_sc_hd__buf_1 u_psincdec_buf (.A(PSINCDEC), .X(psincdec_buf));
`elsif USE_GT2N_CELLS
    gt2_6t_buf_x2_w31_svt u_clkin1_buf (.A(CLKIN1), .Y(clkin1_buf));
    gt2_6t_buf_x2_w31_svt u_clkin2_buf (.A(CLKIN2), .Y(clkin2_buf));
    gt2_6t_buf_x2_w31_svt u_clkfbin_buf (.A(CLKFBIN), .Y(clkfbin_buf));
    gt2_6t_buf_x2_w31_svt u_rst_buf (.A(RST), .Y(rst_buf));
    gt2_6t_buf_x2_w31_svt u_pwrdwn_buf (.A(PWRDWN), .Y(pwrdwn_buf));
    gt2_6t_buf_x2_w31_svt u_clkinsel_buf (.A(CLKINSEL), .Y(clkinsel_buf));
    gt2_6t_buf_x2_w31_svt u_dclk_buf (.A(DCLK), .Y(dclk_buf));
    gt2_6t_buf_x2_w31_svt u_den_buf (.A(DEN), .Y(den_buf));
    gt2_6t_buf_x2_w31_svt u_dwe_buf (.A(DWE), .Y(dwe_buf));
    gt2_6t_buf_x2_w31_svt u_psclk_buf (.A(PSCLK), .Y(psclk_buf));
    gt2_6t_buf_x2_w31_svt u_psen_buf (.A(PSEN), .Y(psen_buf));
    gt2_6t_buf_x2_w31_svt u_psincdec_buf (.A(PSINCDEC), .Y(psincdec_buf));
  `endif
  
  genvar j;
  generate
    for (j = 0; j < 7; j = j + 1) begin : gen_daddr_buf
      `ifdef USE_ASAP7_CELLS
        BUFx2_ASAP7_75t_R u_daddr_buf (.A(DADDR[j]), .Y(daddr_buf[j]));
      `elsif USE_NANGATE45_CELLS
        BUF_X1 u_daddr_buf (.A(DADDR[j]), .Z(daddr_buf[j]));
      `elsif USE_SKY130HD_CELLS
        sky130_fd_sc_hd__buf_1 u_daddr_buf (.A(DADDR[j]), .X(daddr_buf[j]));
`elsif USE_GT2N_CELLS
        gt2_6t_buf_x2_w31_svt u_daddr_buf (.A(DADDR[j]), .Y(daddr_buf[j]));
      `endif
    end
    for (j = 0; j < 16; j = j + 1) begin : gen_di_buf
      `ifdef USE_ASAP7_CELLS
        BUFx2_ASAP7_75t_R u_di_buf (.A(DI[j]), .Y(di_buf[j]));
      `elsif USE_NANGATE45_CELLS
        BUF_X1 u_di_buf (.A(DI[j]), .Z(di_buf[j]));
      `elsif USE_SKY130HD_CELLS
        sky130_fd_sc_hd__buf_1 u_di_buf (.A(DI[j]), .X(di_buf[j]));
`elsif USE_GT2N_CELLS
        gt2_6t_buf_x2_w31_svt u_di_buf (.A(DI[j]), .Y(di_buf[j]));
      `endif
    end
  endgenerate
  
  assign clkin_sel = clkinsel_buf ^ IS_CLKINSEL_INVERTED;
  assign clkin_int = clkin_sel ? (clkin2_buf ^ IS_CLKIN2_INVERTED) : 
                                (clkin1_buf ^ IS_CLKIN1_INVERTED);
  assign clkfb_int = clkfbin_buf ^ IS_CLKFBIN_INVERTED;
  assign reset_int = rst_buf ^ IS_RST_INVERTED;
  assign pwrdwn_int = pwrdwn_buf ^ IS_PWRDWN_INVERTED;
  
  `ifdef USE_ASAP7_CELLS
    BUFx2_ASAP7_75t_R u_vco_buf (.A(clkin_int), .Y(vco_clk));
  `elsif USE_NANGATE45_CELLS
    CLKBUF_X1 u_vco_buf (.A(clkin_int), .Z(vco_clk));
  `elsif USE_SKY130HD_CELLS
    sky130_fd_sc_hd__clkbuf_1 u_vco_buf (.A(clkin_int), .X(vco_clk));
`elsif USE_GT2N_CELLS
    gt2_6t_buf_x2_w31_svt u_vco_buf (.A(clkin_int), .Y(vco_clk));
  `endif  

  always @(*) begin
    vco_enable = !reset_int && !pwrdwn_int && clkin_int;
  end
  
  always @(posedge clkin_int or posedge reset_int) begin
    if (reset_int) begin
      lock_counter <= 8'h00;
      pll_locked_int <= 1'b0;
    end else if (pwrdwn_int) begin
      lock_counter <= 8'h00;
      pll_locked_int <= 1'b0;
    end else if (vco_enable) begin
      if (lock_counter < LOCK_CYCLES) begin
        lock_counter <= lock_counter + 1'b1;
        pll_locked_int <= 1'b0;
      end else begin
        pll_locked_int <= 1'b1;
      end
    end
  end

  always @(posedge vco_clk or posedge reset_int) begin
    if (reset_int) begin
      clk0_count <= 16'h0000;
      clkout0_int <= 1'b0;
    end else if (!pll_locked_int) begin
      clk0_count <= 16'h0000;
      clkout0_int <= 1'b0;
    end else begin
      if (clk0_count >= (CLKOUT0_DIVIDE_F - 1)) begin
        clk0_count <= 16'h0000;
        clkout0_int <= ~clkout0_int;
      end else begin
        clk0_count <= clk0_count + 1'b1;
      end
    end
  end
  
  always @(posedge vco_clk or posedge reset_int) begin
    if (reset_int) begin
      clk1_count <= 16'h0000;
      clkout1_int <= 1'b0;
    end else if (!pll_locked_int) begin
      clk1_count <= 16'h0000;
      clkout1_int <= 1'b0;
    end else begin
      if (clk1_count >= (CLKOUT1_DIVIDE - 1)) begin
        clk1_count <= 16'h0000;
        clkout1_int <= ~clkout1_int;
      end else begin
        clk1_count <= clk1_count + 1'b1;
      end
    end
  end
  
  always @(posedge vco_clk or posedge reset_int) begin
    if (reset_int) begin
      clk2_count <= 16'h0000;
      clkout2_int <= 1'b0;
    end else if (!pll_locked_int) begin
      clk2_count <= 16'h0000;
      clkout2_int <= 1'b0;
    end else begin
      if (clk2_count >= (CLKOUT2_DIVIDE - 1)) begin
        clk2_count <= 16'h0000;
        clkout2_int <= ~clkout2_int;
      end else begin
        clk2_count <= clk2_count + 1'b1;
      end
    end
  end
  
  always @(posedge vco_clk or posedge reset_int) begin
    if (reset_int) begin
      clk3_count <= 16'h0000;
      clkout3_int <= 1'b0;
    end else if (!pll_locked_int) begin
      clk3_count <= 16'h0000;
      clkout3_int <= 1'b0;
    end else begin
      if (clk3_count >= (CLKOUT3_DIVIDE - 1)) begin
        clk3_count <= 16'h0000;
        clkout3_int <= ~clkout3_int;
      end else begin
        clk3_count <= clk3_count + 1'b1;
      end
    end
  end
  
  always @(posedge vco_clk or posedge reset_int) begin
    if (reset_int) begin
      clk4_count <= 16'h0000;
      clkout4_int <= 1'b0;
    end else if (!pll_locked_int) begin
      clk4_count <= 16'h0000;
      clkout4_int <= 1'b0;
    end else begin
      if (clk4_count >= (CLKOUT4_DIVIDE - 1)) begin
        clk4_count <= 16'h0000;
        clkout4_int <= ~clkout4_int;
      end else begin
        clk4_count <= clk4_count + 1'b1;
      end
    end
  end
  
  always @(posedge vco_clk or posedge reset_int) begin
    if (reset_int) begin
      clk5_count <= 16'h0000;
      clkout5_int <= 1'b0;
    end else if (!pll_locked_int) begin
      clk5_count <= 16'h0000;
      clkout5_int <= 1'b0;
    end else begin
      if (clk5_count >= (CLKOUT5_DIVIDE - 1)) begin
        clk5_count <= 16'h0000;
        clkout5_int <= ~clkout5_int;
      end else begin
        clk5_count <= clk5_count + 1'b1;
      end
    end
  end
  
  always @(posedge vco_clk or posedge reset_int) begin
      if (reset_int) begin
        clk6_count <= 16'h0000;
        clkout6_int <= 1'b0;
      end else if (!pll_locked_int) begin
        clk6_count <= 16'h0000;
        clkout6_int <= 1'b0;
      if (clk6_count >= (CLKOUT6_DIVIDE - 1)) begin
        clk6_count <= 16'h0000;
        clkout6_int <= ~clkout6_int;
      end else begin
        clk6_count <= clk6_count + 1'b1;
      end
    end
  end
  
  always @(posedge vco_clk or posedge reset_int) begin
    if (reset_int) begin
      clkfb_count <= 16'h0000;
      clkfbout_int <= 1'b0;
    end else if (!pll_locked_int) begin
      clkfb_count <= 16'h0000;
      clkfbout_int <= 1'b0;
    end else begin
      clkfbout_int <= vco_clk;
    end
  end

  always @(posedge dclk_buf or posedge reset_int) begin
    if (reset_int) begin
      drp_do_reg <= 16'h0000;
      drp_ready_reg <= 1'b0;
    end else begin
      drp_ready_reg <= 1'b0;
      if (den_buf) begin
        if (dwe_buf) begin
          drp_ready_reg <= 1'b1;
        end else begin
          case (daddr_buf)
            7'h00: drp_do_reg <= {15'h0000, pll_locked_int};
            7'h01: drp_do_reg <= CLKFBOUT_MULT_F[15:0];
            7'h02: drp_do_reg <= DIVCLK_DIVIDE[15:0];
            default: drp_do_reg <= 16'h0000;
          endcase
          drp_ready_reg <= 1'b1;
        end
      end
    end
  end

  always @(posedge psclk_buf or posedge reset_int) begin
    if (reset_int) begin
      ps_done_reg <= 1'b0;
    end else begin
      ps_done_reg <= 1'b0;
      if (psen_buf) begin
        ps_done_reg <= 1'b1;
      end
    end
  end

  always @(*) begin
    clkinstopped_int = !clkin_int;
    clkfbstopped_int = !clkfb_int;
  end

  `ifdef USE_ASAP7_CELLS
    BUFx2_ASAP7_75t_R u_clkfbout_buf (.A(clkfbout_int), .Y(CLKFBOUT));
    BUFx2_ASAP7_75t_R u_clkfboutb_buf (.A(~clkfbout_int), .Y(CLKFBOUTB));
    BUFx2_ASAP7_75t_R u_clkout0_buf (.A(clkout0_int), .Y(CLKOUT0));
    BUFx2_ASAP7_75t_R u_clkout0b_buf (.A(~clkout0_int), .Y(CLKOUT0B));
    BUFx2_ASAP7_75t_R u_clkout1_buf (.A(clkout1_int), .Y(CLKOUT1));
    BUFx2_ASAP7_75t_R u_clkout1b_buf (.A(~clkout1_int), .Y(CLKOUT1B));
    BUFx2_ASAP7_75t_R u_clkout2_buf (.A(clkout2_int), .Y(CLKOUT2));
    BUFx2_ASAP7_75t_R u_clkout2b_buf (.A(~clkout2_int), .Y(CLKOUT2B));
    BUFx2_ASAP7_75t_R u_clkout3_buf (.A(clkout3_int), .Y(CLKOUT3));
    BUFx2_ASAP7_75t_R u_clkout3b_buf (.A(~clkout3_int), .Y(CLKOUT3B));
    BUFx2_ASAP7_75t_R u_clkout4_buf (.A(clkout4_int), .Y(CLKOUT4));
    BUFx2_ASAP7_75t_R u_clkout5_buf (.A(clkout5_int), .Y(CLKOUT5));
    BUFx2_ASAP7_75t_R u_clkout6_buf (.A(clkout6_int), .Y(CLKOUT6));
    
    BUFx2_ASAP7_75t_R u_locked_buf (.A(pll_locked_int), .Y(LOCKED));
    BUFx2_ASAP7_75t_R u_clkinstopped_buf (.A(clkinstopped_int), .Y(CLKINSTOPPED));
    BUFx2_ASAP7_75t_R u_clkfbstopped_buf (.A(clkfbstopped_int), .Y(CLKFBSTOPPED));
    BUFx2_ASAP7_75t_R u_psdone_buf (.A(ps_done_reg), .Y(PSDONE));
    
    BUFx2_ASAP7_75t_R u_drdy_buf (.A(drp_ready_reg), .Y(DRDY));
  `elsif USE_NANGATE45_CELLS
    CLKBUF_X1 u_clkfbout_buf (.A(clkfbout_int), .Z(CLKFBOUT));
    BUF_X1 u_clkfboutb_buf (.A(~clkfbout_int), .Z(CLKFBOUTB));
    CLKBUF_X1 u_clkout0_buf (.A(clkout0_int), .Z(CLKOUT0));
    BUF_X1 u_clkout0b_buf (.A(~clkout0_int), .Z(CLKOUT0B));
    CLKBUF_X1 u_clkout1_buf (.A(clkout1_int), .Z(CLKOUT1));
    BUF_X1 u_clkout1b_buf (.A(~clkout1_int), .Z(CLKOUT1B));
    CLKBUF_X1 u_clkout2_buf (.A(clkout2_int), .Z(CLKOUT2));
    BUF_X1 u_clkout2b_buf (.A(~clkout2_int), .Z(CLKOUT2B));
    CLKBUF_X1 u_clkout3_buf (.A(clkout3_int), .Z(CLKOUT3));
    BUF_X1 u_clkout3b_buf (.A(~clkout3_int), .Z(CLKOUT3B));
    CLKBUF_X1 u_clkout4_buf (.A(clkout4_int), .Z(CLKOUT4));
    CLKBUF_X1 u_clkout5_buf (.A(clkout5_int), .Z(CLKOUT5));
    CLKBUF_X1 u_clkout6_buf (.A(clkout6_int), .Z(CLKOUT6));
    
    BUF_X1 u_locked_buf (.A(pll_locked_int), .Z(LOCKED));
    BUF_X1 u_clkinstopped_buf (.A(clkinstopped_int), .Z(CLKINSTOPPED));
    BUF_X1 u_clkfbstopped_buf (.A(clkfbstopped_int), .Z(CLKFBSTOPPED));
    BUF_X1 u_psdone_buf (.A(ps_done_reg), .Z(PSDONE));
    
    BUF_X1 u_drdy_buf (.A(drp_ready_reg), .Z(DRDY));
  `elsif USE_SKY130HD_CELLS
    sky130_fd_sc_hd__clkbuf_2 u_clkfbout_buf (.A(clkfbout_int), .X(CLKFBOUT));
    sky130_fd_sc_hd__buf_2 u_clkfboutb_buf (.A(~clkfbout_int), .X(CLKFBOUTB));
    sky130_fd_sc_hd__clkbuf_2 u_clkout0_buf (.A(clkout0_int), .X(CLKOUT0));
    sky130_fd_sc_hd__buf_2 u_clkout0b_buf (.A(~clkout0_int), .X(CLKOUT0B));
    sky130_fd_sc_hd__clkbuf_2 u_clkout1_buf (.A(clkout1_int), .X(CLKOUT1));
    sky130_fd_sc_hd__buf_2 u_clkout1b_buf (.A(~clkout1_int), .X(CLKOUT1B));
    sky130_fd_sc_hd__clkbuf_1 u_clkout2_buf (.A(clkout2_int), .X(CLKOUT2));
    sky130_fd_sc_hd__buf_1 u_clkout2b_buf (.A(~clkout2_int), .X(CLKOUT2B));
    sky130_fd_sc_hd__clkbuf_1 u_clkout3_buf (.A(clkout3_int), .X(CLKOUT3));
    sky130_fd_sc_hd__buf_1 u_clkout3b_buf (.A(~clkout3_int), .X(CLKOUT3B));
    sky130_fd_sc_hd__buf_1 u_clkout4_buf (.A(clkout4_int), .X(CLKOUT4));
    sky130_fd_sc_hd__buf_1 u_clkout5_buf (.A(clkout5_int), .X(CLKOUT5));
    sky130_fd_sc_hd__buf_1 u_clkout6_buf (.A(clkout6_int), .X(CLKOUT6));
    
    sky130_fd_sc_hd__buf_2 u_locked_buf (.A(pll_locked_int), .X(LOCKED));
    sky130_fd_sc_hd__buf_1 u_clkinstopped_buf (.A(clkinstopped_int), .X(CLKINSTOPPED));
    sky130_fd_sc_hd__buf_1 u_clkfbstopped_buf (.A(clkfbstopped_int), .X(CLKFBSTOPPED));
    sky130_fd_sc_hd__buf_1 u_psdone_buf (.A(ps_done_reg), .X(PSDONE));
    
    sky130_fd_sc_hd__buf_1 u_drdy_buf (.A(drp_ready_reg), .X(DRDY));
`elsif USE_GT2N_CELLS
    gt2_6t_buf_x2_w31_svt u_clkfbout_buf (.A(clkfbout_int), .Y(CLKFBOUT));
    gt2_6t_buf_x2_w31_svt u_clkfboutb_buf (.A(~clkfbout_int), .Y(CLKFBOUTB));
    gt2_6t_buf_x2_w31_svt u_clkout0_buf (.A(clkout0_int), .Y(CLKOUT0));
    gt2_6t_buf_x2_w31_svt u_clkout0b_buf (.A(~clkout0_int), .Y(CLKOUT0B));
    gt2_6t_buf_x2_w31_svt u_clkout1_buf (.A(clkout1_int), .Y(CLKOUT1));
    gt2_6t_buf_x2_w31_svt u_clkout1b_buf (.A(~clkout1_int), .Y(CLKOUT1B));
    gt2_6t_buf_x2_w31_svt u_clkout2_buf (.A(clkout2_int), .Y(CLKOUT2));
    gt2_6t_buf_x2_w31_svt u_clkout2b_buf (.A(~clkout2_int), .Y(CLKOUT2B));
    gt2_6t_buf_x2_w31_svt u_clkout3_buf (.A(clkout3_int), .Y(CLKOUT3));
    gt2_6t_buf_x2_w31_svt u_clkout3b_buf (.A(~clkout3_int), .Y(CLKOUT3B));
    gt2_6t_buf_x2_w31_svt u_clkout4_buf (.A(clkout4_int), .Y(CLKOUT4));
    gt2_6t_buf_x2_w31_svt u_clkout5_buf (.A(clkout5_int), .Y(CLKOUT5));
    gt2_6t_buf_x2_w31_svt u_clkout6_buf (.A(clkout6_int), .Y(CLKOUT6));
    gt2_6t_buf_x2_w31_svt u_locked_buf (.A(pll_locked_int), .Y(LOCKED));
    gt2_6t_buf_x2_w31_svt u_clkinstopped_buf (.A(clkinstopped_int), .Y(CLKINSTOPPED));
    gt2_6t_buf_x2_w31_svt u_clkfbstopped_buf (.A(clkfbstopped_int), .Y(CLKFBSTOPPED));
    gt2_6t_buf_x2_w31_svt u_psdone_buf (.A(ps_done_reg), .Y(PSDONE));
    gt2_6t_buf_x2_w31_svt u_drdy_buf (.A(drp_ready_reg), .Y(DRDY));
  `endif
    
  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_do_buf
      `ifdef USE_ASAP7_CELLS
        BUFx2_ASAP7_75t_R u_do_buf (.A(drp_do_reg[i]), .Y(DO[i]));
      `elsif USE_NANGATE45_CELLS
        BUF_X1 u_do_buf (.A(drp_do_reg[i]), .Z(DO[i]));
      `elsif USE_SKY130HD_CELLS
        sky130_fd_sc_hd__buf_1 u_do_buf (.A(drp_do_reg[i]), .X(DO[i]));
`elsif USE_GT2N_CELLS
        gt2_6t_buf_x2_w31_svt u_do_buf (.A(drp_do_reg[i]), .Y(DO[i]));
      `endif
    end
  endgenerate

endmodule
