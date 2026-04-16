// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author: Noah Huetter <huettern@iis.ee.ethz.ch>

// Macros to define AXI Stream Channel and Request/Response Structs

`ifndef AXI_STREAM_TYPEDEF_SVH_
`define AXI_STREAM_TYPEDEF_SVH_

////////////////////////////////////////////////////////////////////////////////////////////////////
// AXI4-Stream Channel and Request/Response Structs
`define AXI_STREAM_TYPEDEF_S_CHAN_T(s_chan_t, tdata_t, tstrb_t, tkeep_t, tid_t, tdest_t, tuser_t) \
  typedef struct packed {                                                                         \
    tdata_t data;                                                                                 \
    tstrb_t strb;                                                                                 \
    tkeep_t keep;                                                                                 \
    logic   last;                                                                                 \
    tid_t   id;                                                                                   \
    tdest_t dest;                                                                                 \
    tuser_t user;                                                                                 \
  } s_chan_t;
`define AXI_STREAM_TYPEDEF_REQ_T(req_stream_t, s_chan_t) \
  typedef struct packed {                                \
    s_chan_t            t;                               \
    logic               tvalid;                          \
  } req_stream_t;
`define AXI_STREAM_TYPEDEF_RSP_T(rsp_stream_t) \
  typedef struct packed {                      \
    logic                tready;               \
  } rsp_stream_t;
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// All AXI4-Stream Channels and Request/Response Structs in One Macro
//
// This can be used whenever the user is not interested in "precise" control of the naming of the
// individual channels.
//
// Usage Example:
// `AXI_STREAM_TYPEDEF_ALL(axi_stream, tdata_t, tstrb_t, tkeep_t, tlast_t, tid_t, tdest_t, tuser_t, tready_t)
//
// This defines `axi_stream_req_t` and `axi_stream_rsp_t` request/response structs
`define AXI_STREAM_TYPEDEF_ALL(__name, __tdata_t, __tstrb_t, __tkeep_t, __tid_t, __tdest_t, __tuser_t)            \
  `AXI_STREAM_TYPEDEF_S_CHAN_T(__name``_s_chan_t, __tdata_t, __tstrb_t, __tkeep_t, __tid_t, __tdest_t, __tuser_t) \
  `AXI_STREAM_TYPEDEF_REQ_T(__name``_req_t,__name``_s_chan_t)                                                     \
  `AXI_STREAM_TYPEDEF_RSP_T(__name``_rsp_t)
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Flat AXI Stream ports
// Vivado naming convention is followed.
`define AXI_STREAM_FLAT_PORT_TX(__name, __DataWidth, __IdWidth, __DestWidth, __UserWidth) \
    output logic [__DataWidth-1:0]   __name``_tdata,                                      \
    output logic [__DataWidth/8-1:0] __name``_tstrb,                                      \
    output logic [__DataWidth/8-1:0] __name``_tkeep,                                      \
    output logic                     __name``_tlast,                                      \
    output logic [__IdWidth-1:0]     __name``_tid,                                        \
    output logic [__DestWidth-1:0]   __name``_tdest,                                      \
    output logic [__UserWidth-1:0]   __name``_tuser,                                      \
    output logic                     __name``_tvalid,                                     \
    input  logic                     __name``_tready
`define AXI_STREAM_FLAT_PORT_RX(__name, __DataWidth, __IdWidth, ___DestWidth, __UserWidth) \
    input   logic [__DataWidth-1:0]   __name``_tdata,                                      \
    input   logic [__DataWidth/8-1:0] __name``_tstrb,                                      \
    input   logic [__DataWidth/8-1:0] __name``_tkeep,                                      \
    input   logic [__Lw-1:0]          __name``_tlast,                                      \
    input   logic [__IdWidth-1:0]     __name``_tid,                                        \
    input   logic [__DestWidth-1:0]   __name``_tdest,                                      \
    input   logic [__UserWidth-1:0]   __name``_tuser,                                      \
    input   logic                     __name``_tvalid,                                     \
    output  logic                     __name``_tready
////////////////////////////////////////////////////////////////////////////////////////////////////

`endif
