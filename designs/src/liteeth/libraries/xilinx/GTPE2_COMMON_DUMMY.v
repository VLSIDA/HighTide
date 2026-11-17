///////////////////////////////////////////////////////
//     Copyright (c) 2011 Xilinx Inc.
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
///////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \  \    \/      Version     :  13.1
//  \  \           Description : 
//  /  /                      
// /__/   /\       Filename    : GTPE2_COMMON.uniprim.v
// \  \  /  \ 
//  \__\/\__ \                    
//                                 
//  Revision:		1.0
//  11/8/12  - 686589 - YML default changes
//  01/18/13 - 695630 - added drp monitor
//  08/29/14 - 821138 - add negedge specify section for IS_INVERTED*CLK*
//  10/13/25 - ASIC synthesizable.
//  End Revision:
///////////////////////////////////////////////////////

module GTPE2_COMMON_DUMMY (
  output wire        PLL0OUTCLK,
  output wire        PLL0OUTREFCLK,
  output wire        PLL1OUTCLK,
  output wire        PLL1OUTREFCLK,
  output wire        REFCLKOUTMONITOR0,
  output wire        REFCLKOUTMONITOR1,
  
  output wire        PLL0LOCK,
  output wire        PLL1LOCK,
  output wire        PLL0FBCLKLOST,
  output wire        PLL1FBCLKLOST,
  output wire        PLL0REFCLKLOST,
  output wire        PLL1REFCLKLOST,
  
  output wire        DRPRDY,
  output wire [15:0] DRPDO,
  
  output wire [7:0]  DMONITOROUT,
  output wire [15:0] PMARSVDOUT,

  input wire         GTREFCLK0,
  input wire         GTREFCLK1,
  input wire         GTGREFCLK0,
  input wire         GTGREFCLK1,
  input wire         GTEASTREFCLK0,
  input wire         GTEASTREFCLK1,
  input wire         GTWESTREFCLK0,
  input wire         GTWESTREFCLK1,
  
  input wire         PLL0RESET,
  input wire         PLL0PD,
  input wire         PLL0LOCKEN,
  input wire         PLL0LOCKDETCLK,
  input wire [2:0]   PLL0REFCLKSEL,
  
  input wire         PLL1RESET,
  input wire         PLL1PD,
  input wire         PLL1LOCKEN,
  input wire         PLL1LOCKDETCLK,
  input wire [2:0]   PLL1REFCLKSEL,
  
  input wire         DRPCLK,
  input wire         DRPEN,
  input wire         DRPWE,
  input wire [7:0]   DRPADDR,
  input wire [15:0]  DRPDI,
  
  input wire         BGBYPASSB,
  input wire         BGMONITORENB,
  input wire         BGPDB,
  input wire         BGRCALOVRDENB,
  input wire [4:0]   BGRCALOVRD,
  input wire [15:0]  PLLRSVD1,
  input wire [4:0]   PLLRSVD2,
  input wire [7:0]   PMARSVD,
  input wire         RCALENB
);

  parameter integer PLL0_FBDIV = 4;
  parameter integer PLL0_FBDIV_45 = 5;
  parameter integer PLL0_REFCLK_DIV = 1;
  parameter integer PLL1_FBDIV = 4;
  parameter integer PLL1_FBDIV_45 = 5;
  parameter integer PLL1_REFCLK_DIV = 1;
  parameter [2:0]   SIM_PLL0REFCLK_SEL = 3'b001;
  parameter [2:0]   SIM_PLL1REFCLK_SEL = 3'b001;
  parameter         SIM_RESET_SPEEDUP = "TRUE";

  wire pll0_refclk_selected;
  wire pll1_refclk_selected;
  wire pll0_reset_int;
  wire pll1_reset_int;
  wire pll0_enable;
  wire pll1_enable;
  
  reg pll0_locked_reg;
  reg pll1_locked_reg;
  reg pll0_fbclklost_reg;
  reg pll1_fbclklost_reg;
  reg pll0_refclklost_reg;
  reg pll1_refclklost_reg;
  
  reg drprdy_reg;
  reg [15:0] drpdo_reg;
  
  reg pll0_outclk_reg;
  reg pll0_outrefclk_reg;
  reg pll1_outclk_reg;
  reg pll1_outrefclk_reg;
  reg refclkoutmonitor0_reg;
  reg refclkoutmonitor1_reg;
  
  reg [7:0] dmonitorout_reg;
  reg [15:0] pmarsvdout_reg;

  reg pll0_refclk_mux;
  always @(*) begin
    case (PLL0REFCLKSEL)
      3'b000: pll0_refclk_mux = GTREFCLK0;
      3'b001: pll0_refclk_mux = GTREFCLK1;
      3'b010: pll0_refclk_mux = GTGREFCLK0;
      3'b011: pll0_refclk_mux = GTGREFCLK1;
      3'b100: pll0_refclk_mux = GTEASTREFCLK0;
      3'b101: pll0_refclk_mux = GTEASTREFCLK1;
      3'b110: pll0_refclk_mux = GTWESTREFCLK0;
      3'b111: pll0_refclk_mux = GTWESTREFCLK1;
    endcase
  end
  
