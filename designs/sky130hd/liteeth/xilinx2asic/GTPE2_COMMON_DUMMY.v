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
  
  sky130_fd_sc_hd__buf_1 u_pll0_refclk_buf (.A(pll0_refclk_mux), .X(pll0_refclk_selected));

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
  
  sky130_fd_sc_hd__buf_1 u_pll1_refclk_buf (.A(pll1_refclk_mux), .X(pll1_refclk_selected));

  sky130_fd_sc_hd__buf_1 u_pll0_reset_buf (.A(PLL0RESET), .X(pll0_reset_int));
  wire pll0_pd_int;
  sky130_fd_sc_hd__buf_1 u_pll0_pd_buf (.A(PLL0PD), .X(pll0_pd_int));
  
  wire pll0_enable_int;
  sky130_fd_sc_hd__nor2_2 u_pll0_enable (.A(pll0_reset_int), .B(pll0_pd_int), .Y(pll0_enable_int));
  sky130_fd_sc_hd__buf_1 u_pll0_enable_buf (.A(pll0_enable_int), .X(pll0_enable));

  sky130_fd_sc_hd__buf_1 u_pll1_reset_buf (.A(PLL1RESET), .X(pll1_reset_int));
  wire pll1_pd_int;
  sky130_fd_sc_hd__buf_1 u_pll1_pd_buf (.A(PLL1PD), .X(pll1_pd_int));
  
  wire pll1_enable_int;
  sky130_fd_sc_hd__nor2_2 u_pll1_enable (.A(pll1_reset_int), .B(pll1_pd_int), .Y(pll1_enable_int));
  sky130_fd_sc_hd__buf_1 u_pll1_enable_buf (.A(pll1_enable_int), .X(pll1_enable));

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

  sky130_fd_sc_hd__buf_1 u_pll0outclk_buf (.A(pll0_outclk_reg), .X(PLL0OUTCLK));
  sky130_fd_sc_hd__buf_1 u_pll0outrefclk_buf (.A(pll0_outrefclk_reg), .X(PLL0OUTREFCLK));
  sky130_fd_sc_hd__buf_1 u_pll1outclk_buf (.A(pll1_outclk_reg), .X(PLL1OUTCLK));
  sky130_fd_sc_hd__buf_1 u_pll1outrefclk_buf (.A(pll1_outrefclk_reg), .X(PLL1OUTREFCLK));
  sky130_fd_sc_hd__buf_1 u_refmon0_buf (.A(refclkoutmonitor0_reg), .X(REFCLKOUTMONITOR0));
  sky130_fd_sc_hd__buf_1 u_refmon1_buf (.A(refclkoutmonitor1_reg), .X(REFCLKOUTMONITOR1));
  
  sky130_fd_sc_hd__buf_1 u_pll0lock_buf (.A(pll0_locked_reg), .X(PLL0LOCK));
  sky130_fd_sc_hd__buf_1 u_pll1lock_buf (.A(pll1_locked_reg), .X(PLL1LOCK));
  sky130_fd_sc_hd__buf_1 u_pll0fbclklost_buf (.A(pll0_fbclklost_reg), .X(PLL0FBCLKLOST));
  sky130_fd_sc_hd__buf_1 u_pll1fbclklost_buf (.A(pll1_fbclklost_reg), .X(PLL1FBCLKLOST));
  sky130_fd_sc_hd__buf_1 u_pll0refclklost_buf (.A(pll0_refclklost_reg), .X(PLL0REFCLKLOST));
  sky130_fd_sc_hd__buf_1 u_pll1refclklost_buf (.A(pll1_refclklost_reg), .X(PLL1REFCLKLOST));
  
  sky130_fd_sc_hd__buf_1 u_drprdy_buf (.A(drprdy_reg), .X(DRPRDY));
  
  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_drpdo_buf
      sky130_fd_sc_hd__buf_1 u_drpdo_buf (.A(drpdo_reg[i]), .X(DRPDO[i]));
    end
    
    for (i = 0; i < 8; i = i + 1) begin : gen_dmon_buf
      sky130_fd_sc_hd__buf_1 u_dmon_buf (.A(dmonitorout_reg[i]), .X(DMONITOROUT[i]));
    end
    
    for (i = 0; i < 16; i = i + 1) begin : gen_pmarsvd_buf
      sky130_fd_sc_hd__buf_1 u_pmarsvd_buf (.A(pmarsvdout_reg[i]), .X(PMARSVDOUT[i]));
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
