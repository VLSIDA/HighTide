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
  
  genvar j;
  generate
    for (j = 0; j < 7; j = j + 1) begin : gen_daddr_buf
      sky130_fd_sc_hd__buf_1 u_daddr_buf (.A(DADDR[j]), .X(daddr_buf[j]));
    end
    for (j = 0; j < 16; j = j + 1) begin : gen_di_buf
      sky130_fd_sc_hd__buf_1 u_di_buf (.A(DI[j]), .X(di_buf[j]));
    end
  endgenerate
  
  assign clkin_sel = clkinsel_buf ^ IS_CLKINSEL_INVERTED;
  assign clkin_int = clkin_sel ? (clkin2_buf ^ IS_CLKIN2_INVERTED) : 
                                (clkin1_buf ^ IS_CLKIN1_INVERTED);
  assign clkfb_int = clkfbin_buf ^ IS_CLKFBIN_INVERTED;
  assign reset_int = rst_buf ^ IS_RST_INVERTED;
  assign pwrdwn_int = pwrdwn_buf ^ IS_PWRDWN_INVERTED;

  // always @(*) begin
  //   if (clkin_sel) begin
  //     clkin_period = CLKIN2_PERIOD;
  //   end else begin
  //     clkin_period = CLKIN1_PERIOD;
  //   end
    
  //   if (DIVCLK_DIVIDE > 0 && CLKFBOUT_MULT_F > 0) begin
  //     vco_period = (clkin_period * DIVCLK_DIVIDE) / CLKFBOUT_MULT_F;
  //   end else begin
  //     vco_period = 10.0;
  //   end
  // end
  
  sky130_fd_sc_hd__buf_1 u_vco_buf (.A(clkin_int), .X(vco_clk));
  
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
  
  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_do_buf
      sky130_fd_sc_hd__buf_1 u_do_buf (.A(drp_do_reg[i]), .X(DO[i]));
    end
  endgenerate

endmodule