`ifdef USE_ASAP7_CELLS
  BUFx2_ASAP7_75t_R u_pll0_refclk_buf (.A(pll0_refclk_mux), .Y(pll0_refclk_selected));
`elsif USE_NANGATE45_CELLS
  CLKBUF_X1 u_pll0_refclk_buf (.A(pll0_refclk_mux), .Z(pll0_refclk_selected));
`elsif USE_SKY130HD_CELLS
  sky130_fd_sc_hd__clkbuf_1 u_pll0_refclk_buf (.A(pll0_refclk_mux), .X(pll0_refclk_selected));
`elsif USE_GT2N_CELLS
  gt2_6t_buf_x2_w31_svt u_pll0_refclk_buf (.A(pll0_refclk_mux), .Y(pll0_refclk_selected));
`endif

  reg pll1_refclk_mux;
  always @(*) begin
    case (PLL1REFCLKSEL)
      3'b000: pll1_refclk_mux = GTREFCLK0;
      3'b001: pll1_refclk_mux = GTREFCLK1;
      3'b010: pll1_refclk_mux = GTGREFCLK0;
      3'b011: pll1_refclk_mux = GTGREFCLK1;
      3'b100: pll1_refclk_mux = GTEASTREFCLK0;
      3'b101: pll1_refclk_mux = GTEASTREFCLK1;
      3'b110: pll1_refclk_mux = GTWESTREFCLK0;
      3'b111: pll1_refclk_mux = GTWESTREFCLK1;
    endcase
  end
  
`ifdef USE_ASAP7_CELLS
  BUFx2_ASAP7_75t_R u_pll1_refclk_buf (.A(pll1_refclk_mux), .Y(pll1_refclk_selected));
`elsif USE_NANGATE45_CELLS
  CLKBUF_X1 u_pll1_refclk_buf (.A(pll1_refclk_mux), .Z(pll1_refclk_selected));
`elsif USE_SKY130HD_CELLS
  sky130_fd_sc_hd__clkbuf_1 u_pll1_refclk_buf (.A(pll1_refclk_mux), .X(pll1_refclk_selected));
`elsif USE_GT2N_CELLS
  gt2_6t_buf_x2_w31_svt u_pll1_refclk_buf (.A(pll1_refclk_mux), .Y(pll1_refclk_selected));
`endif

`ifdef USE_ASAP7_CELLS
  BUFx2_ASAP7_75t_R u_pll0_reset_buf (.A(PLL0RESET), .Y(pll0_reset_int));
`elsif USE_NANGATE45_CELLS
  BUF_X1 u_pll0_reset_buf (.A(PLL0RESET), .Z(pll0_reset_int));
`elsif USE_SKY130HD_CELLS
  sky130_fd_sc_hd__buf_1 u_pll0_reset_buf (.A(PLL0RESET), .X(pll0_reset_int));
`elsif USE_GT2N_CELLS
  gt2_6t_buf_x2_w31_svt u_pll0_reset_buf (.A(PLL0RESET), .Y(pll0_reset_int));
`endif
  wire pll0_pd_int;
`ifdef USE_ASAP7_CELLS
  BUFx2_ASAP7_75t_R u_pll0_pd_buf (.A(PLL0PD), .Y(pll0_pd_int));
