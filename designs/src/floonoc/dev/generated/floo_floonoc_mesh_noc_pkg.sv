// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// AUTOMATICALLY GENERATED! DO NOT EDIT!

`include "axi/typedef.svh"
`include "floo_noc/typedef.svh"

package floo_floonoc_mesh_noc_pkg;

  import floo_pkg::*;

  /////////////////////
  //   Address Map   //
  /////////////////////

  typedef enum logic[4:0] {
    ClusterX0Y0 = 0,
    ClusterX0Y1 = 1,
    ClusterX0Y2 = 2,
    ClusterX0Y3 = 3,
    ClusterX1Y0 = 4,
    ClusterX1Y1 = 5,
    ClusterX1Y2 = 6,
    ClusterX1Y3 = 7,
    ClusterX2Y0 = 8,
    ClusterX2Y1 = 9,
    ClusterX2Y2 = 10,
    ClusterX2Y3 = 11,
    ClusterX3Y0 = 12,
    ClusterX3Y1 = 13,
    ClusterX3Y2 = 14,
    ClusterX3Y3 = 15,
    Hbm0 = 16,
    Hbm1 = 17,
    Hbm2 = 18,
    Hbm3 = 19,
    NumEndpoints = 20} ep_id_e;



  typedef enum logic[4:0] {
    ClusterX0Y0SamIdx = 0,
    ClusterX0Y1SamIdx = 1,
    ClusterX0Y2SamIdx = 2,
    ClusterX0Y3SamIdx = 3,
    ClusterX1Y0SamIdx = 4,
    ClusterX1Y1SamIdx = 5,
    ClusterX1Y2SamIdx = 6,
    ClusterX1Y3SamIdx = 7,
    ClusterX2Y0SamIdx = 8,
    ClusterX2Y1SamIdx = 9,
    ClusterX2Y2SamIdx = 10,
    ClusterX2Y3SamIdx = 11,
    ClusterX3Y0SamIdx = 12,
    ClusterX3Y1SamIdx = 13,
    ClusterX3Y2SamIdx = 14,
    ClusterX3Y3SamIdx = 15,
    Hbm0SamIdx = 16,
    Hbm1SamIdx = 17,
    Hbm2SamIdx = 18,
    Hbm3SamIdx = 19} sam_idx_e;



  typedef logic[0:0] rob_idx_t;
typedef logic[0:0] port_id_t;
typedef logic[2:0] x_bits_t;
typedef logic[1:0] y_bits_t;
typedef struct packed {
    x_bits_t x;
    y_bits_t y;
    port_id_t port_id;
} id_t;

typedef logic route_t;


  localparam int unsigned SamNumRules = 20;

typedef struct packed {
    id_t idx;
    logic [47:0] start_addr;
    logic [47:0] end_addr;
} sam_rule_t;

localparam sam_rule_t[SamNumRules-1:0] Sam = '{
'{    idx: '{x: 0, y: 3, port_id: 0},
    start_addr: 48'h000140000000,
    end_addr: 48'h000180000000},// Hbm3
'{    idx: '{x: 0, y: 2, port_id: 0},
    start_addr: 48'h000100000000,
    end_addr: 48'h000140000000},// Hbm2
'{    idx: '{x: 0, y: 1, port_id: 0},
    start_addr: 48'h0000c0000000,
    end_addr: 48'h000100000000},// Hbm1
'{    idx: '{x: 0, y: 0, port_id: 0},
    start_addr: 48'h000080000000,
    end_addr: 48'h0000c0000000},// Hbm0
'{    idx: '{x: 4, y: 3, port_id: 0},
    start_addr: 48'h0000103c0000,
    end_addr: 48'h000010400000},// ClusterX3Y3
'{    idx: '{x: 4, y: 2, port_id: 0},
    start_addr: 48'h000010380000,
    end_addr: 48'h0000103c0000},// ClusterX3Y2
'{    idx: '{x: 4, y: 1, port_id: 0},
    start_addr: 48'h000010340000,
    end_addr: 48'h000010380000},// ClusterX3Y1
'{    idx: '{x: 4, y: 0, port_id: 0},
    start_addr: 48'h000010300000,
    end_addr: 48'h000010340000},// ClusterX3Y0
'{    idx: '{x: 3, y: 3, port_id: 0},
    start_addr: 48'h0000102c0000,
    end_addr: 48'h000010300000},// ClusterX2Y3
'{    idx: '{x: 3, y: 2, port_id: 0},
    start_addr: 48'h000010280000,
    end_addr: 48'h0000102c0000},// ClusterX2Y2
'{    idx: '{x: 3, y: 1, port_id: 0},
    start_addr: 48'h000010240000,
    end_addr: 48'h000010280000},// ClusterX2Y1
'{    idx: '{x: 3, y: 0, port_id: 0},
    start_addr: 48'h000010200000,
    end_addr: 48'h000010240000},// ClusterX2Y0
'{    idx: '{x: 2, y: 3, port_id: 0},
    start_addr: 48'h0000101c0000,
    end_addr: 48'h000010200000},// ClusterX1Y3
