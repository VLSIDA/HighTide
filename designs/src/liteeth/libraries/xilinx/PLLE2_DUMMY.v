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
// \   \   \/      Version     : 2017.4
//  \   \          Description : Xilinx Unified Simulation Library Component
//  /   /                        Advanced Phase-Locked Loop (PLL)
// /___/   /\      Filename    : PLLE2_ADV.v
// \   \  /  \
//  \___\/\___\
//
///////////////////////////////////////////////////////////////////////////////
//  Revision:
//  12/09/09 - Initial version.
//  03/24/10 - Change CLKFBOUT_MULT defaut to 5, CLKIN_PERIOD range.
//  04/28/10 - Fix CLKIN1_PERIOD check (CR557962)
//  06/03/10 - Change DIVCLK_DIVIDE range to 56 according yaml.
//  07/12/10 - Add RST to LOCKED iopath (CR567807)
//  07/28/10 - Change ref parameter values (CR569262)
//  08/06/10 - Remove CASCADE from COMPENSATION (CR571190)
//  08/17/10 - Add Decay output clocks when input clock stopped (CR555324)
//  09/03/10 - Change to bus timing.
//  09/26/10 - Add RST to LOCKED timing path (CR567807)
//  02/22/11 - reduce clkin period check resolution to 0.001 (CR594003)
//  03/03/11 - Keep 100ps dealy only on RST to LOCKED for unisim (CR595354)
//  05/05/11 - Update cp_res table (CR609232)
//  10/26/11 - Add DRC check for samples CLKIN period with parameter setting (CR631150)
//  12/13/11 - Added `celldefine and `endcelldefine (CR 524859).
//  02/22/12 - Modify DRC (638094).
//  03/07/12 - added vcoflag (CR 638088, CR 636493)
//  04/19/12 - 654951 - rounding issue with clk_out_para_cal
//  05/03/12 - jittery clock (CR 652401)
//  05/03/12 - incorrect period (CR 654951)
//  06/11/12 - update cp and res settings (CR 664278)
//  06/20/12 - modify reset drc (CR 643540)
//  04/04/13 - change error to warning (CR 708090)
//  04/09/13 - Added DRP monitor (CR 695630).
//  10/22/2014 808642 - Added #1 to $finish
//  10/13/25 - ASIC synthesizable.
//  End Revision:
///////////////////////////////////////////////////////////////////////////////

