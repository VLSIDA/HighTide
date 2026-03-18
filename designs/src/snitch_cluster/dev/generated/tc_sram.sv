// Replacement tc_sram for ASAP7 synthesis.
// Maps large memories to fakeram macros; small memories stay as FFs.
// Drop-in replacement for tech_cells_generic tc_sram.

module tc_sram #(
  parameter int unsigned NumWords     = 32'd1024,
  parameter int unsigned DataWidth    = 32'd128,
  parameter int unsigned ByteWidth    = 32'd8,
  parameter int unsigned NumPorts     = 32'd2,
  parameter int unsigned Latency      = 32'd1,
  parameter              SimInit      = "none",
  parameter bit          PrintSimCfg  = 1'b0,
  parameter              ImplKey      = "none",
  // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
  parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
  parameter int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth,
  parameter type         addr_t    = logic [AddrWidth-1:0],
  parameter type         data_t    = logic [DataWidth-1:0],
  parameter type         be_t      = logic [BeWidth-1:0]
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic  [NumPorts-1:0] req_i,
  input  logic  [NumPorts-1:0] we_i,
  input  addr_t [NumPorts-1:0] addr_i,
  input  data_t [NumPorts-1:0] wdata_i,
  input  be_t   [NumPorts-1:0] be_i,
  output data_t [NumPorts-1:0] rdata_o
);

  // ────────────────────────────────────────────────────────────────────
  // 512x64: TCDM banks → 2x fakeram7_256x64 (address-banked)
  // ────────────────────────────────────────────────────────────────────
  if (NumPorts == 1 && NumWords == 512 && DataWidth == 64) begin : gen_512x64

    logic bank_sel;
    logic bank_sel_q;
    logic [7:0] bank_addr;
    logic [63:0] rd0, rd1;

    assign bank_sel  = addr_i[0][8];
    assign bank_addr = addr_i[0][7:0];

    fakeram7_256x64 i_bank0 (
      .rw0_clk     ( clk_i ),
      .rw0_ce_in   ( req_i[0] & ~bank_sel ),
      .rw0_we_in   ( we_i[0] ),
      .rw0_addr_in ( bank_addr ),
      .rw0_wd_in   ( wdata_i[0] ),
      .rw0_rd_out  ( rd0 )
    );

    fakeram7_256x64 i_bank1 (
      .rw0_clk     ( clk_i ),
      .rw0_ce_in   ( req_i[0] & bank_sel ),
      .rw0_we_in   ( we_i[0] ),
      .rw0_addr_in ( bank_addr ),
      .rw0_wd_in   ( wdata_i[0] ),
      .rw0_rd_out  ( rd1 )
    );

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) bank_sel_q <= 1'b0;
      else if (req_i[0]) bank_sel_q <= bank_sel;
    end

    assign rdata_o[0] = bank_sel_q ? rd1 : rd0;

  // ────────────────────────────────────────────────────────────────────
  // 64x512: DMA → fakeram7_64x512
  // ────────────────────────────────────────────────────────────────────
  end else if (NumPorts == 1 && NumWords == 64 && DataWidth == 512) begin : gen_64x512

    fakeram7_64x512 i_mem (
      .rw0_clk     ( clk_i ),
      .rw0_ce_in   ( req_i[0] ),
      .rw0_we_in   ( we_i[0] ),
      .rw0_addr_in ( addr_i[0] ),
      .rw0_wd_in   ( wdata_i[0] ),
      .rw0_rd_out  ( rdata_o[0] )
    );

  // ────────────────────────────────────────────────────────────────────
  // 128x512: ICache data → 2x fakeram7_256x256 (width-split)
  // ────────────────────────────────────────────────────────────────────
  end else if (NumPorts == 1 && NumWords <= 256 && DataWidth == 512) begin : gen_Nx512

    logic [7:0] padded_addr;
    assign padded_addr = {{(8-AddrWidth){1'b0}}, addr_i[0]};

    logic [255:0] rd_lo, rd_hi;

    fakeram7_256x256 i_lo (
      .rw0_clk     ( clk_i ),
      .rw0_ce_in   ( req_i[0] ),
      .rw0_we_in   ( we_i[0] ),
      .rw0_addr_in ( padded_addr ),
      .rw0_wd_in   ( wdata_i[0][255:0] ),
      .rw0_rd_out  ( rd_lo )
    );

    fakeram7_256x256 i_hi (
      .rw0_clk     ( clk_i ),
      .rw0_ce_in   ( req_i[0] ),
      .rw0_we_in   ( we_i[0] ),
      .rw0_addr_in ( padded_addr ),
      .rw0_wd_in   ( wdata_i[0][511:256] ),
      .rw0_rd_out  ( rd_hi )
    );

    assign rdata_o[0] = {rd_hi, rd_lo};

  // ────────────────────────────────────────────────────────────────────
  // All other sizes: behavioral model (synthesized to FFs)
  // ────────────────────────────────────────────────────────────────────
  end else begin : gen_ff

    data_t sram [NumWords-1:0];
    addr_t [NumPorts-1:0] r_addr_q;

    data_t [NumPorts-1:0][Latency-1:0] rdata_q, rdata_d;
    if (Latency == 32'd0) begin : gen_no_read_lat
      for (genvar i = 0; i < NumPorts; i++) begin : gen_port
        assign rdata_o[i] = (req_i[i] && !we_i[i]) ? sram[addr_i[i]] : sram[r_addr_q[i]];
      end
    end else begin : gen_read_lat
      always_comb begin
        for (int unsigned i = 0; i < NumPorts; i++) begin
          rdata_o[i] = rdata_q[i][0];
          for (int unsigned j = 0; j < (Latency-1); j++)
            rdata_d[i][j] = rdata_q[i][j+1];
          rdata_d[i][Latency-1] = (req_i[i] && !we_i[i]) ? sram[addr_i[i]] : sram[r_addr_q[i]];
        end
      end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        for (int i = 0; i < NumPorts; i++)
          r_addr_q[i] <= {AddrWidth{1'b0}};
      end else begin
        for (int unsigned i = 0; i < NumPorts; i++) begin
          if (Latency != 0) begin
            for (int unsigned j = 0; j < Latency; j++)
              rdata_q[i][j] <= rdata_d[i][j];
          end
        end
        for (int unsigned i = 0; i < NumPorts; i++) begin
          if (req_i[i]) begin
            if (we_i[i]) begin
              for (int unsigned j = 0; j < BeWidth; j++) begin
                if (be_i[i][j])
                  sram[addr_i[i]][j*ByteWidth+:ByteWidth] <= wdata_i[i][j*ByteWidth+:ByteWidth];
              end
            end else begin
              r_addr_q[i] <= addr_i[i];
            end
          end
        end
      end
    end

  end

endmodule
