// Cluster stub for snitch_cluster_wrapper: a synthesizable area/activity
// proxy for the cluster macro attached to each FlooNoC mesh endpoint.
// Uses FlooNoC package AXI types directly for interface compatibility.
//
// History (VLSIDA/HighTide#254): this used to be an empty module intended
// as a black box, but without a (* blackbox *) attribute the slang
// frontend dissolved it, every cluster output became an undriven net, and
// synthesis constant-folded most of the mesh away (~13.7K flops survived
// on asap7 where the full mesh carries hundreds of thousands).
//
// Instead of a pin-level black box (which would need a custom LEF), the
// stub now follows the suite's standard macros.v pattern: a real body
// wrapping a stock bsg_fakeram macro (fakeram_w64_l16384 = 1 Mbit, the
// TCDM-equivalent of one snitch cluster) plus registered glue. Every
// output is a registered function of the SRAM read data and the folded
// AXI inputs, so the mesh sees live, input-dependent traffic on every
// channel and nothing can be simplified away. The glue is not an AXI
// protocol model; it exists to load the mesh ports realistically.

module cluster_blackbox
  import floo_floonoc_mesh_noc_pkg::*;
(
  input  logic                    clk_i,
  input  logic                    rst_ni,
  // Narrow AXI slave (mesh -> cluster)
  input  axi_narrow_out_req_t     narrow_in_req_i,
  output axi_narrow_out_rsp_t     narrow_in_resp_o,
  // Narrow AXI master (cluster -> mesh)
  output axi_narrow_in_req_t      narrow_out_req_o,
  input  axi_narrow_in_rsp_t      narrow_out_resp_i,
  // Wide AXI slave (mesh -> cluster)
  input  axi_wide_out_req_t       wide_in_req_i,
  output axi_wide_out_rsp_t       wide_in_resp_o,
  // Wide AXI master (cluster -> mesh)
  output axi_wide_in_req_t        wide_out_req_o,
  input  axi_wide_in_rsp_t        wide_out_resp_i
);

  localparam int unsigned MemWidth = 64;
  localparam int unsigned MemDepth = 16384;
  localparam int unsigned AddrW    = $clog2(MemDepth);

  // Fold an arbitrary packed vector into MemWidth bits, 64b chunk by
  // 64b chunk, so every input bit influences the SRAM write stream.
  function automatic logic [MemWidth-1:0] fold64(input logic [16383:0] v,
                                                 input int unsigned nbits);
    logic [MemWidth-1:0] acc;
    acc = '0;
    for (int unsigned i = 0; i < nbits; i += MemWidth) begin
      acc ^= v[i +: MemWidth];
    end
    return acc;
  endfunction

  localparam int unsigned NInW  = $bits(axi_narrow_out_req_t);
  localparam int unsigned NOutW = $bits(axi_narrow_in_rsp_t);
  localparam int unsigned WInW  = $bits(axi_wide_out_req_t);
  localparam int unsigned WOutW = $bits(axi_wide_in_rsp_t);

  logic [MemWidth-1:0] rd_out;
  logic [MemWidth-1:0] wd_q;
  logic [AddrW-1:0]    addr_q;
  logic                we_q;

  // Live write stream: every AXI input folded together, mixed with the
  // previous read data; address walks the array seeded by read data.
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      wd_q   <= '0;
      addr_q <= '0;
      we_q   <= 1'b0;
    end else begin
      wd_q   <= fold64(16384'(narrow_in_req_i), NInW)
              ^ fold64(16384'(wide_in_req_i), WInW)
              ^ fold64(16384'(narrow_out_resp_i), NOutW)
              ^ fold64(16384'(wide_out_resp_i), WOutW)
              ^ rd_out;
      addr_q <= addr_q + AddrW'(1) + AddrW'(rd_out[AddrW-1:0]);
      we_q   <= ~we_q;
    end
  end

  fakeram_w64_l16384 u_cluster_mem (
    .rw0_clk    (clk_i),
    .rw0_ce_in  (1'b1),
    .rw0_we_in  (we_q),
    .rw0_addr_in(addr_q),
    .rw0_wd_in  (wd_q),
    .rw0_rd_out (rd_out)
  );

  // Registered outputs: replicate the SRAM read data across each output
  // struct, remixed with the opposite-direction inputs so every output
  // bit is sequential and input-dependent.
  localparam int unsigned NRspW = $bits(axi_narrow_out_rsp_t);
  localparam int unsigned NReqW = $bits(axi_narrow_in_req_t);
  localparam int unsigned WRspW = $bits(axi_wide_out_rsp_t);
  localparam int unsigned WReqW = $bits(axi_wide_in_req_t);

  logic [NRspW-1:0] n_rsp_q;
  logic [NReqW-1:0] n_req_q;
  logic [WRspW-1:0] w_rsp_q;
  logic [WReqW-1:0] w_req_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      n_rsp_q <= '0;
      n_req_q <= '0;
      w_rsp_q <= '0;
      w_req_q <= '0;
    end else begin
      n_rsp_q <= NRspW'({(NRspW+MemWidth-1)/MemWidth{rd_out}})
                 ^ NRspW'(narrow_in_req_i);
      n_req_q <= NReqW'({(NReqW+MemWidth-1)/MemWidth{~rd_out}})
                 ^ NReqW'(narrow_out_resp_i);
      w_rsp_q <= WRspW'({(WRspW+MemWidth-1)/MemWidth{rd_out}})
                 ^ WRspW'(wide_in_req_i);
      w_req_q <= WReqW'({(WReqW+MemWidth-1)/MemWidth{~rd_out}})
                 ^ WReqW'(wide_out_resp_i);
    end
  end

  assign narrow_in_resp_o = axi_narrow_out_rsp_t'(n_rsp_q);
  assign narrow_out_req_o = axi_narrow_in_req_t'(n_req_q);
  assign wide_in_resp_o   = axi_wide_out_rsp_t'(w_rsp_q);
  assign wide_out_req_o   = axi_wide_in_req_t'(w_req_q);

endmodule