module PLLE2_DUMMY #(
  parameter BANDWIDTH = "OPTIMIZED",
  parameter integer CLKFBOUT_MULT = 5,
  parameter real CLKFBOUT_PHASE = 0.000,
  parameter real CLKIN1_PERIOD = 0.000,
  parameter real CLKIN2_PERIOD = 0.000,
  
  parameter integer CLKOUT0_DIVIDE = 1,
  parameter real CLKOUT0_DUTY_CYCLE = 0.500,
  parameter real CLKOUT0_PHASE = 0.000,
  parameter integer CLKOUT1_DIVIDE = 1,
  parameter real CLKOUT1_DUTY_CYCLE = 0.500,
  parameter real CLKOUT1_PHASE = 0.000,
  parameter integer CLKOUT2_DIVIDE = 1,
  parameter real CLKOUT2_DUTY_CYCLE = 0.500,
  parameter real CLKOUT2_PHASE = 0.000,
  parameter integer CLKOUT3_DIVIDE = 1,
  parameter real CLKOUT3_DUTY_CYCLE = 0.500,
  parameter real CLKOUT3_PHASE = 0.000,
  parameter integer CLKOUT4_DIVIDE = 1,
  parameter real CLKOUT4_DUTY_CYCLE = 0.500,
  parameter real CLKOUT4_PHASE = 0.000,
  parameter integer CLKOUT5_DIVIDE = 1,
  parameter real CLKOUT5_DUTY_CYCLE = 0.500,
  parameter real CLKOUT5_PHASE = 0.000,
  
  parameter COMPENSATION = "ZHOLD",
  parameter integer DIVCLK_DIVIDE = 1,
  parameter [0:0] IS_CLKINSEL_INVERTED = 1'b0,
  parameter [0:0] IS_PWRDWN_INVERTED = 1'b0,
  parameter [0:0] IS_RST_INVERTED = 1'b0,
  parameter real REF_JITTER1 = 0.010,
  parameter real REF_JITTER2 = 0.010,
  parameter STARTUP_WAIT = "FALSE"
)(
  output CLKFBOUT,
  output CLKOUT0,
  output CLKOUT1,
  output CLKOUT2,
  output CLKOUT3,
  output CLKOUT4,
  output CLKOUT5,
  
  output [15:0] DO,
  output DRDY,
  
  output LOCKED,
  
  input CLKFBIN,
  input CLKIN1,
  input CLKIN2,
  input CLKINSEL,
  
  input [6:0] DADDR,
  input DCLK,
  input DEN,
  input [15:0] DI,
  input DWE,
  
  input PWRDWN,
  input RST
);

  wire clkin_int;
  wire rst_int;
  wire pwrdwn_int;
  wire clkfb_int;
  
  reg pll_locked_reg;
  reg [15:0] do_reg;
  reg drdy_reg;
  
  wire vco_clk;
  reg [31:0] clk_counters [0:5];
  reg [31:0] clk_phases [0:5];
  
  wire reset_active;
  wire pll_enable;
  
  wire clkinsel_buf;
  `ifdef USE_ASAP7_CELLS
    BUFx2_ASAP7_75t_R u_clkinsel_buf (.A(CLKINSEL), .Y(clkinsel_buf));
  `elsif USE_NANGATE45_CELLS
    BUF_X1 u_clkinsel_buf (.A(CLKINSEL), .Z(clkinsel_buf));
  `elsif USE_SKY130HD_CELLS
    sky130_fd_sc_hd__buf_1 u_clkinsel_buf (.A(CLKINSEL), .X(clkinsel_buf));
`elsif USE_GT2N_CELLS
    gt2_6t_buf_x2_w31_svt u_clkinsel_buf (.A(CLKINSEL), .Y(clkinsel_buf));
  `endif
  
  assign clkin_int = (clkinsel_buf ^ IS_CLKINSEL_INVERTED) ? CLKIN1 : CLKIN2;
  
  wire rst_buf;
  `ifdef USE_ASAP7_CELLS
    BUFx2_ASAP7_75t_R u_rst_buf (.A(RST), .Y(rst_buf));
  `elsif USE_NANGATE45_CELLS
    BUF_X1 u_rst_buf (.A(RST), .Z(rst_buf));
  `elsif USE_SKY130HD_CELLS
    sky130_fd_sc_hd__buf_1 u_rst_buf (.A(RST), .X(rst_buf));
`elsif USE_GT2N_CELLS
    gt2_6t_buf_x2_w31_svt u_rst_buf (.A(RST), .Y(rst_buf));
  `endif
  assign rst_int = rst_buf ^ IS_RST_INVERTED;
  
  wire pwrdwn_buf;
  `ifdef USE_ASAP7_CELLS
    BUFx2_ASAP7_75t_R u_pwrdwn_buf (.A(PWRDWN), .Y(pwrdwn_buf));
  `elsif USE_NANGATE45_CELLS
    BUF_X1 u_pwrdwn_buf (.A(PWRDWN), .Z(pwrdwn_buf));
  `elsif USE_SKY130HD_CELLS
    sky130_fd_sc_hd__buf_1 u_pwrdwn_buf (.A(PWRDWN), .X(pwrdwn_buf));
`elsif USE_GT2N_CELLS
    gt2_6t_buf_x2_w31_svt u_pwrdwn_buf (.A(PWRDWN), .Y(pwrdwn_buf));
  `endif
  assign pwrdwn_int = pwrdwn_buf ^ IS_PWRDWN_INVERTED;
  
  assign reset_active = rst_int | pwrdwn_int;
  assign pll_enable = ~reset_active;
  
  `ifdef USE_ASAP7_CELLS
    BUFx2_ASAP7_75t_R u_clkfb_buf (.A(CLKFBIN), .Y(clkfb_int));
  `elsif USE_NANGATE45_CELLS
    CLKBUF_X1 u_clkfb_buf (.A(CLKFBIN), .Z(clkfb_int));
  `elsif USE_SKY130HD_CELLS
    sky130_fd_sc_hd__buf_1 u_clkfb_buf (.A(CLKFBIN), .X(clkfb_int));