`elsif USE_NANGATE45_CELLS
  BUF_X1 u_pll0_pd_buf (.A(PLL0PD), .Z(pll0_pd_int));
`elsif USE_SKY130HD_CELLS
  sky130_fd_sc_hd__buf_1 u_pll0_pd_buf (.A(PLL0PD), .X(pll0_pd_int));
`elsif USE_GT2N_CELLS
  gt2_6t_buf_x2_w31_svt u_pll0_pd_buf (.A(PLL0PD), .Y(pll0_pd_int));
`endif
  
  wire pll0_enable_int;
  assign pll0_enable_int = ~(pll0_reset_int | pll0_pd_int);
`ifdef USE_ASAP7_CELLS
  BUFx2_ASAP7_75t_R u_pll0_enable_buf (.A(pll0_enable_int), .Y(pll0_enable));
`elsif USE_NANGATE45_CELLS
  BUF_X1 u_pll0_enable_buf (.A(pll0_enable_int), .Z(pll0_enable));
`elsif USE_SKY130HD_CELLS
  sky130_fd_sc_hd__buf_1 u_pll0_enable_buf (.A(pll0_enable_int), .X(pll0_enable));
`elsif USE_GT2N_CELLS
  gt2_6t_buf_x2_w31_svt u_pll0_enable_buf (.A(pll0_enable_int), .Y(pll0_enable));
`endif

`ifdef USE_ASAP7_CELLS
  BUFx2_ASAP7_75t_R u_pll1_reset_buf (.A(PLL1RESET), .Y(pll1_reset_int));
`elsif USE_NANGATE45_CELLS
  BUF_X1 u_pll1_reset_buf (.A(PLL1RESET), .Z(pll1_reset_int));
`elsif USE_SKY130HD_CELLS
  sky130_fd_sc_hd__buf_1 u_pll1_reset_buf (.A(PLL1RESET), .X(pll1_reset_int));
`elsif USE_GT2N_CELLS
  gt2_6t_buf_x2_w31_svt u_pll1_reset_buf (.A(PLL1RESET), .Y(pll1_reset_int));
`endif
  wire pll1_pd_int;
`ifdef USE_ASAP7_CELLS
  BUFx2_ASAP7_75t_R u_pll1_pd_buf (.A(PLL1PD), .Y(pll1_pd_int));
`elsif USE_NANGATE45_CELLS
  BUF_X1 u_pll1_pd_buf (.A(PLL1PD), .Z(pll1_pd_int));
`elsif USE_SKY130HD_CELLS
  sky130_fd_sc_hd__buf_1 u_pll1_pd_buf (.A(PLL1PD), .X(pll1_pd_int));
`elsif USE_GT2N_CELLS
  gt2_6t_buf_x2_w31_svt u_pll1_pd_buf (.A(PLL1PD), .Y(pll1_pd_int));
`endif
  
  wire pll1_enable_int;
  assign pll1_enable_int = ~(pll1_reset_int | pll1_pd_int);
`ifdef USE_ASAP7_CELLS
  BUFx2_ASAP7_75t_R u_pll1_enable_buf (.A(pll1_enable_int), .Y(pll1_enable));
`elsif USE_NANGATE45_CELLS
  BUF_X1 u_pll1_enable_buf (.A(pll1_enable_int), .Z(pll1_enable));
`elsif USE_SKY130HD_CELLS
  sky130_fd_sc_hd__buf_1 u_pll1_enable_buf (.A(pll1_enable_int), .X(pll1_enable));
