// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author: Noah Huetter <huettern@iis.ee.ethz.ch>

/// An AXI4 Stream interface.
interface AXI_STREAM_BUS #(
  parameter int unsigned DataWidth = 0,
  parameter int unsigned IdWidth   = 0,
  parameter int unsigned DestWidth = 0,
  parameter int unsigned UserWidth = 0
);
  localparam int unsigned StrbWidth = DataWidth / 8;
  localparam int unsigned KeepWidth = DataWidth / 8;

  typedef logic [DataWidth-1:0] tdata_t;
  typedef logic [StrbWidth-1:0] tstrb_t;
  typedef logic [KeepWidth-1:0] tkeep_t;
  typedef logic [IdWidth-1:0]   tid_t;
  typedef logic [DestWidth-1:0] tdest_t;
  typedef logic [UserWidth-1:0] tuser_t;
  typedef logic                 tready_t;
  typedef logic                 tlast_t;

  // Signal list
  logic    tvalid;
  tready_t tready;
  tdata_t  tdata;
  tstrb_t  tstrb;
  tkeep_t  tkeep;
  tlast_t  tlast;
  tid_t    tid;
  tdest_t  tdest;
  tuser_t  tuser;

  // Module ports
  modport Tx(output tvalid, tdata, tstrb, tkeep, tlast, tid, tdest, tuser, input  tready);
  modport Rx(input  tvalid, tdata, tstrb, tkeep, tlast, tid, tdest, tuser, output tready);

endinterface

/// A clocked AXI4 Stream interface for use in design verification.
interface AXI_STREAM_BUS_DV #(
  parameter int unsigned DataWidth = 0,
  parameter int unsigned IdWidth   = 0,
  parameter int unsigned DestWidth = 0,
  parameter int unsigned UserWidth = 0
) (
  input logic clk_i
);
  localparam int unsigned StrbWidth = DataWidth / 8;
  localparam int unsigned KeepWidth = DataWidth / 8;

  typedef logic [DataWidth-1:0] tdata_t;
  typedef logic [StrbWidth-1:0] tstrb_t;
  typedef logic [KeepWidth-1:0] tkeep_t;
  typedef logic [IdWidth-1:0]   tid_t;
  typedef logic [DestWidth-1:0] tdest_t;
  typedef logic [UserWidth-1:0] tuser_t;
  typedef logic                 tready_t;
  typedef logic                 tlast_t;

  // Signal list
  logic    tvalid;
  tready_t tready;
  tdata_t  tdata;
  tstrb_t  tstrb;
  tkeep_t  tkeep;
  tlast_t  tlast;
  tid_t    tid;
  tdest_t  tdest;
  tuser_t  tuser;

  // Module ports
  modport Tx     (output tvalid, tdata, tstrb, tkeep, tlast, tid, tdest, tuser, input  tready);
  modport Rx     (input  tvalid, tdata, tstrb, tkeep, tlast, tid, tdest, tuser, output tready);
  modport Monitor(input  tvalid, tdata, tstrb, tkeep, tlast, tid, tdest, tuser, tready);

  // pragma translate_off
`ifndef VERILATOR
  // Single-Channel Assertions: Signals including valid must not change between valid and handshake.
  assert property (@(posedge clk_i) (tvalid && !tready |=> $stable(tdata)));
  assert property (@(posedge clk_i) (tvalid && !tready |=> $stable(tstrb)));
  assert property (@(posedge clk_i) (tvalid && !tready |=> $stable(tkeep)));
  assert property (@(posedge clk_i) (tvalid && !tready |=> $stable(tlast)));
  assert property (@(posedge clk_i) (tvalid && !tready |=> $stable(tid)));
  assert property (@(posedge clk_i) (tvalid && !tready |=> $stable(tdest)));
  assert property (@(posedge clk_i) (tvalid && !tready |=> $stable(tuser)));
  assert property (@(posedge clk_i) (tvalid && !tready |=> tvalid));
`endif
  // pragma translate_on

endinterface