`elsif USE_GT2N_CELLS
    gt2_6t_buf_x2_w31_svt u_clkfb_buf (.A(CLKFBIN), .Y(clkfb_int));
  `endif
  
  `ifdef USE_ASAP7_CELLS
    BUFx2_ASAP7_75t_R u_vco_buf (.A(clkin_int), .Y(vco_clk));
  `elsif USE_NANGATE45_CELLS
    CLKBUF_X1 u_vco_buf (.A(clkin_int), .Z(vco_clk));
  `elsif USE_SKY130HD_CELLS
    sky130_fd_sc_hd__clkbuf_1 u_vco_buf (.A(clkin_int), .X(vco_clk));
`elsif USE_GT2N_CELLS
    gt2_6t_buf_x2_w31_svt u_vco_buf (.A(clkin_int), .Y(vco_clk));
  `endif
  
  reg [7:0] lock_counter;
  localparam LOCK_CYCLES = 8'd50;
  
  always @(posedge clkin_int or posedge reset_active) begin
    if (reset_active) begin
      lock_counter <= 8'd0;
      pll_locked_reg <= 1'b0;
    end else begin
      if (lock_counter < LOCK_CYCLES) begin
        lock_counter <= lock_counter + 1'b1;
      end else begin
        pll_locked_reg <= 1'b1;
      end
    end
  end
  

  
  reg [31:0] clk0_count;
  reg clkout0_reg;
  
  always @(posedge vco_clk or posedge reset_active) begin
    if (reset_active) begin
      clk0_count <= 32'd0;
      clkout0_reg <= 1'b0;
    end else if (pll_locked_reg) begin
      if (clk0_count >= (CLKOUT0_DIVIDE - 1)) begin
        clk0_count <= 32'd0;
        clkout0_reg <= ~clkout0_reg;
      end else begin
        clk0_count <= clk0_count + 1'b1;
      end
    end
  end
  
  reg [31:0] clk1_count;
  reg clkout1_reg;
  
  always @(posedge vco_clk or posedge reset_active) begin
    if (reset_active) begin
      clk1_count <= 32'd0;
      clkout1_reg <= 1'b0;
    end else if (pll_locked_reg) begin
      if (clk1_count >= (CLKOUT1_DIVIDE - 1)) begin
        clk1_count <= 32'd0;
        clkout1_reg <= ~clkout1_reg;
      end else begin
        clk1_count <= clk1_count + 1'b1;
      end
    end
  end
  
  reg [31:0] clk2_count;
  reg clkout2_reg;
  
  always @(posedge vco_clk or posedge reset_active) begin
    if (reset_active) begin
      clk2_count <= 32'd0;
      clkout2_reg <= 1'b0;
    end else if (pll_locked_reg) begin
      if (clk2_count >= (CLKOUT2_DIVIDE - 1)) begin
        clk2_count <= 32'd0;
        clkout2_reg <= ~clkout2_reg;
      end else begin
        clk2_count <= clk2_count + 1'b1;
      end
    end
  end
  
  reg [31:0] clk3_count;
  reg clkout3_reg;
  
  always @(posedge vco_clk or posedge reset_active) begin
    if (reset_active) begin
      clk3_count <= 32'd0;
      clkout3_reg <= 1'b0;
    end else if (pll_locked_reg) begin
      if (clk3_count >= (CLKOUT3_DIVIDE - 1)) begin
        clk3_count <= 32'd0;
        clkout3_reg <= ~clkout3_reg;
      end else begin
        clk3_count <= clk3_count + 1'b1;
      end
    end
  end
  
  reg [31:0] clk4_count;
  reg clkout4_reg;
  
  always @(posedge vco_clk or posedge reset_active) begin
    if (reset_active) begin
      clk4_count <= 32'd0;
      clkout4_reg <= 1'b0;
    end else if (pll_locked_reg) begin
      if (clk4_count >= (CLKOUT4_DIVIDE - 1)) begin
        clk4_count <= 32'd0;
        clkout4_reg <= ~clkout4_reg;
      end else begin
        clk4_count <= clk4_count + 1'b1;
      end
    end
  end
  
  reg [31:0] clk5_count;
  reg clkout5_reg;
  
  always @(posedge vco_clk or posedge reset_active) begin
    if (reset_active) begin
      clk5_count <= 32'd0;
      clkout5_reg <= 1'b0;
    end else if (pll_locked_reg) begin
      if (clk5_count >= (CLKOUT5_DIVIDE - 1)) begin
        clk5_count <= 32'd0;
        clkout5_reg <= ~clkout5_reg;
      end else begin
        clk5_count <= clk5_count + 1'b1;
      end
    end
  end
  
  reg clkfbout_reg;
  always @(posedge vco_clk or posedge reset_active) begin
    if (reset_active) begin
      clkfbout_reg <= 1'b0;
    end else begin
      clkfbout_reg <= vco_clk;
    end
  end
  
  always @(posedge DCLK or posedge reset_active) begin
    if (reset_active) begin
      do_reg <= 16'h0000;
      drdy_reg <= 1'b0;
    end else begin
      if (DEN) begin
        if (DWE) begin
          drdy_reg <= 1'b1;
        end else begin
          case (DADDR[3:0])
            4'h0: do_reg <= 16'h1234;
            4'h1: do_reg <= 16'h5678;
            4'h2: do_reg <= 16'h9ABC;
            4'h3: do_reg <= 16'hDEF0;
            default: do_reg <= 16'h0000;
          endcase
          drdy_reg <= 1'b1;
        end
      end else begin
        drdy_reg <= 1'b0;
      end
    end
  end
  
  `ifdef USE_ASAP7_CELLS
    BUFx2_ASAP7_75t_R u_clkfbout_buf (.A(clkfbout_reg), .Y(CLKFBOUT));
    BUFx2_ASAP7_75t_R u_clkout0_buf (.A(clkout0_reg), .Y(CLKOUT0));
    BUFx2_ASAP7_75t_R u_clkout1_buf (.A(clkout1_reg), .Y(CLKOUT1));
    BUFx2_ASAP7_75t_R u_clkout2_buf (.A(clkout2_reg), .Y(CLKOUT2));
    BUFx2_ASAP7_75t_R u_clkout3_buf (.A(clkout3_reg), .Y(CLKOUT3));
    BUFx2_ASAP7_75t_R u_clkout4_buf (.A(clkout4_reg), .Y(CLKOUT4));
    BUFx2_ASAP7_75t_R u_clkout5_buf (.A(clkout5_reg), .Y(CLKOUT5));
    BUFx2_ASAP7_75t_R u_locked_buf (.A(pll_locked_reg), .Y(LOCKED));
    BUFx2_ASAP7_75t_R u_drdy_buf (.A(drdy_reg), .Y(DRDY));
  `elsif USE_NANGATE45_CELLS
    CLKBUF_X1 u_clkfbout_buf (.A(clkfbout_reg), .Z(CLKFBOUT));
    CLKBUF_X1 u_clkout0_buf (.A(clkout0_reg), .Z(CLKOUT0));
    CLKBUF_X1 u_clkout1_buf (.A(clkout1_reg), .Z(CLKOUT1));
    CLKBUF_X1 u_clkout2_buf (.A(clkout2_reg), .Z(CLKOUT2));
    CLKBUF_X1 u_clkout3_buf (.A(clkout3_reg), .Z(CLKOUT3));
    CLKBUF_X1 u_clkout4_buf (.A(clkout4_reg), .Z(CLKOUT4));
    CLKBUF_X1 u_clkout5_buf (.A(clkout5_reg), .Z(CLKOUT5));
    BUF_X1 u_locked_buf (.A(pll_locked_reg), .Z(LOCKED));
    BUF_X1 u_drdy_buf (.A(drdy_reg), .Z(DRDY));
  `elsif USE_SKY130HD_CELLS
    sky130_fd_sc_hd__buf_1 u_clkfbout_buf (.A(clkfbout_reg), .X(CLKFBOUT));
    sky130_fd_sc_hd__buf_1 u_clkout0_buf (.A(clkout0_reg), .X(CLKOUT0));
    sky130_fd_sc_hd__buf_1 u_clkout1_buf (.A(clkout1_reg), .X(CLKOUT1));
    sky130_fd_sc_hd__buf_1 u_clkout2_buf (.A(clkout2_reg), .X(CLKOUT2));
    sky130_fd_sc_hd__buf_1 u_clkout3_buf (.A(clkout3_reg), .X(CLKOUT3));
    sky130_fd_sc_hd__buf_1 u_clkout4_buf (.A(clkout4_reg), .X(CLKOUT4));
    sky130_fd_sc_hd__buf_1 u_clkout5_buf (.A(clkout5_reg), .X(CLKOUT5));
    sky130_fd_sc_hd__buf_1 u_locked_buf (.A(pll_locked_reg), .X(LOCKED));
    sky130_fd_sc_hd__buf_1 u_drdy_buf (.A(drdy_reg), .X(DRDY));