'{    idx: '{x: 2, y: 2, port_id: 0},
    start_addr: 48'h000010180000,
    end_addr: 48'h0000101c0000},// ClusterX1Y2
'{    idx: '{x: 2, y: 1, port_id: 0},
    start_addr: 48'h000010140000,
    end_addr: 48'h000010180000},// ClusterX1Y1
'{    idx: '{x: 2, y: 0, port_id: 0},
    start_addr: 48'h000010100000,
    end_addr: 48'h000010140000},// ClusterX1Y0
'{    idx: '{x: 1, y: 3, port_id: 0},
    start_addr: 48'h0000100c0000,
    end_addr: 48'h000010100000},// ClusterX0Y3
'{    idx: '{x: 1, y: 2, port_id: 0},
    start_addr: 48'h000010080000,
    end_addr: 48'h0000100c0000},// ClusterX0Y2
'{    idx: '{x: 1, y: 1, port_id: 0},
    start_addr: 48'h000010040000,
    end_addr: 48'h000010080000},// ClusterX0Y1
'{    idx: '{x: 1, y: 0, port_id: 0},
    start_addr: 48'h000010000000,
    end_addr: 48'h000010040000} // ClusterX0Y0

};



  localparam route_cfg_t RouteCfg = '{    RouteAlgo: XYRouting,
    UseIdTable: 1'b1,
    XYAddrOffsetX: 33,
    XYAddrOffsetY: 36,
    IdAddrOffset: 0,
    NumSamRules: 20,
    NumRoutes: 0,
    EnMultiCast: 1'b0,
    EnParallelReduction: 1'b0,
    EnNarrowOffloadReduction: 1'b0,
    EnWideOffloadReduction: 1'b0};


    typedef logic[47:0] axi_narrow_in_addr_t;
typedef logic[63:0] axi_narrow_in_data_t;
typedef logic[7:0] axi_narrow_in_strb_t;
typedef logic[3:0] axi_narrow_in_id_t;
typedef logic[0:0] axi_narrow_in_user_t;
`AXI_TYPEDEF_ALL_CT(axi_narrow_in,             axi_narrow_in_req_t,             axi_narrow_in_rsp_t,             axi_narrow_in_addr_t,             axi_narrow_in_id_t,             axi_narrow_in_data_t,             axi_narrow_in_strb_t,             axi_narrow_in_user_t)


    typedef logic[47:0] axi_narrow_out_addr_t;
typedef logic[63:0] axi_narrow_out_data_t;
typedef logic[7:0] axi_narrow_out_strb_t;
typedef logic[1:0] axi_narrow_out_id_t;
typedef logic[0:0] axi_narrow_out_user_t;
`AXI_TYPEDEF_ALL_CT(axi_narrow_out,             axi_narrow_out_req_t,             axi_narrow_out_rsp_t,             axi_narrow_out_addr_t,             axi_narrow_out_id_t,             axi_narrow_out_data_t,             axi_narrow_out_strb_t,             axi_narrow_out_user_t)


    typedef logic[47:0] axi_wide_in_addr_t;
typedef logic[511:0] axi_wide_in_data_t;
typedef logic[63:0] axi_wide_in_strb_t;
typedef logic[2:0] axi_wide_in_id_t;
typedef logic[0:0] axi_wide_in_user_t;
`AXI_TYPEDEF_ALL_CT(axi_wide_in,             axi_wide_in_req_t,             axi_wide_in_rsp_t,             axi_wide_in_addr_t,             axi_wide_in_id_t,             axi_wide_in_data_t,             axi_wide_in_strb_t,             axi_wide_in_user_t)


    typedef logic[47:0] axi_wide_out_addr_t;
typedef logic[511:0] axi_wide_out_data_t;
typedef logic[63:0] axi_wide_out_strb_t;
typedef logic[0:0] axi_wide_out_id_t;
typedef logic[0:0] axi_wide_out_user_t;
`AXI_TYPEDEF_ALL_CT(axi_wide_out,             axi_wide_out_req_t,             axi_wide_out_rsp_t,             axi_wide_out_addr_t,             axi_wide_out_id_t,             axi_wide_out_data_t,             axi_wide_out_strb_t,             axi_wide_out_user_t)



  `FLOO_TYPEDEF_HDR_T(hdr_t, id_t, id_t, nw_ch_e, rob_idx_t)
  localparam axi_cfg_t AxiCfgN = '{    AddrWidth: 48,
    DataWidth: 64,
    InIdWidth: 4,
    OutIdWidth: 2,
    UserWidth: 1};
localparam axi_cfg_t AxiCfgW = '{    AddrWidth: 48,
    DataWidth: 512,
    InIdWidth: 3,
    OutIdWidth: 1,
    UserWidth: 1};
`FLOO_TYPEDEF_NW_CHAN_ALL(axi, req, rsp, wide,             axi_narrow_in, axi_wide_in, AxiCfgN, AxiCfgW, hdr_t)

`FLOO_TYPEDEF_NW_LINK_ALL(req, rsp, wide, req, rsp, wide)


endpackage
