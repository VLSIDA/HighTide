// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Wolfgang Roenninger <wroennin@iis.ee.ethz.ch>
// - Fabian Schuiki <fschuiki@iis.ee.ethz.ch>
// - Andreas Kurth <akurth@iis.ee.ethz.ch>
// - Stefan Mach <smach@iis.ee.ethz.ch>
// - Noah Huetter <huettern@iis.ee.ethz.ch>

/// Multiple AXI4 Stream cuts.
module axi_stream_multicut #(
  /// Number of cuts
  parameter int unsigned NumCuts  = 32'd0,
  /// AXI Stream channel struct
  parameter type s_chan_t         = logic,
  /// AXI Stream request struct
  parameter type axi_stream_req_t = logic,
  /// AXI Stream response struct
  parameter type axi_stream_rsp_t = logic
) (
  /// Clock
  input  logic            clk_i,
  /// Asynchronous reset, active low
  input  logic            rst_ni,
  /// rx port request
  input  axi_stream_req_t rx_req_i,
  /// rx port response
  output axi_stream_rsp_t rx_rsp_o,
  /// tx port request
  output axi_stream_req_t tx_req_o,
  /// tx port request
  input  axi_stream_rsp_t tx_rsp_i
);

  if (NumCuts == 32'd0) begin : gen_no_cut
    // degenerate case, connect input to output
    assign tx_req_o = rx_req_i;
    assign rx_rsp_o = tx_rsp_i;

  end else begin : gen_axi_stream_cut
    // instantiate all needed cuts
    axi_stream_req_t [NumCuts:0] cut_req;
    axi_stream_rsp_t [NumCuts:0] cut_rsp;

    // connect slave to the lowest index
    assign cut_req[0] = rx_req_i;
    assign rx_rsp_o   = cut_rsp[0];

    // AXI cuts
    for (genvar i = 0; i < NumCuts; i++) begin : gen_axi_cuts

      axi_stream_cut #(
        .Bypass           ( 1'b0             ),
        .s_chan_t         ( s_chan_t         ),
        .axi_stream_req_t ( axi_stream_req_t ),
        .axi_stream_rsp_t ( axi_stream_rsp_t )
      ) i_axi_stream_cut (
        .clk_i,
        .rst_ni,
        .rx_req_i ( cut_req[i]   ),
        .rx_rsp_o ( cut_rsp[i]   ),
        .tx_req_o ( cut_req[i+1] ),
        .tx_rsp_i ( cut_rsp[i+1] )
      );

    end

    // connect master to the highest index
    assign tx_req_o         = cut_req[NumCuts];
    assign cut_rsp[NumCuts] = tx_rsp_i;
  end

  // Check the invariants
  // pragma translate_off
  `ifndef VERILATOR
  initial begin
    assert(NumCuts >= 0);
  end
  `endif
  // pragma translate_on

endmodule


`include "axi_stream/assign.svh"
`include "axi_stream/typedef.svh"

// interface wrapper
module axi_stream_multicut_intf #(
  /// Number of cuts
  parameter int unsigned NumCuts    = 32'd0,
  /// AXI Stream Data Width
  parameter int unsigned DataWidth  = 32'd0,
  /// AXI Stream ID Width
  parameter int unsigned IdWidth    = 32'd0,
  /// AXI Stream Dest Width
  parameter int unsigned DestWidth  = 32'd0,
  /// AXI Stream User Width
  parameter int unsigned UserWidth  = 32'd0
) (
  /// Clock
  input logic       clk_i,
  /// Asynchronous reset, active low
  input logic       rst_ni,
  /// AXI Stream Bus Receiver Port
  AXI_STREAM_BUS.Rx in,
  /// AXI Stream Bus Transmitter Port
  AXI_STREAM_BUS.Tx out
);
  // AXI stream channels typedefs
  typedef logic [DataWidth-1:0]   tdata_t;
  typedef logic [DataWidth/8-1:0] tstrb_t;
  typedef logic [DataWidth/8-1:0] tkeep_t;
  typedef logic [IdWidth-1:0]     tid_t;
  typedef logic [DestWidth-1:0]   tdest_t;
  typedef logic [UserWidth-1:0]   tuser_t;

  `AXI_STREAM_TYPEDEF_ALL(s, tdata_t, tstrb_t, tkeep_t, tid_t, tdest_t, tuser_t)

  // AXI stream signals
  s_req_t s_rx_req, s_tx_req;
  s_rsp_t s_rx_rsp, s_tx_rsp;

  // connect modports to req/rsp signals
  `AXI_STREAM_ASSIGN_FROM_REQ(out, s_tx_req)
  `AXI_STREAM_ASSIGN_TO_RSP(s_tx_rsp, out)
  `AXI_STREAM_ASSIGN_TO_REQ(s_rx_req, in)
  `AXI_STREAM_ASSIGN_FROM_RSP(in, s_rx_rsp)

  axi_stream_multicut #(
      .NumCuts          ( NumCuts    ),
      .s_chan_t         ( s_s_chan_t ),
      .axi_stream_req_t ( s_req_t    ),
      .axi_stream_rsp_t ( s_rsp_t    )
  ) i_axi_stream_multicut (
      .clk_i,
      .rst_ni,
      .rx_req_i ( s_rx_req ),
      .rx_rsp_o ( s_rx_rsp ),
      .tx_req_o ( s_tx_req ),
      .tx_rsp_i ( s_tx_rsp )
  );

endmodule