`elsif USE_GT2N_CELLS
    gt2_6t_buf_x2_w31_svt u_clkfbout_buf (.A(clkfbout_reg), .Y(CLKFBOUT));
    gt2_6t_buf_x2_w31_svt u_clkout0_buf (.A(clkout0_reg), .Y(CLKOUT0));
    gt2_6t_buf_x2_w31_svt u_clkout1_buf (.A(clkout1_reg), .Y(CLKOUT1));
    gt2_6t_buf_x2_w31_svt u_clkout2_buf (.A(clkout2_reg), .Y(CLKOUT2));
    gt2_6t_buf_x2_w31_svt u_clkout3_buf (.A(clkout3_reg), .Y(CLKOUT3));
    gt2_6t_buf_x2_w31_svt u_clkout4_buf (.A(clkout4_reg), .Y(CLKOUT4));
    gt2_6t_buf_x2_w31_svt u_clkout5_buf (.A(clkout5_reg), .Y(CLKOUT5));
    gt2_6t_buf_x2_w31_svt u_locked_buf (.A(pll_locked_reg), .Y(LOCKED));
    gt2_6t_buf_x2_w31_svt u_drdy_buf (.A(drdy_reg), .Y(DRDY));
  `endif
  
  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_do_buf
      `ifdef USE_ASAP7_CELLS
        BUFx2_ASAP7_75t_R u_do_buf (.A(do_reg[i]), .Y(DO[i]));
      `elsif USE_NANGATE45_CELLS
        BUF_X1 u_do_buf (.A(do_reg[i]), .Z(DO[i]));
      `elsif USE_SKY130HD_CELLS
        sky130_fd_sc_hd__buf_1 u_do_buf (.A(do_reg[i]), .X(DO[i]));
`elsif USE_GT2N_CELLS
        gt2_6t_buf_x2_w31_svt u_do_buf (.A(do_reg[i]), .Y(DO[i]));
      `endif
    end
  endgenerate
  
  initial begin
    if (CLKFBOUT_MULT < 2 || CLKFBOUT_MULT > 64) begin
      $display("ERROR: CLKFBOUT_MULT must be between 2 and 64");
      $finish;
    end
    if (DIVCLK_DIVIDE < 1 || DIVCLK_DIVIDE > 56) begin
      $display("ERROR: DIVCLK_DIVIDE must be between 1 and 56");
      $finish;
    end
  end

endmodule