`elsif USE_GT2N_CELLS
  gt2_6t_buf_x2_w31_svt u_pll1_enable_buf (.A(pll1_enable_int), .Y(pll1_enable));
`endif

  reg [7:0] pll0_lock_counter;
  localparam PLL0_LOCK_CYCLES = 8'd100;
  
  always @(posedge PLL0LOCKDETCLK or posedge pll0_reset_int) begin
    if (pll0_reset_int) begin
      pll0_lock_counter <= 8'd0;
      pll0_locked_reg <= 1'b0;
      pll0_fbclklost_reg <= 1'b1;
      pll0_refclklost_reg <= 1'b1;
    end else if (pll0_enable && PLL0LOCKEN) begin
      if (pll0_lock_counter < PLL0_LOCK_CYCLES) begin
        pll0_lock_counter <= pll0_lock_counter + 1'b1;
        pll0_fbclklost_reg <= 1'b0;
        pll0_refclklost_reg <= 1'b0;
      end else begin
        pll0_locked_reg <= 1'b1;
      end
    end
  end

  reg [7:0] pll1_lock_counter;
  localparam PLL1_LOCK_CYCLES = 8'd100;
  
  always @(posedge PLL1LOCKDETCLK or posedge pll1_reset_int) begin
    if (pll1_reset_int) begin
      pll1_lock_counter <= 8'd0;
      pll1_locked_reg <= 1'b0;
      pll1_fbclklost_reg <= 1'b1;
      pll1_refclklost_reg <= 1'b1;
    end else if (pll1_enable && PLL1LOCKEN) begin
      if (pll1_lock_counter < PLL1_LOCK_CYCLES) begin
        pll1_lock_counter <= pll1_lock_counter + 1'b1;
        pll1_fbclklost_reg <= 1'b0;
        pll1_refclklost_reg <= 1'b0;
      end else begin
        pll1_locked_reg <= 1'b1;
      end
    end
  end

  reg [31:0] pll0_div_counter;
  wire pll0_feedback_div_tc;
  
  // Simple divider model - in real ASIC would use clock divider cells
  always @(posedge pll0_refclk_selected or posedge pll0_reset_int) begin
    if (pll0_reset_int) begin
      pll0_div_counter <= 32'd0;
      pll0_outclk_reg <= 1'b0;
      pll0_outrefclk_reg <= 1'b0;
    end else if (pll0_enable && pll0_locked_reg) begin
      if (pll0_div_counter >= (PLL0_FBDIV - 1)) begin
        pll0_div_counter <= 32'd0;
        pll0_outclk_reg <= ~pll0_outclk_reg;
      end else begin
        pll0_div_counter <= pll0_div_counter + 1'b1;
      end
      pll0_outrefclk_reg <= pll0_refclk_selected;
    end
  end

  reg [31:0] pll1_div_counter;
  
  always @(posedge pll1_refclk_selected or posedge pll1_reset_int) begin
    if (pll1_reset_int) begin
      pll1_div_counter <= 32'd0;
      pll1_outclk_reg <= 1'b0;
      pll1_outrefclk_reg <= 1'b0;
    end else if (pll1_enable && pll1_locked_reg) begin
      if (pll1_div_counter >= (PLL1_FBDIV - 1)) begin
        pll1_div_counter <= 32'd0;
        pll1_outclk_reg <= ~pll1_outclk_reg;
      end else begin
        pll1_div_counter <= pll1_div_counter + 1'b1;
      end
      pll1_outrefclk_reg <= pll1_refclk_selected;
    end
  end

  always @(posedge GTGREFCLK0) begin
      refclkoutmonitor0_reg <= GTGREFCLK0;
  end

  always @(posedge GTGREFCLK1) begin
      refclkoutmonitor1_reg <= GTGREFCLK1;
  end

  reg drpen_r1, drpen_r2;
  reg drpwe_r1, drpwe_r2;
  reg [1:0] drp_state;
  
  localparam DRP_IDLE = 2'b01;
  localparam DRP_WAIT = 2'b10;
  
  always @(posedge DRPCLK) begin
    drpen_r1 <= DRPEN;
    drpen_r2 <= drpen_r1;
    drpwe_r1 <= DRPWE;
    drpwe_r2 <= drpwe_r1;
    
    case (drp_state)
      DRP_IDLE: begin
        drprdy_reg <= 1'b0;
        if (DRPEN) begin
          drp_state <= DRP_WAIT;
          if (DRPWE) begin

            drprdy_reg <= 1'b1;
          end else begin
            case (DRPADDR[4:0])
              5'h00: drpdo_reg <= {8'h00, PLL0_FBDIV[7:0]};
              5'h01: drpdo_reg <= {8'h00, PLL0_REFCLK_DIV[7:0]};
              5'h02: drpdo_reg <= {8'h00, PLL1_FBDIV[7:0]};
              5'h03: drpdo_reg <= {8'h00, PLL1_REFCLK_DIV[7:0]};
              5'h04: drpdo_reg <= {13'h0000, SIM_PLL0REFCLK_SEL};
              5'h05: drpdo_reg <= {13'h0000, SIM_PLL1REFCLK_SEL};
              5'h06: drpdo_reg <= {pll1_locked_reg, pll0_locked_reg, 14'h0000};
              default: drpdo_reg <= 16'h0000;
            endcase
            drprdy_reg <= 1'b1;
          end
        end
      end
      
      DRP_WAIT: begin
        if (drprdy_reg) begin
          drprdy_reg <= 1'b0;
          drp_state <= DRP_IDLE;
        end
      end
      
      default: drp_state <= DRP_IDLE;
    endcase
  end

  always @(*) begin
    // Simple monitoring data
    dmonitorout_reg = {pll1_locked_reg, pll0_locked_reg, 6'b000000};
    pmarsvdout_reg = {PMARSVD, 8'h00};
  end

`ifdef USE_ASAP7_CELLS
  BUFx2_ASAP7_75t_R u_pll0outclk_buf (.A(pll0_outclk_reg), .Y(PLL0OUTCLK));
  BUFx2_ASAP7_75t_R u_pll0outrefclk_buf (.A(pll0_outrefclk_reg), .Y(PLL0OUTREFCLK));
  BUFx2_ASAP7_75t_R u_pll1outclk_buf (.A(pll1_outclk_reg), .Y(PLL1OUTCLK));
  BUFx2_ASAP7_75t_R u_pll1outrefclk_buf (.A(pll1_outrefclk_reg), .Y(PLL1OUTREFCLK));
  BUFx2_ASAP7_75t_R u_refmon0_buf (.A(refclkoutmonitor0_reg), .Y(REFCLKOUTMONITOR0));
  BUFx2_ASAP7_75t_R u_refmon1_buf (.A(refclkoutmonitor1_reg), .Y(REFCLKOUTMONITOR1));
  
  BUFx2_ASAP7_75t_R u_pll0lock_buf (.A(pll0_locked_reg), .Y(PLL0LOCK));
  BUFx2_ASAP7_75t_R u_pll1lock_buf (.A(pll1_locked_reg), .Y(PLL1LOCK));
  BUFx2_ASAP7_75t_R u_pll0fbclklost_buf (.A(pll0_fbclklost_reg), .Y(PLL0FBCLKLOST));
  BUFx2_ASAP7_75t_R u_pll1fbclklost_buf (.A(pll1_fbclklost_reg), .Y(PLL1FBCLKLOST));
  BUFx2_ASAP7_75t_R u_pll0refclklost_buf (.A(pll0_refclklost_reg), .Y(PLL0REFCLKLOST));
  BUFx2_ASAP7_75t_R u_pll1refclklost_buf (.A(pll1_refclklost_reg), .Y(PLL1REFCLKLOST));
  
  BUFx2_ASAP7_75t_R u_drprdy_buf (.A(drprdy_reg), .Y(DRPRDY));
`elsif USE_NANGATE45_CELLS
  CLKBUF_X1 u_pll0outclk_buf (.A(pll0_outclk_reg), .Z(PLL0OUTCLK));
  CLKBUF_X1 u_pll0outrefclk_buf (.A(pll0_outrefclk_reg), .Z(PLL0OUTREFCLK));
  CLKBUF_X1 u_pll1outclk_buf (.A(pll1_outclk_reg), .Z(PLL1OUTCLK));
  CLKBUF_X1 u_pll1outrefclk_buf (.A(pll1_outrefclk_reg), .Z(PLL1OUTREFCLK));
  CLKBUF_X1 u_refmon0_buf (.A(refclkoutmonitor0_reg), .Z(REFCLKOUTMONITOR0));
  CLKBUF_X1 u_refmon1_buf (.A(refclkoutmonitor1_reg), .Z(REFCLKOUTMONITOR1));
  
  BUF_X1 u_pll0lock_buf (.A(pll0_locked_reg), .Z(PLL0LOCK));
  BUF_X1 u_pll1lock_buf (.A(pll1_locked_reg), .Z(PLL1LOCK));
  BUF_X1 u_pll0fbclklost_buf (.A(pll0_fbclklost_reg), .Z(PLL0FBCLKLOST));
  BUF_X1 u_pll1fbclklost_buf (.A(pll1_fbclklost_reg), .Z(PLL1FBCLKLOST));
  BUF_X1 u_pll0refclklost_buf (.A(pll0_refclklost_reg), .Z(PLL0REFCLKLOST));
  BUF_X1 u_pll1refclklost_buf (.A(pll1_refclklost_reg), .Z(PLL1REFCLKLOST));
  
  BUF_X1 u_drprdy_buf (.A(drprdy_reg), .Z(DRPRDY));
`elsif USE_SKY130HD_CELLS
  sky130_fd_sc_hd__clkbuf_1 u_pll0outclk_buf (.A(pll0_outclk_reg), .X(PLL0OUTCLK));
  sky130_fd_sc_hd__clkbuf_1 u_pll0outrefclk_buf (.A(pll0_outrefclk_reg), .X(PLL0OUTREFCLK));
  sky130_fd_sc_hd__clkbuf_1 u_pll1outclk_buf (.A(pll1_outclk_reg), .X(PLL1OUTCLK));
  sky130_fd_sc_hd__clkbuf_1 u_pll1outrefclk_buf (.A(pll1_outrefclk_reg), .X(PLL1OUTREFCLK));
  sky130_fd_sc_hd__clkbuf_1 u_refmon0_buf (.A(refclkoutmonitor0_reg), .X(REFCLKOUTMONITOR0));
  sky130_fd_sc_hd__clkbuf_1 u_refmon1_buf (.A(refclkoutmonitor1_reg), .X(REFCLKOUTMONITOR1));
  
  sky130_fd_sc_hd__buf_1 u_pll0lock_buf (.A(pll0_locked_reg), .X(PLL0LOCK));
  sky130_fd_sc_hd__buf_1 u_pll1lock_buf (.A(pll1_locked_reg), .X(PLL1LOCK));
  sky130_fd_sc_hd__buf_1 u_pll0fbclklost_buf (.A(pll0_fbclklost_reg), .X(PLL0FBCLKLOST));
  sky130_fd_sc_hd__buf_1 u_pll1fbclklost_buf (.A(pll1_fbclklost_reg), .X(PLL1FBCLKLOST));
  sky130_fd_sc_hd__buf_1 u_pll0refclklost_buf (.A(pll0_refclklost_reg), .X(PLL0REFCLKLOST));
  sky130_fd_sc_hd__buf_1 u_pll1refclklost_buf (.A(pll1_refclklost_reg), .X(PLL1REFCLKLOST));
  
  sky130_fd_sc_hd__buf_1 u_drprdy_buf (.A(drprdy_reg), .X(DRPRDY));
`elsif USE_GT2N_CELLS
  gt2_6t_buf_x2_w31_svt u_pll0outclk_buf (.A(pll0_outclk_reg), .Y(PLL0OUTCLK));
  gt2_6t_buf_x2_w31_svt u_pll0outrefclk_buf (.A(pll0_outrefclk_reg), .Y(PLL0OUTREFCLK));
  gt2_6t_buf_x2_w31_svt u_pll1outclk_buf (.A(pll1_outclk_reg), .Y(PLL1OUTCLK));
  gt2_6t_buf_x2_w31_svt u_pll1outrefclk_buf (.A(pll1_outrefclk_reg), .Y(PLL1OUTREFCLK));
  gt2_6t_buf_x2_w31_svt u_refmon0_buf (.A(refclkoutmonitor0_reg), .Y(REFCLKOUTMONITOR0));
  gt2_6t_buf_x2_w31_svt u_refmon1_buf (.A(refclkoutmonitor1_reg), .Y(REFCLKOUTMONITOR1));
  gt2_6t_buf_x2_w31_svt u_pll0lock_buf (.A(pll0_locked_reg), .Y(PLL0LOCK));
  gt2_6t_buf_x2_w31_svt u_pll1lock_buf (.A(pll1_locked_reg), .Y(PLL1LOCK));
  gt2_6t_buf_x2_w31_svt u_pll0fbclklost_buf (.A(pll0_fbclklost_reg), .Y(PLL0FBCLKLOST));
  gt2_6t_buf_x2_w31_svt u_pll1fbclklost_buf (.A(pll1_fbclklost_reg), .Y(PLL1FBCLKLOST));
  gt2_6t_buf_x2_w31_svt u_pll0refclklost_buf (.A(pll0_refclklost_reg), .Y(PLL0REFCLKLOST));
  gt2_6t_buf_x2_w31_svt u_pll1refclklost_buf (.A(pll1_refclklost_reg), .Y(PLL1REFCLKLOST));
  gt2_6t_buf_x2_w31_svt u_drprdy_buf (.A(drprdy_reg), .Y(DRPRDY));
`endif
  
  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_drpdo_buf
`ifdef USE_ASAP7_CELLS
      BUFx2_ASAP7_75t_R u_drpdo_buf (.A(drpdo_reg[i]), .Y(DRPDO[i]));
`elsif USE_NANGATE45_CELLS
      BUF_X1 u_drpdo_buf (.A(drpdo_reg[i]), .Z(DRPDO[i]));
`elsif USE_SKY130HD_CELLS
      sky130_fd_sc_hd__buf_1 u_drpdo_buf (.A(drpdo_reg[i]), .X(DRPDO[i]));
`elsif USE_GT2N_CELLS
      gt2_6t_buf_x2_w31_svt u_drpdo_buf (.A(drpdo_reg[i]), .Y(DRPDO[i]));
`endif
    end
    
    for (i = 0; i < 8; i = i + 1) begin : gen_dmon_buf
`ifdef USE_ASAP7_CELLS
      BUFx2_ASAP7_75t_R u_dmon_buf (.A(dmonitorout_reg[i]), .Y(DMONITOROUT[i]));
`elsif USE_NANGATE45_CELLS
      BUF_X1 u_dmon_buf (.A(dmonitorout_reg[i]), .Z(DMONITOROUT[i]));
`elsif USE_SKY130HD_CELLS
      sky130_fd_sc_hd__buf_1 u_dmon_buf (.A(dmonitorout_reg[i]), .X(DMONITOROUT[i]));
`elsif USE_GT2N_CELLS
      gt2_6t_buf_x2_w31_svt u_dmon_buf (.A(dmonitorout_reg[i]), .Y(DMONITOROUT[i]));
`endif
    end
    
    for (i = 0; i < 16; i = i + 1) begin : gen_pmarsvd_buf
`ifdef USE_ASAP7_CELLS
      BUFx2_ASAP7_75t_R u_pmarsvd_buf (.A(pmarsvdout_reg[i]), .Y(PMARSVDOUT[i]));
`elsif USE_NANGATE45_CELLS
      BUF_X1 u_pmarsvd_buf (.A(pmarsvdout_reg[i]), .Z(PMARSVDOUT[i]));
`elsif USE_SKY130HD_CELLS
      sky130_fd_sc_hd__buf_1 u_pmarsvd_buf (.A(pmarsvdout_reg[i]), .X(PMARSVDOUT[i]));
`elsif USE_GT2N_CELLS
      gt2_6t_buf_x2_w31_svt u_pmarsvd_buf (.A(pmarsvdout_reg[i]), .Y(PMARSVDOUT[i]));
`endif
    end
  endgenerate

  initial begin
    if (PLL0_FBDIV < 1 || PLL0_FBDIV > 20) begin
      $display("ERROR: PLL0_FBDIV must be between 1 and 20");
      $finish;
    end
    if (PLL1_FBDIV < 1 || PLL1_FBDIV > 20) begin
      $display("ERROR: PLL1_FBDIV must be between 1 and 20");
      $finish;
    end
    if (PLL0_REFCLK_DIV < 1 || PLL0_REFCLK_DIV > 20) begin
      $display("ERROR: PLL0_REFCLK_DIV must be between 1 and 20");
      $finish;
    end
    if (PLL1_REFCLK_DIV < 1 || PLL1_REFCLK_DIV > 20) begin
      $display("ERROR: PLL1_REFCLK_DIV must be between 1 and 20");
      $finish;
    end
  end

endmodule
