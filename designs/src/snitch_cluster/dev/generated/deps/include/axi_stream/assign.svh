// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
//  - Noah Huetter <huettern@iis.ee.ethz.ch>
//  - Nils Wistoff <nwistoff@iis.ee.ethz.ch>

// Macros to define AXI Stream Channel and Request/Response Structs

`ifndef AXI_STREAM_ASSIGN_SVH_
`define AXI_STREAM_ASSIGN_SVH_

////////////////////////////////////////////////////////////////////////////////////////////////////
// Internal implementation for assigning one stream structs or interface to another struct or
// interface.  The path to the signals on each side is defined by the `__sep*` arguments.  The
// `__opt_as` argument allows to use this standalone (with `__opt_as = assign`) or in assignments
// inside processes (with `__opt_as` void).
`define __AXI_STREAM_TO_S(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;           \
  __opt_as __lhs``__lhs_sep``strb   = __rhs``__rhs_sep``strb;           \
  __opt_as __lhs``__lhs_sep``keep   = __rhs``__rhs_sep``keep;           \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;           \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;             \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;           \
  __opt_as __lhs``__lhs_sep``dest   = __rhs``__rhs_sep``dest;
`define __AXI_STREAM_TO_REQ(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  `__AXI_STREAM_TO_S(__opt_as, __lhs.t, __lhs_sep, __rhs.t, __rhs_sep)    \
  __opt_as __lhs.tvalid = __rhs.tvalid;
`define __AXI_STREAM_TO_RSP(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs.tready = __rhs.tready;
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Assigning one AXI4 Stream interface to another, as if you would do `assign slv = mst;`
//
`define AXI_STREAM_ASSIGN_S(dst, src)          \
  `__AXI_STREAM_TO_S(assign, dst.t, , src.t, ) \
  assign dst.tvalid  = src.tvalid;             \
  assign src.tready  = dst.tready;
`define AXI_STREAM_ASSIGN(dst, src) \
  `AXI_STREAM_ASSIGN_S(dst, src)
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Assigning a stream interface from channel or request/response structs outside a process.
`define AXI_STREAM_ASSIGN_FROM_S(axi_if, s_struct) `__AXI_STREAM_TO_S(assign, axi_if.t, , s_struct, .)
`define AXI_STREAM_ASSIGN_FROM_REQ(axi_if, req_struct) `__AXI_STREAM_TO_REQ(assign, axi_if, , req_struct, .)
`define AXI_STREAM_ASSIGN_FROM_RSP(axi_if, rsp_struct) `__AXI_STREAM_TO_RSP(assign, axi_if, , rsp_struct, .)
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Assigning channel or request/response structs from an interface outside a process.
`define AXI_STREAM_ASSIGN_TO_R(s_struct, axi_if) `__AXI_STREAM_TO_S(assign, s_struct, ., axi_if.t, )
`define AXI_STREAM_ASSIGN_TO_REQ(req_struct, axi_if) `__AXI_STREAM_TO_REQ(assign, req_struct, ., axi_if, )
`define AXI_STREAM_ASSIGN_TO_RSP(rsp_struct, axi_if) `__AXI_STREAM_TO_RSP(assign, rsp_struct, ., axi_if, )
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Macros for assigning flattened AXI stream ports to req/rsp AXI Stream structs
// Vivado naming convention is followed.
`define AXI_STREAM_ASSIGN_TO_FLAT(__name, __req, __rsp) \
  assign __name``_tvalid   = __req.tvalid;              \
  assign __name``_tdata    = __req.t.data;              \
  assign __name``_tstrb    = __req.t.strb;              \
  assign __name``_tkeep    = __req.t.keep;              \
  assign __name``_tid      = __req.t.id;                \
  assign __name``_tlast    = __req.t.last;              \
  assign __name``_tuser    = __req.t.user;              \
  assign __name``_tdest    = __req.t.dest;              \
  assign __rsp.tready     = __name``_tready;
`define AXI_STREAM_ASSIGN_FROM_FLAT(__req, __rsp, __name) \
  assign __req.tvalid   = __name``_tvalid;                \
  assign __req.t.data    = __name``_tdata;                \
  assign __req.t.strb    = __name``_tstrb;                \
  assign __req.t.keep    = __name``_tkeep;                \
  assign __req.t.id      = __name``_tid;                  \
  assign __req.t.last    = __name``_tlast;                \
  assign __req.t.user    = __name``_tuser;                \
  assign __req.t.dest    = __name``_tdest;                \
  assign __name``_tready = __rsp.tready;
////////////////////////////////////////////////////////////////////////////////////////////////////

`endif
