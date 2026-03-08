// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// AUTOMATICALLY GENERATED! DO NOT EDIT!

module floo_floonoc_mesh_noc
  import floo_pkg::*;
  import floo_floonoc_mesh_noc_pkg::*;
(
  input logic clk_i,
  input logic rst_ni,
  input logic test_enable_i,
  input axi_narrow_in_req_t             [3:0][3:0] cluster_narrow_in_req_i,
  output axi_narrow_in_rsp_t             [3:0][3:0] cluster_narrow_in_rsp_o,
  input axi_wide_in_req_t             [3:0][3:0] cluster_wide_in_req_i,
  output axi_wide_in_rsp_t             [3:0][3:0] cluster_wide_in_rsp_o,
  output axi_narrow_out_req_t             [3:0][3:0] cluster_narrow_out_req_o,
  input axi_narrow_out_rsp_t             [3:0][3:0] cluster_narrow_out_rsp_i,
  output axi_wide_out_req_t             [3:0][3:0] cluster_wide_out_req_o,
  input axi_wide_out_rsp_t             [3:0][3:0] cluster_wide_out_rsp_i,
  output axi_narrow_out_req_t             [3:0] hbm_narrow_out_req_o,
  input axi_narrow_out_rsp_t             [3:0] hbm_narrow_out_rsp_i,
  output axi_wide_out_req_t             [3:0] hbm_wide_out_req_o,
  input axi_wide_out_rsp_t             [3:0] hbm_wide_out_rsp_i

);

floo_req_t router_0_0_to_router_0_1_req;
floo_rsp_t router_0_1_to_router_0_0_rsp;
floo_wide_t router_0_0_to_router_0_1_wide;

floo_req_t router_0_0_to_router_1_0_req;
floo_rsp_t router_1_0_to_router_0_0_rsp;
floo_wide_t router_0_0_to_router_1_0_wide;

floo_req_t router_0_0_to_cluster_ni_0_0_req;
floo_rsp_t cluster_ni_0_0_to_router_0_0_rsp;
floo_wide_t router_0_0_to_cluster_ni_0_0_wide;

floo_req_t router_0_0_to_hbm_ni_0_req;
floo_rsp_t hbm_ni_0_to_router_0_0_rsp;
floo_wide_t router_0_0_to_hbm_ni_0_wide;

floo_req_t router_0_1_to_router_0_0_req;
floo_rsp_t router_0_0_to_router_0_1_rsp;
floo_wide_t router_0_1_to_router_0_0_wide;

floo_req_t router_0_1_to_router_0_2_req;
floo_rsp_t router_0_2_to_router_0_1_rsp;
floo_wide_t router_0_1_to_router_0_2_wide;

floo_req_t router_0_1_to_router_1_1_req;
floo_rsp_t router_1_1_to_router_0_1_rsp;
floo_wide_t router_0_1_to_router_1_1_wide;

floo_req_t router_0_1_to_cluster_ni_0_1_req;
floo_rsp_t cluster_ni_0_1_to_router_0_1_rsp;
floo_wide_t router_0_1_to_cluster_ni_0_1_wide;

floo_req_t router_0_1_to_hbm_ni_1_req;
floo_rsp_t hbm_ni_1_to_router_0_1_rsp;
floo_wide_t router_0_1_to_hbm_ni_1_wide;

floo_req_t router_0_2_to_router_0_1_req;
floo_rsp_t router_0_1_to_router_0_2_rsp;
floo_wide_t router_0_2_to_router_0_1_wide;

floo_req_t router_0_2_to_router_0_3_req;
floo_rsp_t router_0_3_to_router_0_2_rsp;
floo_wide_t router_0_2_to_router_0_3_wide;

floo_req_t router_0_2_to_router_1_2_req;
floo_rsp_t router_1_2_to_router_0_2_rsp;
floo_wide_t router_0_2_to_router_1_2_wide;

floo_req_t router_0_2_to_cluster_ni_0_2_req;
floo_rsp_t cluster_ni_0_2_to_router_0_2_rsp;
floo_wide_t router_0_2_to_cluster_ni_0_2_wide;

floo_req_t router_0_2_to_hbm_ni_2_req;
floo_rsp_t hbm_ni_2_to_router_0_2_rsp;
floo_wide_t router_0_2_to_hbm_ni_2_wide;

floo_req_t router_0_3_to_router_0_2_req;
floo_rsp_t router_0_2_to_router_0_3_rsp;
floo_wide_t router_0_3_to_router_0_2_wide;

floo_req_t router_0_3_to_router_1_3_req;
floo_rsp_t router_1_3_to_router_0_3_rsp;
floo_wide_t router_0_3_to_router_1_3_wide;

floo_req_t router_0_3_to_cluster_ni_0_3_req;
floo_rsp_t cluster_ni_0_3_to_router_0_3_rsp;
floo_wide_t router_0_3_to_cluster_ni_0_3_wide;

floo_req_t router_0_3_to_hbm_ni_3_req;
floo_rsp_t hbm_ni_3_to_router_0_3_rsp;
floo_wide_t router_0_3_to_hbm_ni_3_wide;

floo_req_t router_1_0_to_router_0_0_req;
floo_rsp_t router_0_0_to_router_1_0_rsp;
floo_wide_t router_1_0_to_router_0_0_wide;

floo_req_t router_1_0_to_router_1_1_req;
floo_rsp_t router_1_1_to_router_1_0_rsp;
floo_wide_t router_1_0_to_router_1_1_wide;

floo_req_t router_1_0_to_router_2_0_req;
floo_rsp_t router_2_0_to_router_1_0_rsp;
floo_wide_t router_1_0_to_router_2_0_wide;

floo_req_t router_1_0_to_cluster_ni_1_0_req;
floo_rsp_t cluster_ni_1_0_to_router_1_0_rsp;
floo_wide_t router_1_0_to_cluster_ni_1_0_wide;

floo_req_t router_1_1_to_router_0_1_req;
floo_rsp_t router_0_1_to_router_1_1_rsp;
floo_wide_t router_1_1_to_router_0_1_wide;

floo_req_t router_1_1_to_router_1_0_req;
floo_rsp_t router_1_0_to_router_1_1_rsp;
floo_wide_t router_1_1_to_router_1_0_wide;

floo_req_t router_1_1_to_router_1_2_req;
floo_rsp_t router_1_2_to_router_1_1_rsp;
floo_wide_t router_1_1_to_router_1_2_wide;

floo_req_t router_1_1_to_router_2_1_req;
floo_rsp_t router_2_1_to_router_1_1_rsp;
floo_wide_t router_1_1_to_router_2_1_wide;

floo_req_t router_1_1_to_cluster_ni_1_1_req;
floo_rsp_t cluster_ni_1_1_to_router_1_1_rsp;
floo_wide_t router_1_1_to_cluster_ni_1_1_wide;

floo_req_t router_1_2_to_router_0_2_req;
floo_rsp_t router_0_2_to_router_1_2_rsp;
floo_wide_t router_1_2_to_router_0_2_wide;

floo_req_t router_1_2_to_router_1_1_req;
floo_rsp_t router_1_1_to_router_1_2_rsp;
floo_wide_t router_1_2_to_router_1_1_wide;

floo_req_t router_1_2_to_router_1_3_req;
floo_rsp_t router_1_3_to_router_1_2_rsp;
floo_wide_t router_1_2_to_router_1_3_wide;

floo_req_t router_1_2_to_router_2_2_req;
floo_rsp_t router_2_2_to_router_1_2_rsp;
floo_wide_t router_1_2_to_router_2_2_wide;

floo_req_t router_1_2_to_cluster_ni_1_2_req;
floo_rsp_t cluster_ni_1_2_to_router_1_2_rsp;
floo_wide_t router_1_2_to_cluster_ni_1_2_wide;

floo_req_t router_1_3_to_router_0_3_req;
floo_rsp_t router_0_3_to_router_1_3_rsp;
floo_wide_t router_1_3_to_router_0_3_wide;

floo_req_t router_1_3_to_router_1_2_req;
floo_rsp_t router_1_2_to_router_1_3_rsp;
floo_wide_t router_1_3_to_router_1_2_wide;

floo_req_t router_1_3_to_router_2_3_req;
floo_rsp_t router_2_3_to_router_1_3_rsp;
floo_wide_t router_1_3_to_router_2_3_wide;

floo_req_t router_1_3_to_cluster_ni_1_3_req;
floo_rsp_t cluster_ni_1_3_to_router_1_3_rsp;
floo_wide_t router_1_3_to_cluster_ni_1_3_wide;

floo_req_t router_2_0_to_router_1_0_req;
floo_rsp_t router_1_0_to_router_2_0_rsp;
floo_wide_t router_2_0_to_router_1_0_wide;

floo_req_t router_2_0_to_router_2_1_req;
floo_rsp_t router_2_1_to_router_2_0_rsp;
floo_wide_t router_2_0_to_router_2_1_wide;

floo_req_t router_2_0_to_router_3_0_req;
floo_rsp_t router_3_0_to_router_2_0_rsp;
floo_wide_t router_2_0_to_router_3_0_wide;

floo_req_t router_2_0_to_cluster_ni_2_0_req;
floo_rsp_t cluster_ni_2_0_to_router_2_0_rsp;
floo_wide_t router_2_0_to_cluster_ni_2_0_wide;

floo_req_t router_2_1_to_router_1_1_req;
floo_rsp_t router_1_1_to_router_2_1_rsp;
floo_wide_t router_2_1_to_router_1_1_wide;

floo_req_t router_2_1_to_router_2_0_req;
floo_rsp_t router_2_0_to_router_2_1_rsp;
floo_wide_t router_2_1_to_router_2_0_wide;

floo_req_t router_2_1_to_router_2_2_req;
floo_rsp_t router_2_2_to_router_2_1_rsp;
floo_wide_t router_2_1_to_router_2_2_wide;

floo_req_t router_2_1_to_router_3_1_req;
floo_rsp_t router_3_1_to_router_2_1_rsp;
floo_wide_t router_2_1_to_router_3_1_wide;

floo_req_t router_2_1_to_cluster_ni_2_1_req;
floo_rsp_t cluster_ni_2_1_to_router_2_1_rsp;
floo_wide_t router_2_1_to_cluster_ni_2_1_wide;

floo_req_t router_2_2_to_router_1_2_req;
floo_rsp_t router_1_2_to_router_2_2_rsp;
floo_wide_t router_2_2_to_router_1_2_wide;

floo_req_t router_2_2_to_router_2_1_req;
floo_rsp_t router_2_1_to_router_2_2_rsp;
floo_wide_t router_2_2_to_router_2_1_wide;

floo_req_t router_2_2_to_router_2_3_req;
floo_rsp_t router_2_3_to_router_2_2_rsp;
floo_wide_t router_2_2_to_router_2_3_wide;

floo_req_t router_2_2_to_router_3_2_req;
floo_rsp_t router_3_2_to_router_2_2_rsp;
floo_wide_t router_2_2_to_router_3_2_wide;

floo_req_t router_2_2_to_cluster_ni_2_2_req;
floo_rsp_t cluster_ni_2_2_to_router_2_2_rsp;
floo_wide_t router_2_2_to_cluster_ni_2_2_wide;

floo_req_t router_2_3_to_router_1_3_req;
floo_rsp_t router_1_3_to_router_2_3_rsp;
floo_wide_t router_2_3_to_router_1_3_wide;

floo_req_t router_2_3_to_router_2_2_req;
floo_rsp_t router_2_2_to_router_2_3_rsp;
floo_wide_t router_2_3_to_router_2_2_wide;

floo_req_t router_2_3_to_router_3_3_req;
floo_rsp_t router_3_3_to_router_2_3_rsp;
floo_wide_t router_2_3_to_router_3_3_wide;

floo_req_t router_2_3_to_cluster_ni_2_3_req;
floo_rsp_t cluster_ni_2_3_to_router_2_3_rsp;
floo_wide_t router_2_3_to_cluster_ni_2_3_wide;

floo_req_t router_3_0_to_router_2_0_req;
floo_rsp_t router_2_0_to_router_3_0_rsp;
floo_wide_t router_3_0_to_router_2_0_wide;

floo_req_t router_3_0_to_router_3_1_req;
floo_rsp_t router_3_1_to_router_3_0_rsp;
floo_wide_t router_3_0_to_router_3_1_wide;

floo_req_t router_3_0_to_cluster_ni_3_0_req;
floo_rsp_t cluster_ni_3_0_to_router_3_0_rsp;
floo_wide_t router_3_0_to_cluster_ni_3_0_wide;

floo_req_t router_3_1_to_router_2_1_req;
floo_rsp_t router_2_1_to_router_3_1_rsp;
floo_wide_t router_3_1_to_router_2_1_wide;

floo_req_t router_3_1_to_router_3_0_req;
floo_rsp_t router_3_0_to_router_3_1_rsp;
floo_wide_t router_3_1_to_router_3_0_wide;

floo_req_t router_3_1_to_router_3_2_req;
floo_rsp_t router_3_2_to_router_3_1_rsp;
floo_wide_t router_3_1_to_router_3_2_wide;

floo_req_t router_3_1_to_cluster_ni_3_1_req;
floo_rsp_t cluster_ni_3_1_to_router_3_1_rsp;
floo_wide_t router_3_1_to_cluster_ni_3_1_wide;

floo_req_t router_3_2_to_router_2_2_req;
floo_rsp_t router_2_2_to_router_3_2_rsp;
floo_wide_t router_3_2_to_router_2_2_wide;

floo_req_t router_3_2_to_router_3_1_req;
floo_rsp_t router_3_1_to_router_3_2_rsp;
floo_wide_t router_3_2_to_router_3_1_wide;

floo_req_t router_3_2_to_router_3_3_req;
floo_rsp_t router_3_3_to_router_3_2_rsp;
floo_wide_t router_3_2_to_router_3_3_wide;

floo_req_t router_3_2_to_cluster_ni_3_2_req;
floo_rsp_t cluster_ni_3_2_to_router_3_2_rsp;
floo_wide_t router_3_2_to_cluster_ni_3_2_wide;

floo_req_t router_3_3_to_router_2_3_req;
floo_rsp_t router_2_3_to_router_3_3_rsp;
floo_wide_t router_3_3_to_router_2_3_wide;

floo_req_t router_3_3_to_router_3_2_req;
floo_rsp_t router_3_2_to_router_3_3_rsp;
floo_wide_t router_3_3_to_router_3_2_wide;

floo_req_t router_3_3_to_cluster_ni_3_3_req;
floo_rsp_t cluster_ni_3_3_to_router_3_3_rsp;
floo_wide_t router_3_3_to_cluster_ni_3_3_wide;

floo_req_t cluster_ni_0_0_to_router_0_0_req;
floo_rsp_t router_0_0_to_cluster_ni_0_0_rsp;
floo_wide_t cluster_ni_0_0_to_router_0_0_wide;

floo_req_t cluster_ni_0_1_to_router_0_1_req;
floo_rsp_t router_0_1_to_cluster_ni_0_1_rsp;
floo_wide_t cluster_ni_0_1_to_router_0_1_wide;

floo_req_t cluster_ni_0_2_to_router_0_2_req;
floo_rsp_t router_0_2_to_cluster_ni_0_2_rsp;
floo_wide_t cluster_ni_0_2_to_router_0_2_wide;

floo_req_t cluster_ni_0_3_to_router_0_3_req;
floo_rsp_t router_0_3_to_cluster_ni_0_3_rsp;
floo_wide_t cluster_ni_0_3_to_router_0_3_wide;

floo_req_t cluster_ni_1_0_to_router_1_0_req;
floo_rsp_t router_1_0_to_cluster_ni_1_0_rsp;
floo_wide_t cluster_ni_1_0_to_router_1_0_wide;

floo_req_t cluster_ni_1_1_to_router_1_1_req;
floo_rsp_t router_1_1_to_cluster_ni_1_1_rsp;
floo_wide_t cluster_ni_1_1_to_router_1_1_wide;

floo_req_t cluster_ni_1_2_to_router_1_2_req;
floo_rsp_t router_1_2_to_cluster_ni_1_2_rsp;
floo_wide_t cluster_ni_1_2_to_router_1_2_wide;

floo_req_t cluster_ni_1_3_to_router_1_3_req;
floo_rsp_t router_1_3_to_cluster_ni_1_3_rsp;
floo_wide_t cluster_ni_1_3_to_router_1_3_wide;

floo_req_t cluster_ni_2_0_to_router_2_0_req;
floo_rsp_t router_2_0_to_cluster_ni_2_0_rsp;
floo_wide_t cluster_ni_2_0_to_router_2_0_wide;

floo_req_t cluster_ni_2_1_to_router_2_1_req;
floo_rsp_t router_2_1_to_cluster_ni_2_1_rsp;
floo_wide_t cluster_ni_2_1_to_router_2_1_wide;

floo_req_t cluster_ni_2_2_to_router_2_2_req;
floo_rsp_t router_2_2_to_cluster_ni_2_2_rsp;
floo_wide_t cluster_ni_2_2_to_router_2_2_wide;

floo_req_t cluster_ni_2_3_to_router_2_3_req;
floo_rsp_t router_2_3_to_cluster_ni_2_3_rsp;
floo_wide_t cluster_ni_2_3_to_router_2_3_wide;

floo_req_t cluster_ni_3_0_to_router_3_0_req;
floo_rsp_t router_3_0_to_cluster_ni_3_0_rsp;
floo_wide_t cluster_ni_3_0_to_router_3_0_wide;

floo_req_t cluster_ni_3_1_to_router_3_1_req;
floo_rsp_t router_3_1_to_cluster_ni_3_1_rsp;
floo_wide_t cluster_ni_3_1_to_router_3_1_wide;

floo_req_t cluster_ni_3_2_to_router_3_2_req;
floo_rsp_t router_3_2_to_cluster_ni_3_2_rsp;
floo_wide_t cluster_ni_3_2_to_router_3_2_wide;

floo_req_t cluster_ni_3_3_to_router_3_3_req;
floo_rsp_t router_3_3_to_cluster_ni_3_3_rsp;
floo_wide_t cluster_ni_3_3_to_router_3_3_wide;

floo_req_t hbm_ni_0_to_router_0_0_req;
floo_rsp_t router_0_0_to_hbm_ni_0_rsp;
floo_wide_t hbm_ni_0_to_router_0_0_wide;

floo_req_t hbm_ni_1_to_router_0_1_req;
floo_rsp_t router_0_1_to_hbm_ni_1_rsp;
floo_wide_t hbm_ni_1_to_router_0_1_wide;

floo_req_t hbm_ni_2_to_router_0_2_req;
floo_rsp_t router_0_2_to_hbm_ni_2_rsp;
floo_wide_t hbm_ni_2_to_router_0_2_wide;

floo_req_t hbm_ni_3_to_router_0_3_req;
floo_rsp_t router_0_3_to_hbm_ni_3_rsp;
floo_wide_t hbm_ni_3_to_router_0_3_wide;



  localparam id_t CLUSTER_NI_0_0_ID = '{x: 1, y: 0, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_0_0 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[0][0] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[0][0] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[0][0] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[0][0] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[0][0] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[0][0] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[0][0] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[0][0] ),
  .id_i             ( CLUSTER_NI_0_0_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_0_0_to_router_0_0_req   ),
  .floo_rsp_i       ( router_0_0_to_cluster_ni_0_0_rsp   ),
  .floo_wide_o      ( cluster_ni_0_0_to_router_0_0_wide  ),
  .floo_req_i       ( router_0_0_to_cluster_ni_0_0_req   ),
  .floo_rsp_o       ( cluster_ni_0_0_to_router_0_0_rsp   ),
  .floo_wide_i      ( router_0_0_to_cluster_ni_0_0_wide  )
);

  localparam id_t CLUSTER_NI_0_1_ID = '{x: 1, y: 1, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_0_1 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[0][1] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[0][1] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[0][1] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[0][1] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[0][1] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[0][1] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[0][1] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[0][1] ),
  .id_i             ( CLUSTER_NI_0_1_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_0_1_to_router_0_1_req   ),
  .floo_rsp_i       ( router_0_1_to_cluster_ni_0_1_rsp   ),
  .floo_wide_o      ( cluster_ni_0_1_to_router_0_1_wide  ),
  .floo_req_i       ( router_0_1_to_cluster_ni_0_1_req   ),
  .floo_rsp_o       ( cluster_ni_0_1_to_router_0_1_rsp   ),
  .floo_wide_i      ( router_0_1_to_cluster_ni_0_1_wide  )
);

  localparam id_t CLUSTER_NI_0_2_ID = '{x: 1, y: 2, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_0_2 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[0][2] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[0][2] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[0][2] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[0][2] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[0][2] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[0][2] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[0][2] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[0][2] ),
  .id_i             ( CLUSTER_NI_0_2_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_0_2_to_router_0_2_req   ),
  .floo_rsp_i       ( router_0_2_to_cluster_ni_0_2_rsp   ),
  .floo_wide_o      ( cluster_ni_0_2_to_router_0_2_wide  ),
  .floo_req_i       ( router_0_2_to_cluster_ni_0_2_req   ),
  .floo_rsp_o       ( cluster_ni_0_2_to_router_0_2_rsp   ),
  .floo_wide_i      ( router_0_2_to_cluster_ni_0_2_wide  )
);

  localparam id_t CLUSTER_NI_0_3_ID = '{x: 1, y: 3, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_0_3 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[0][3] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[0][3] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[0][3] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[0][3] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[0][3] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[0][3] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[0][3] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[0][3] ),
  .id_i             ( CLUSTER_NI_0_3_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_0_3_to_router_0_3_req   ),
  .floo_rsp_i       ( router_0_3_to_cluster_ni_0_3_rsp   ),
  .floo_wide_o      ( cluster_ni_0_3_to_router_0_3_wide  ),
  .floo_req_i       ( router_0_3_to_cluster_ni_0_3_req   ),
  .floo_rsp_o       ( cluster_ni_0_3_to_router_0_3_rsp   ),
  .floo_wide_i      ( router_0_3_to_cluster_ni_0_3_wide  )
);

  localparam id_t CLUSTER_NI_1_0_ID = '{x: 2, y: 0, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_1_0 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[1][0] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[1][0] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[1][0] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[1][0] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[1][0] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[1][0] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[1][0] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[1][0] ),
  .id_i             ( CLUSTER_NI_1_0_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_1_0_to_router_1_0_req   ),
  .floo_rsp_i       ( router_1_0_to_cluster_ni_1_0_rsp   ),
  .floo_wide_o      ( cluster_ni_1_0_to_router_1_0_wide  ),
  .floo_req_i       ( router_1_0_to_cluster_ni_1_0_req   ),
  .floo_rsp_o       ( cluster_ni_1_0_to_router_1_0_rsp   ),
  .floo_wide_i      ( router_1_0_to_cluster_ni_1_0_wide  )
);

  localparam id_t CLUSTER_NI_1_1_ID = '{x: 2, y: 1, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_1_1 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[1][1] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[1][1] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[1][1] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[1][1] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[1][1] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[1][1] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[1][1] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[1][1] ),
  .id_i             ( CLUSTER_NI_1_1_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_1_1_to_router_1_1_req   ),
  .floo_rsp_i       ( router_1_1_to_cluster_ni_1_1_rsp   ),
  .floo_wide_o      ( cluster_ni_1_1_to_router_1_1_wide  ),
  .floo_req_i       ( router_1_1_to_cluster_ni_1_1_req   ),
  .floo_rsp_o       ( cluster_ni_1_1_to_router_1_1_rsp   ),
  .floo_wide_i      ( router_1_1_to_cluster_ni_1_1_wide  )
);

  localparam id_t CLUSTER_NI_1_2_ID = '{x: 2, y: 2, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_1_2 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[1][2] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[1][2] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[1][2] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[1][2] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[1][2] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[1][2] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[1][2] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[1][2] ),
  .id_i             ( CLUSTER_NI_1_2_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_1_2_to_router_1_2_req   ),
  .floo_rsp_i       ( router_1_2_to_cluster_ni_1_2_rsp   ),
  .floo_wide_o      ( cluster_ni_1_2_to_router_1_2_wide  ),
  .floo_req_i       ( router_1_2_to_cluster_ni_1_2_req   ),
  .floo_rsp_o       ( cluster_ni_1_2_to_router_1_2_rsp   ),
  .floo_wide_i      ( router_1_2_to_cluster_ni_1_2_wide  )
);

  localparam id_t CLUSTER_NI_1_3_ID = '{x: 2, y: 3, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_1_3 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[1][3] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[1][3] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[1][3] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[1][3] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[1][3] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[1][3] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[1][3] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[1][3] ),
  .id_i             ( CLUSTER_NI_1_3_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_1_3_to_router_1_3_req   ),
  .floo_rsp_i       ( router_1_3_to_cluster_ni_1_3_rsp   ),
  .floo_wide_o      ( cluster_ni_1_3_to_router_1_3_wide  ),
  .floo_req_i       ( router_1_3_to_cluster_ni_1_3_req   ),
  .floo_rsp_o       ( cluster_ni_1_3_to_router_1_3_rsp   ),
  .floo_wide_i      ( router_1_3_to_cluster_ni_1_3_wide  )
);

  localparam id_t CLUSTER_NI_2_0_ID = '{x: 3, y: 0, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_2_0 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[2][0] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[2][0] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[2][0] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[2][0] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[2][0] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[2][0] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[2][0] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[2][0] ),
  .id_i             ( CLUSTER_NI_2_0_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_2_0_to_router_2_0_req   ),
  .floo_rsp_i       ( router_2_0_to_cluster_ni_2_0_rsp   ),
  .floo_wide_o      ( cluster_ni_2_0_to_router_2_0_wide  ),
  .floo_req_i       ( router_2_0_to_cluster_ni_2_0_req   ),
  .floo_rsp_o       ( cluster_ni_2_0_to_router_2_0_rsp   ),
  .floo_wide_i      ( router_2_0_to_cluster_ni_2_0_wide  )
);

  localparam id_t CLUSTER_NI_2_1_ID = '{x: 3, y: 1, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_2_1 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[2][1] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[2][1] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[2][1] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[2][1] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[2][1] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[2][1] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[2][1] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[2][1] ),
  .id_i             ( CLUSTER_NI_2_1_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_2_1_to_router_2_1_req   ),
  .floo_rsp_i       ( router_2_1_to_cluster_ni_2_1_rsp   ),
  .floo_wide_o      ( cluster_ni_2_1_to_router_2_1_wide  ),
  .floo_req_i       ( router_2_1_to_cluster_ni_2_1_req   ),
  .floo_rsp_o       ( cluster_ni_2_1_to_router_2_1_rsp   ),
  .floo_wide_i      ( router_2_1_to_cluster_ni_2_1_wide  )
);

  localparam id_t CLUSTER_NI_2_2_ID = '{x: 3, y: 2, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_2_2 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[2][2] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[2][2] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[2][2] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[2][2] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[2][2] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[2][2] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[2][2] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[2][2] ),
  .id_i             ( CLUSTER_NI_2_2_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_2_2_to_router_2_2_req   ),
  .floo_rsp_i       ( router_2_2_to_cluster_ni_2_2_rsp   ),
  .floo_wide_o      ( cluster_ni_2_2_to_router_2_2_wide  ),
  .floo_req_i       ( router_2_2_to_cluster_ni_2_2_req   ),
  .floo_rsp_o       ( cluster_ni_2_2_to_router_2_2_rsp   ),
  .floo_wide_i      ( router_2_2_to_cluster_ni_2_2_wide  )
);

  localparam id_t CLUSTER_NI_2_3_ID = '{x: 3, y: 3, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_2_3 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[2][3] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[2][3] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[2][3] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[2][3] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[2][3] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[2][3] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[2][3] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[2][3] ),
  .id_i             ( CLUSTER_NI_2_3_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_2_3_to_router_2_3_req   ),
  .floo_rsp_i       ( router_2_3_to_cluster_ni_2_3_rsp   ),
  .floo_wide_o      ( cluster_ni_2_3_to_router_2_3_wide  ),
  .floo_req_i       ( router_2_3_to_cluster_ni_2_3_req   ),
  .floo_rsp_o       ( cluster_ni_2_3_to_router_2_3_rsp   ),
  .floo_wide_i      ( router_2_3_to_cluster_ni_2_3_wide  )
);

  localparam id_t CLUSTER_NI_3_0_ID = '{x: 4, y: 0, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_3_0 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[3][0] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[3][0] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[3][0] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[3][0] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[3][0] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[3][0] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[3][0] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[3][0] ),
  .id_i             ( CLUSTER_NI_3_0_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_3_0_to_router_3_0_req   ),
  .floo_rsp_i       ( router_3_0_to_cluster_ni_3_0_rsp   ),
  .floo_wide_o      ( cluster_ni_3_0_to_router_3_0_wide  ),
  .floo_req_i       ( router_3_0_to_cluster_ni_3_0_req   ),
  .floo_rsp_o       ( cluster_ni_3_0_to_router_3_0_rsp   ),
  .floo_wide_i      ( router_3_0_to_cluster_ni_3_0_wide  )
);

  localparam id_t CLUSTER_NI_3_1_ID = '{x: 4, y: 1, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_3_1 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[3][1] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[3][1] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[3][1] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[3][1] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[3][1] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[3][1] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[3][1] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[3][1] ),
  .id_i             ( CLUSTER_NI_3_1_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_3_1_to_router_3_1_req   ),
  .floo_rsp_i       ( router_3_1_to_cluster_ni_3_1_rsp   ),
  .floo_wide_o      ( cluster_ni_3_1_to_router_3_1_wide  ),
  .floo_req_i       ( router_3_1_to_cluster_ni_3_1_req   ),
  .floo_rsp_o       ( cluster_ni_3_1_to_router_3_1_rsp   ),
  .floo_wide_i      ( router_3_1_to_cluster_ni_3_1_wide  )
);

  localparam id_t CLUSTER_NI_3_2_ID = '{x: 4, y: 2, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_3_2 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[3][2] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[3][2] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[3][2] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[3][2] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[3][2] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[3][2] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[3][2] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[3][2] ),
  .id_i             ( CLUSTER_NI_3_2_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_3_2_to_router_3_2_req   ),
  .floo_rsp_i       ( router_3_2_to_cluster_ni_3_2_rsp   ),
  .floo_wide_o      ( cluster_ni_3_2_to_router_3_2_wide  ),
  .floo_req_i       ( router_3_2_to_cluster_ni_3_2_req   ),
  .floo_rsp_o       ( cluster_ni_3_2_to_router_3_2_rsp   ),
  .floo_wide_i      ( router_3_2_to_cluster_ni_3_2_wide  )
);

  localparam id_t CLUSTER_NI_3_3_ID = '{x: 4, y: 3, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b1)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) cluster_ni_3_3 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( cluster_narrow_in_req_i[3][3] ),
  .axi_narrow_in_rsp_o  ( cluster_narrow_in_rsp_o[3][3] ),
  .axi_narrow_out_req_o ( cluster_narrow_out_req_o[3][3] ),
  .axi_narrow_out_rsp_i ( cluster_narrow_out_rsp_i[3][3] ),
  .axi_wide_in_req_i  ( cluster_wide_in_req_i[3][3] ),
  .axi_wide_in_rsp_o  ( cluster_wide_in_rsp_o[3][3] ),
  .axi_wide_out_req_o ( cluster_wide_out_req_o[3][3] ),
  .axi_wide_out_rsp_i ( cluster_wide_out_rsp_i[3][3] ),
  .id_i             ( CLUSTER_NI_3_3_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( cluster_ni_3_3_to_router_3_3_req   ),
  .floo_rsp_i       ( router_3_3_to_cluster_ni_3_3_rsp   ),
  .floo_wide_o      ( cluster_ni_3_3_to_router_3_3_wide  ),
  .floo_req_i       ( router_3_3_to_cluster_ni_3_3_req   ),
  .floo_rsp_o       ( cluster_ni_3_3_to_router_3_3_rsp   ),
  .floo_wide_i      ( router_3_3_to_cluster_ni_3_3_wide  )
);

  localparam id_t HBM_NI_0_ID = '{x: 0, y: 0, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b0)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b0)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) hbm_ni_0 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( '0 ),
  .axi_narrow_in_rsp_o  (    ),
  .axi_narrow_out_req_o ( hbm_narrow_out_req_o[0] ),
  .axi_narrow_out_rsp_i ( hbm_narrow_out_rsp_i[0] ),
  .axi_wide_in_req_i  ( '0 ),
  .axi_wide_in_rsp_o  (    ),
  .axi_wide_out_req_o ( hbm_wide_out_req_o[0] ),
  .axi_wide_out_rsp_i ( hbm_wide_out_rsp_i[0] ),
  .id_i             ( HBM_NI_0_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( hbm_ni_0_to_router_0_0_req   ),
  .floo_rsp_i       ( router_0_0_to_hbm_ni_0_rsp   ),
  .floo_wide_o      ( hbm_ni_0_to_router_0_0_wide  ),
  .floo_req_i       ( router_0_0_to_hbm_ni_0_req   ),
  .floo_rsp_o       ( hbm_ni_0_to_router_0_0_rsp   ),
  .floo_wide_i      ( router_0_0_to_hbm_ni_0_wide  )
);

  localparam id_t HBM_NI_1_ID = '{x: 0, y: 1, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b0)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b0)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) hbm_ni_1 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( '0 ),
  .axi_narrow_in_rsp_o  (    ),
  .axi_narrow_out_req_o ( hbm_narrow_out_req_o[1] ),
  .axi_narrow_out_rsp_i ( hbm_narrow_out_rsp_i[1] ),
  .axi_wide_in_req_i  ( '0 ),
  .axi_wide_in_rsp_o  (    ),
  .axi_wide_out_req_o ( hbm_wide_out_req_o[1] ),
  .axi_wide_out_rsp_i ( hbm_wide_out_rsp_i[1] ),
  .id_i             ( HBM_NI_1_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( hbm_ni_1_to_router_0_1_req   ),
  .floo_rsp_i       ( router_0_1_to_hbm_ni_1_rsp   ),
  .floo_wide_o      ( hbm_ni_1_to_router_0_1_wide  ),
  .floo_req_i       ( router_0_1_to_hbm_ni_1_req   ),
  .floo_rsp_o       ( hbm_ni_1_to_router_0_1_rsp   ),
  .floo_wide_i      ( router_0_1_to_hbm_ni_1_wide  )
);

  localparam id_t HBM_NI_2_ID = '{x: 0, y: 2, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b0)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b0)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) hbm_ni_2 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( '0 ),
  .axi_narrow_in_rsp_o  (    ),
  .axi_narrow_out_req_o ( hbm_narrow_out_req_o[2] ),
  .axi_narrow_out_rsp_i ( hbm_narrow_out_rsp_i[2] ),
  .axi_wide_in_req_i  ( '0 ),
  .axi_wide_in_rsp_o  (    ),
  .axi_wide_out_req_o ( hbm_wide_out_req_o[2] ),
  .axi_wide_out_rsp_i ( hbm_wide_out_rsp_i[2] ),
  .id_i             ( HBM_NI_2_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( hbm_ni_2_to_router_0_2_req   ),
  .floo_rsp_i       ( router_0_2_to_hbm_ni_2_rsp   ),
  .floo_wide_o      ( hbm_ni_2_to_router_0_2_wide  ),
  .floo_req_i       ( router_0_2_to_hbm_ni_2_req   ),
  .floo_rsp_o       ( hbm_ni_2_to_router_0_2_rsp   ),
  .floo_wide_i      ( router_0_2_to_hbm_ni_2_wide  )
);

  localparam id_t HBM_NI_3_ID = '{x: 0, y: 3, port_id: 0};

floo_nw_chimney  #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .ChimneyCfgN(set_ports(ChimneyDefaultCfg, 1'b1, 1'b0)),
  .ChimneyCfgW(set_ports(ChimneyDefaultCfg, 1'b1, 1'b0)),
  .RouteCfg(RouteCfg),
  .id_t(id_t),
  .rob_idx_t(rob_idx_t),
  .hdr_t  (hdr_t),
  .sam_rule_t(sam_rule_t),
  .Sam(Sam),
  .axi_narrow_in_req_t(axi_narrow_in_req_t),
  .axi_narrow_in_rsp_t(axi_narrow_in_rsp_t),
  .axi_narrow_out_req_t(axi_narrow_out_req_t),
  .axi_narrow_out_rsp_t(axi_narrow_out_rsp_t),
  .axi_wide_in_req_t(axi_wide_in_req_t),
  .axi_wide_in_rsp_t(axi_wide_in_rsp_t),
  .axi_wide_out_req_t(axi_wide_out_req_t),
  .axi_wide_out_rsp_t(axi_wide_out_rsp_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) hbm_ni_3 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .sram_cfg_i ( '0 ),
  .axi_narrow_in_req_i  ( '0 ),
  .axi_narrow_in_rsp_o  (    ),
  .axi_narrow_out_req_o ( hbm_narrow_out_req_o[3] ),
  .axi_narrow_out_rsp_i ( hbm_narrow_out_rsp_i[3] ),
  .axi_wide_in_req_i  ( '0 ),
  .axi_wide_in_rsp_o  (    ),
  .axi_wide_out_req_o ( hbm_wide_out_req_o[3] ),
  .axi_wide_out_rsp_i ( hbm_wide_out_rsp_i[3] ),
  .id_i             ( HBM_NI_3_ID       ),
  .route_table_i    ( '0                          ),
  .floo_req_o       ( hbm_ni_3_to_router_0_3_req   ),
  .floo_rsp_i       ( router_0_3_to_hbm_ni_3_rsp   ),
  .floo_wide_o      ( hbm_ni_3_to_router_0_3_wide  ),
  .floo_req_i       ( router_0_3_to_hbm_ni_3_req   ),
  .floo_rsp_o       ( hbm_ni_3_to_router_0_3_rsp   ),
  .floo_wide_i      ( router_0_3_to_hbm_ni_3_wide  )
);


floo_req_t [4:0] router_0_0_req_in;
floo_rsp_t [4:0] router_0_0_rsp_out;
floo_req_t [4:0] router_0_0_req_out;
floo_rsp_t [4:0] router_0_0_rsp_in;
floo_wide_t [4:0] router_0_0_wide_in;
floo_wide_t [4:0] router_0_0_wide_out;

    assign router_0_0_req_in[0] = router_0_1_to_router_0_0_req;
    assign router_0_0_req_in[1] = router_1_0_to_router_0_0_req;
    assign router_0_0_req_in[2] = '0;
    assign router_0_0_req_in[3] = hbm_ni_0_to_router_0_0_req;
    assign router_0_0_req_in[4] = cluster_ni_0_0_to_router_0_0_req;

    assign router_0_0_to_router_0_1_rsp = router_0_0_rsp_out[0];
    assign router_0_0_to_router_1_0_rsp = router_0_0_rsp_out[1];
    assign router_0_0_to_hbm_ni_0_rsp = router_0_0_rsp_out[3];
    assign router_0_0_to_cluster_ni_0_0_rsp = router_0_0_rsp_out[4];

    assign router_0_0_to_router_0_1_req = router_0_0_req_out[0];
    assign router_0_0_to_router_1_0_req = router_0_0_req_out[1];
    assign router_0_0_to_hbm_ni_0_req = router_0_0_req_out[3];
    assign router_0_0_to_cluster_ni_0_0_req = router_0_0_req_out[4];

    assign router_0_0_rsp_in[0] = router_0_1_to_router_0_0_rsp;
    assign router_0_0_rsp_in[1] = router_1_0_to_router_0_0_rsp;
    assign router_0_0_rsp_in[2] = '0;
    assign router_0_0_rsp_in[3] = hbm_ni_0_to_router_0_0_rsp;
    assign router_0_0_rsp_in[4] = cluster_ni_0_0_to_router_0_0_rsp;

    assign router_0_0_wide_in[0] = router_0_1_to_router_0_0_wide;
    assign router_0_0_wide_in[1] = router_1_0_to_router_0_0_wide;
    assign router_0_0_wide_in[2] = '0;
    assign router_0_0_wide_in[3] = hbm_ni_0_to_router_0_0_wide;
    assign router_0_0_wide_in[4] = cluster_ni_0_0_to_router_0_0_wide;

    assign router_0_0_to_router_0_1_wide = router_0_0_wide_out[0];
    assign router_0_0_to_router_1_0_wide = router_0_0_wide_out[1];
    assign router_0_0_to_hbm_ni_0_wide = router_0_0_wide_out[3];
    assign router_0_0_to_cluster_ni_0_0_wide = router_0_0_wide_out[4];

  localparam id_t ROUTER_0_0_ID = '{x: 1, y: 0, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_0_0 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_0_0_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_0_0_req_in),
  .floo_rsp_o (router_0_0_rsp_out),
  .floo_req_o (router_0_0_req_out),
  .floo_rsp_i (router_0_0_rsp_in),
  .floo_wide_i (router_0_0_wide_in),
  .floo_wide_o (router_0_0_wide_out)
);


floo_req_t [4:0] router_0_1_req_in;
floo_rsp_t [4:0] router_0_1_rsp_out;
floo_req_t [4:0] router_0_1_req_out;
floo_rsp_t [4:0] router_0_1_rsp_in;
floo_wide_t [4:0] router_0_1_wide_in;
floo_wide_t [4:0] router_0_1_wide_out;

    assign router_0_1_req_in[0] = router_0_2_to_router_0_1_req;
    assign router_0_1_req_in[1] = router_1_1_to_router_0_1_req;
    assign router_0_1_req_in[2] = router_0_0_to_router_0_1_req;
    assign router_0_1_req_in[3] = hbm_ni_1_to_router_0_1_req;
    assign router_0_1_req_in[4] = cluster_ni_0_1_to_router_0_1_req;

    assign router_0_1_to_router_0_2_rsp = router_0_1_rsp_out[0];
    assign router_0_1_to_router_1_1_rsp = router_0_1_rsp_out[1];
    assign router_0_1_to_router_0_0_rsp = router_0_1_rsp_out[2];
    assign router_0_1_to_hbm_ni_1_rsp = router_0_1_rsp_out[3];
    assign router_0_1_to_cluster_ni_0_1_rsp = router_0_1_rsp_out[4];

    assign router_0_1_to_router_0_2_req = router_0_1_req_out[0];
    assign router_0_1_to_router_1_1_req = router_0_1_req_out[1];
    assign router_0_1_to_router_0_0_req = router_0_1_req_out[2];
    assign router_0_1_to_hbm_ni_1_req = router_0_1_req_out[3];
    assign router_0_1_to_cluster_ni_0_1_req = router_0_1_req_out[4];

    assign router_0_1_rsp_in[0] = router_0_2_to_router_0_1_rsp;
    assign router_0_1_rsp_in[1] = router_1_1_to_router_0_1_rsp;
    assign router_0_1_rsp_in[2] = router_0_0_to_router_0_1_rsp;
    assign router_0_1_rsp_in[3] = hbm_ni_1_to_router_0_1_rsp;
    assign router_0_1_rsp_in[4] = cluster_ni_0_1_to_router_0_1_rsp;

    assign router_0_1_wide_in[0] = router_0_2_to_router_0_1_wide;
    assign router_0_1_wide_in[1] = router_1_1_to_router_0_1_wide;
    assign router_0_1_wide_in[2] = router_0_0_to_router_0_1_wide;
    assign router_0_1_wide_in[3] = hbm_ni_1_to_router_0_1_wide;
    assign router_0_1_wide_in[4] = cluster_ni_0_1_to_router_0_1_wide;

    assign router_0_1_to_router_0_2_wide = router_0_1_wide_out[0];
    assign router_0_1_to_router_1_1_wide = router_0_1_wide_out[1];
    assign router_0_1_to_router_0_0_wide = router_0_1_wide_out[2];
    assign router_0_1_to_hbm_ni_1_wide = router_0_1_wide_out[3];
    assign router_0_1_to_cluster_ni_0_1_wide = router_0_1_wide_out[4];

  localparam id_t ROUTER_0_1_ID = '{x: 1, y: 1, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_0_1 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_0_1_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_0_1_req_in),
  .floo_rsp_o (router_0_1_rsp_out),
  .floo_req_o (router_0_1_req_out),
  .floo_rsp_i (router_0_1_rsp_in),
  .floo_wide_i (router_0_1_wide_in),
  .floo_wide_o (router_0_1_wide_out)
);


floo_req_t [4:0] router_0_2_req_in;
floo_rsp_t [4:0] router_0_2_rsp_out;
floo_req_t [4:0] router_0_2_req_out;
floo_rsp_t [4:0] router_0_2_rsp_in;
floo_wide_t [4:0] router_0_2_wide_in;
floo_wide_t [4:0] router_0_2_wide_out;

    assign router_0_2_req_in[0] = router_0_3_to_router_0_2_req;
    assign router_0_2_req_in[1] = router_1_2_to_router_0_2_req;
    assign router_0_2_req_in[2] = router_0_1_to_router_0_2_req;
    assign router_0_2_req_in[3] = hbm_ni_2_to_router_0_2_req;
    assign router_0_2_req_in[4] = cluster_ni_0_2_to_router_0_2_req;

    assign router_0_2_to_router_0_3_rsp = router_0_2_rsp_out[0];
    assign router_0_2_to_router_1_2_rsp = router_0_2_rsp_out[1];
    assign router_0_2_to_router_0_1_rsp = router_0_2_rsp_out[2];
    assign router_0_2_to_hbm_ni_2_rsp = router_0_2_rsp_out[3];
    assign router_0_2_to_cluster_ni_0_2_rsp = router_0_2_rsp_out[4];

    assign router_0_2_to_router_0_3_req = router_0_2_req_out[0];
    assign router_0_2_to_router_1_2_req = router_0_2_req_out[1];
    assign router_0_2_to_router_0_1_req = router_0_2_req_out[2];
    assign router_0_2_to_hbm_ni_2_req = router_0_2_req_out[3];
    assign router_0_2_to_cluster_ni_0_2_req = router_0_2_req_out[4];

    assign router_0_2_rsp_in[0] = router_0_3_to_router_0_2_rsp;
    assign router_0_2_rsp_in[1] = router_1_2_to_router_0_2_rsp;
    assign router_0_2_rsp_in[2] = router_0_1_to_router_0_2_rsp;
    assign router_0_2_rsp_in[3] = hbm_ni_2_to_router_0_2_rsp;
    assign router_0_2_rsp_in[4] = cluster_ni_0_2_to_router_0_2_rsp;

    assign router_0_2_wide_in[0] = router_0_3_to_router_0_2_wide;
    assign router_0_2_wide_in[1] = router_1_2_to_router_0_2_wide;
    assign router_0_2_wide_in[2] = router_0_1_to_router_0_2_wide;
    assign router_0_2_wide_in[3] = hbm_ni_2_to_router_0_2_wide;
    assign router_0_2_wide_in[4] = cluster_ni_0_2_to_router_0_2_wide;

    assign router_0_2_to_router_0_3_wide = router_0_2_wide_out[0];
    assign router_0_2_to_router_1_2_wide = router_0_2_wide_out[1];
    assign router_0_2_to_router_0_1_wide = router_0_2_wide_out[2];
    assign router_0_2_to_hbm_ni_2_wide = router_0_2_wide_out[3];
    assign router_0_2_to_cluster_ni_0_2_wide = router_0_2_wide_out[4];

  localparam id_t ROUTER_0_2_ID = '{x: 1, y: 2, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_0_2 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_0_2_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_0_2_req_in),
  .floo_rsp_o (router_0_2_rsp_out),
  .floo_req_o (router_0_2_req_out),
  .floo_rsp_i (router_0_2_rsp_in),
  .floo_wide_i (router_0_2_wide_in),
  .floo_wide_o (router_0_2_wide_out)
);


floo_req_t [4:0] router_0_3_req_in;
floo_rsp_t [4:0] router_0_3_rsp_out;
floo_req_t [4:0] router_0_3_req_out;
floo_rsp_t [4:0] router_0_3_rsp_in;
floo_wide_t [4:0] router_0_3_wide_in;
floo_wide_t [4:0] router_0_3_wide_out;

    assign router_0_3_req_in[0] = '0;
    assign router_0_3_req_in[1] = router_1_3_to_router_0_3_req;
    assign router_0_3_req_in[2] = router_0_2_to_router_0_3_req;
    assign router_0_3_req_in[3] = hbm_ni_3_to_router_0_3_req;
    assign router_0_3_req_in[4] = cluster_ni_0_3_to_router_0_3_req;

    assign router_0_3_to_router_1_3_rsp = router_0_3_rsp_out[1];
    assign router_0_3_to_router_0_2_rsp = router_0_3_rsp_out[2];
    assign router_0_3_to_hbm_ni_3_rsp = router_0_3_rsp_out[3];
    assign router_0_3_to_cluster_ni_0_3_rsp = router_0_3_rsp_out[4];

    assign router_0_3_to_router_1_3_req = router_0_3_req_out[1];
    assign router_0_3_to_router_0_2_req = router_0_3_req_out[2];
    assign router_0_3_to_hbm_ni_3_req = router_0_3_req_out[3];
    assign router_0_3_to_cluster_ni_0_3_req = router_0_3_req_out[4];

    assign router_0_3_rsp_in[0] = '0;
    assign router_0_3_rsp_in[1] = router_1_3_to_router_0_3_rsp;
    assign router_0_3_rsp_in[2] = router_0_2_to_router_0_3_rsp;
    assign router_0_3_rsp_in[3] = hbm_ni_3_to_router_0_3_rsp;
    assign router_0_3_rsp_in[4] = cluster_ni_0_3_to_router_0_3_rsp;

    assign router_0_3_wide_in[0] = '0;
    assign router_0_3_wide_in[1] = router_1_3_to_router_0_3_wide;
    assign router_0_3_wide_in[2] = router_0_2_to_router_0_3_wide;
    assign router_0_3_wide_in[3] = hbm_ni_3_to_router_0_3_wide;
    assign router_0_3_wide_in[4] = cluster_ni_0_3_to_router_0_3_wide;

    assign router_0_3_to_router_1_3_wide = router_0_3_wide_out[1];
    assign router_0_3_to_router_0_2_wide = router_0_3_wide_out[2];
    assign router_0_3_to_hbm_ni_3_wide = router_0_3_wide_out[3];
    assign router_0_3_to_cluster_ni_0_3_wide = router_0_3_wide_out[4];

  localparam id_t ROUTER_0_3_ID = '{x: 1, y: 3, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_0_3 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_0_3_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_0_3_req_in),
  .floo_rsp_o (router_0_3_rsp_out),
  .floo_req_o (router_0_3_req_out),
  .floo_rsp_i (router_0_3_rsp_in),
  .floo_wide_i (router_0_3_wide_in),
  .floo_wide_o (router_0_3_wide_out)
);


floo_req_t [4:0] router_1_0_req_in;
floo_rsp_t [4:0] router_1_0_rsp_out;
floo_req_t [4:0] router_1_0_req_out;
floo_rsp_t [4:0] router_1_0_rsp_in;
floo_wide_t [4:0] router_1_0_wide_in;
floo_wide_t [4:0] router_1_0_wide_out;

    assign router_1_0_req_in[0] = router_1_1_to_router_1_0_req;
    assign router_1_0_req_in[1] = router_2_0_to_router_1_0_req;
    assign router_1_0_req_in[2] = '0;
    assign router_1_0_req_in[3] = router_0_0_to_router_1_0_req;
    assign router_1_0_req_in[4] = cluster_ni_1_0_to_router_1_0_req;

    assign router_1_0_to_router_1_1_rsp = router_1_0_rsp_out[0];
    assign router_1_0_to_router_2_0_rsp = router_1_0_rsp_out[1];
    assign router_1_0_to_router_0_0_rsp = router_1_0_rsp_out[3];
    assign router_1_0_to_cluster_ni_1_0_rsp = router_1_0_rsp_out[4];

    assign router_1_0_to_router_1_1_req = router_1_0_req_out[0];
    assign router_1_0_to_router_2_0_req = router_1_0_req_out[1];
    assign router_1_0_to_router_0_0_req = router_1_0_req_out[3];
    assign router_1_0_to_cluster_ni_1_0_req = router_1_0_req_out[4];

    assign router_1_0_rsp_in[0] = router_1_1_to_router_1_0_rsp;
    assign router_1_0_rsp_in[1] = router_2_0_to_router_1_0_rsp;
    assign router_1_0_rsp_in[2] = '0;
    assign router_1_0_rsp_in[3] = router_0_0_to_router_1_0_rsp;
    assign router_1_0_rsp_in[4] = cluster_ni_1_0_to_router_1_0_rsp;

    assign router_1_0_wide_in[0] = router_1_1_to_router_1_0_wide;
    assign router_1_0_wide_in[1] = router_2_0_to_router_1_0_wide;
    assign router_1_0_wide_in[2] = '0;
    assign router_1_0_wide_in[3] = router_0_0_to_router_1_0_wide;
    assign router_1_0_wide_in[4] = cluster_ni_1_0_to_router_1_0_wide;

    assign router_1_0_to_router_1_1_wide = router_1_0_wide_out[0];
    assign router_1_0_to_router_2_0_wide = router_1_0_wide_out[1];
    assign router_1_0_to_router_0_0_wide = router_1_0_wide_out[3];
    assign router_1_0_to_cluster_ni_1_0_wide = router_1_0_wide_out[4];

  localparam id_t ROUTER_1_0_ID = '{x: 2, y: 0, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_1_0 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_1_0_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_1_0_req_in),
  .floo_rsp_o (router_1_0_rsp_out),
  .floo_req_o (router_1_0_req_out),
  .floo_rsp_i (router_1_0_rsp_in),
  .floo_wide_i (router_1_0_wide_in),
  .floo_wide_o (router_1_0_wide_out)
);


floo_req_t [4:0] router_1_1_req_in;
floo_rsp_t [4:0] router_1_1_rsp_out;
floo_req_t [4:0] router_1_1_req_out;
floo_rsp_t [4:0] router_1_1_rsp_in;
floo_wide_t [4:0] router_1_1_wide_in;
floo_wide_t [4:0] router_1_1_wide_out;

    assign router_1_1_req_in[0] = router_1_2_to_router_1_1_req;
    assign router_1_1_req_in[1] = router_2_1_to_router_1_1_req;
    assign router_1_1_req_in[2] = router_1_0_to_router_1_1_req;
    assign router_1_1_req_in[3] = router_0_1_to_router_1_1_req;
    assign router_1_1_req_in[4] = cluster_ni_1_1_to_router_1_1_req;

    assign router_1_1_to_router_1_2_rsp = router_1_1_rsp_out[0];
    assign router_1_1_to_router_2_1_rsp = router_1_1_rsp_out[1];
    assign router_1_1_to_router_1_0_rsp = router_1_1_rsp_out[2];
    assign router_1_1_to_router_0_1_rsp = router_1_1_rsp_out[3];
    assign router_1_1_to_cluster_ni_1_1_rsp = router_1_1_rsp_out[4];

    assign router_1_1_to_router_1_2_req = router_1_1_req_out[0];
    assign router_1_1_to_router_2_1_req = router_1_1_req_out[1];
    assign router_1_1_to_router_1_0_req = router_1_1_req_out[2];
    assign router_1_1_to_router_0_1_req = router_1_1_req_out[3];
    assign router_1_1_to_cluster_ni_1_1_req = router_1_1_req_out[4];

    assign router_1_1_rsp_in[0] = router_1_2_to_router_1_1_rsp;
    assign router_1_1_rsp_in[1] = router_2_1_to_router_1_1_rsp;
    assign router_1_1_rsp_in[2] = router_1_0_to_router_1_1_rsp;
    assign router_1_1_rsp_in[3] = router_0_1_to_router_1_1_rsp;
    assign router_1_1_rsp_in[4] = cluster_ni_1_1_to_router_1_1_rsp;

    assign router_1_1_wide_in[0] = router_1_2_to_router_1_1_wide;
    assign router_1_1_wide_in[1] = router_2_1_to_router_1_1_wide;
    assign router_1_1_wide_in[2] = router_1_0_to_router_1_1_wide;
    assign router_1_1_wide_in[3] = router_0_1_to_router_1_1_wide;
    assign router_1_1_wide_in[4] = cluster_ni_1_1_to_router_1_1_wide;

    assign router_1_1_to_router_1_2_wide = router_1_1_wide_out[0];
    assign router_1_1_to_router_2_1_wide = router_1_1_wide_out[1];
    assign router_1_1_to_router_1_0_wide = router_1_1_wide_out[2];
    assign router_1_1_to_router_0_1_wide = router_1_1_wide_out[3];
    assign router_1_1_to_cluster_ni_1_1_wide = router_1_1_wide_out[4];

  localparam id_t ROUTER_1_1_ID = '{x: 2, y: 1, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_1_1 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_1_1_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_1_1_req_in),
  .floo_rsp_o (router_1_1_rsp_out),
  .floo_req_o (router_1_1_req_out),
  .floo_rsp_i (router_1_1_rsp_in),
  .floo_wide_i (router_1_1_wide_in),
  .floo_wide_o (router_1_1_wide_out)
);


floo_req_t [4:0] router_1_2_req_in;
floo_rsp_t [4:0] router_1_2_rsp_out;
floo_req_t [4:0] router_1_2_req_out;
floo_rsp_t [4:0] router_1_2_rsp_in;
floo_wide_t [4:0] router_1_2_wide_in;
floo_wide_t [4:0] router_1_2_wide_out;

    assign router_1_2_req_in[0] = router_1_3_to_router_1_2_req;
    assign router_1_2_req_in[1] = router_2_2_to_router_1_2_req;
    assign router_1_2_req_in[2] = router_1_1_to_router_1_2_req;
    assign router_1_2_req_in[3] = router_0_2_to_router_1_2_req;
    assign router_1_2_req_in[4] = cluster_ni_1_2_to_router_1_2_req;

    assign router_1_2_to_router_1_3_rsp = router_1_2_rsp_out[0];
    assign router_1_2_to_router_2_2_rsp = router_1_2_rsp_out[1];
    assign router_1_2_to_router_1_1_rsp = router_1_2_rsp_out[2];
    assign router_1_2_to_router_0_2_rsp = router_1_2_rsp_out[3];
    assign router_1_2_to_cluster_ni_1_2_rsp = router_1_2_rsp_out[4];

    assign router_1_2_to_router_1_3_req = router_1_2_req_out[0];
    assign router_1_2_to_router_2_2_req = router_1_2_req_out[1];
    assign router_1_2_to_router_1_1_req = router_1_2_req_out[2];
    assign router_1_2_to_router_0_2_req = router_1_2_req_out[3];
    assign router_1_2_to_cluster_ni_1_2_req = router_1_2_req_out[4];

    assign router_1_2_rsp_in[0] = router_1_3_to_router_1_2_rsp;
    assign router_1_2_rsp_in[1] = router_2_2_to_router_1_2_rsp;
    assign router_1_2_rsp_in[2] = router_1_1_to_router_1_2_rsp;
    assign router_1_2_rsp_in[3] = router_0_2_to_router_1_2_rsp;
    assign router_1_2_rsp_in[4] = cluster_ni_1_2_to_router_1_2_rsp;

    assign router_1_2_wide_in[0] = router_1_3_to_router_1_2_wide;
    assign router_1_2_wide_in[1] = router_2_2_to_router_1_2_wide;
    assign router_1_2_wide_in[2] = router_1_1_to_router_1_2_wide;
    assign router_1_2_wide_in[3] = router_0_2_to_router_1_2_wide;
    assign router_1_2_wide_in[4] = cluster_ni_1_2_to_router_1_2_wide;

    assign router_1_2_to_router_1_3_wide = router_1_2_wide_out[0];
    assign router_1_2_to_router_2_2_wide = router_1_2_wide_out[1];
    assign router_1_2_to_router_1_1_wide = router_1_2_wide_out[2];
    assign router_1_2_to_router_0_2_wide = router_1_2_wide_out[3];
    assign router_1_2_to_cluster_ni_1_2_wide = router_1_2_wide_out[4];

  localparam id_t ROUTER_1_2_ID = '{x: 2, y: 2, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_1_2 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_1_2_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_1_2_req_in),
  .floo_rsp_o (router_1_2_rsp_out),
  .floo_req_o (router_1_2_req_out),
  .floo_rsp_i (router_1_2_rsp_in),
  .floo_wide_i (router_1_2_wide_in),
  .floo_wide_o (router_1_2_wide_out)
);


floo_req_t [4:0] router_1_3_req_in;
floo_rsp_t [4:0] router_1_3_rsp_out;
floo_req_t [4:0] router_1_3_req_out;
floo_rsp_t [4:0] router_1_3_rsp_in;
floo_wide_t [4:0] router_1_3_wide_in;
floo_wide_t [4:0] router_1_3_wide_out;

    assign router_1_3_req_in[0] = '0;
    assign router_1_3_req_in[1] = router_2_3_to_router_1_3_req;
    assign router_1_3_req_in[2] = router_1_2_to_router_1_3_req;
    assign router_1_3_req_in[3] = router_0_3_to_router_1_3_req;
    assign router_1_3_req_in[4] = cluster_ni_1_3_to_router_1_3_req;

    assign router_1_3_to_router_2_3_rsp = router_1_3_rsp_out[1];
    assign router_1_3_to_router_1_2_rsp = router_1_3_rsp_out[2];
    assign router_1_3_to_router_0_3_rsp = router_1_3_rsp_out[3];
    assign router_1_3_to_cluster_ni_1_3_rsp = router_1_3_rsp_out[4];

    assign router_1_3_to_router_2_3_req = router_1_3_req_out[1];
    assign router_1_3_to_router_1_2_req = router_1_3_req_out[2];
    assign router_1_3_to_router_0_3_req = router_1_3_req_out[3];
    assign router_1_3_to_cluster_ni_1_3_req = router_1_3_req_out[4];

    assign router_1_3_rsp_in[0] = '0;
    assign router_1_3_rsp_in[1] = router_2_3_to_router_1_3_rsp;
    assign router_1_3_rsp_in[2] = router_1_2_to_router_1_3_rsp;
    assign router_1_3_rsp_in[3] = router_0_3_to_router_1_3_rsp;
    assign router_1_3_rsp_in[4] = cluster_ni_1_3_to_router_1_3_rsp;

    assign router_1_3_wide_in[0] = '0;
    assign router_1_3_wide_in[1] = router_2_3_to_router_1_3_wide;
    assign router_1_3_wide_in[2] = router_1_2_to_router_1_3_wide;
    assign router_1_3_wide_in[3] = router_0_3_to_router_1_3_wide;
    assign router_1_3_wide_in[4] = cluster_ni_1_3_to_router_1_3_wide;

    assign router_1_3_to_router_2_3_wide = router_1_3_wide_out[1];
    assign router_1_3_to_router_1_2_wide = router_1_3_wide_out[2];
    assign router_1_3_to_router_0_3_wide = router_1_3_wide_out[3];
    assign router_1_3_to_cluster_ni_1_3_wide = router_1_3_wide_out[4];

  localparam id_t ROUTER_1_3_ID = '{x: 2, y: 3, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_1_3 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_1_3_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_1_3_req_in),
  .floo_rsp_o (router_1_3_rsp_out),
  .floo_req_o (router_1_3_req_out),
  .floo_rsp_i (router_1_3_rsp_in),
  .floo_wide_i (router_1_3_wide_in),
  .floo_wide_o (router_1_3_wide_out)
);


floo_req_t [4:0] router_2_0_req_in;
floo_rsp_t [4:0] router_2_0_rsp_out;
floo_req_t [4:0] router_2_0_req_out;
floo_rsp_t [4:0] router_2_0_rsp_in;
floo_wide_t [4:0] router_2_0_wide_in;
floo_wide_t [4:0] router_2_0_wide_out;

    assign router_2_0_req_in[0] = router_2_1_to_router_2_0_req;
    assign router_2_0_req_in[1] = router_3_0_to_router_2_0_req;
    assign router_2_0_req_in[2] = '0;
    assign router_2_0_req_in[3] = router_1_0_to_router_2_0_req;
    assign router_2_0_req_in[4] = cluster_ni_2_0_to_router_2_0_req;

    assign router_2_0_to_router_2_1_rsp = router_2_0_rsp_out[0];
    assign router_2_0_to_router_3_0_rsp = router_2_0_rsp_out[1];
    assign router_2_0_to_router_1_0_rsp = router_2_0_rsp_out[3];
    assign router_2_0_to_cluster_ni_2_0_rsp = router_2_0_rsp_out[4];

    assign router_2_0_to_router_2_1_req = router_2_0_req_out[0];
    assign router_2_0_to_router_3_0_req = router_2_0_req_out[1];
    assign router_2_0_to_router_1_0_req = router_2_0_req_out[3];
    assign router_2_0_to_cluster_ni_2_0_req = router_2_0_req_out[4];

    assign router_2_0_rsp_in[0] = router_2_1_to_router_2_0_rsp;
    assign router_2_0_rsp_in[1] = router_3_0_to_router_2_0_rsp;
    assign router_2_0_rsp_in[2] = '0;
    assign router_2_0_rsp_in[3] = router_1_0_to_router_2_0_rsp;
    assign router_2_0_rsp_in[4] = cluster_ni_2_0_to_router_2_0_rsp;

    assign router_2_0_wide_in[0] = router_2_1_to_router_2_0_wide;
    assign router_2_0_wide_in[1] = router_3_0_to_router_2_0_wide;
    assign router_2_0_wide_in[2] = '0;
    assign router_2_0_wide_in[3] = router_1_0_to_router_2_0_wide;
    assign router_2_0_wide_in[4] = cluster_ni_2_0_to_router_2_0_wide;

    assign router_2_0_to_router_2_1_wide = router_2_0_wide_out[0];
    assign router_2_0_to_router_3_0_wide = router_2_0_wide_out[1];
    assign router_2_0_to_router_1_0_wide = router_2_0_wide_out[3];
    assign router_2_0_to_cluster_ni_2_0_wide = router_2_0_wide_out[4];

  localparam id_t ROUTER_2_0_ID = '{x: 3, y: 0, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_2_0 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_2_0_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_2_0_req_in),
  .floo_rsp_o (router_2_0_rsp_out),
  .floo_req_o (router_2_0_req_out),
  .floo_rsp_i (router_2_0_rsp_in),
  .floo_wide_i (router_2_0_wide_in),
  .floo_wide_o (router_2_0_wide_out)
);


floo_req_t [4:0] router_2_1_req_in;
floo_rsp_t [4:0] router_2_1_rsp_out;
floo_req_t [4:0] router_2_1_req_out;
floo_rsp_t [4:0] router_2_1_rsp_in;
floo_wide_t [4:0] router_2_1_wide_in;
floo_wide_t [4:0] router_2_1_wide_out;

    assign router_2_1_req_in[0] = router_2_2_to_router_2_1_req;
    assign router_2_1_req_in[1] = router_3_1_to_router_2_1_req;
    assign router_2_1_req_in[2] = router_2_0_to_router_2_1_req;
    assign router_2_1_req_in[3] = router_1_1_to_router_2_1_req;
    assign router_2_1_req_in[4] = cluster_ni_2_1_to_router_2_1_req;

    assign router_2_1_to_router_2_2_rsp = router_2_1_rsp_out[0];
    assign router_2_1_to_router_3_1_rsp = router_2_1_rsp_out[1];
    assign router_2_1_to_router_2_0_rsp = router_2_1_rsp_out[2];
    assign router_2_1_to_router_1_1_rsp = router_2_1_rsp_out[3];
    assign router_2_1_to_cluster_ni_2_1_rsp = router_2_1_rsp_out[4];

    assign router_2_1_to_router_2_2_req = router_2_1_req_out[0];
    assign router_2_1_to_router_3_1_req = router_2_1_req_out[1];
    assign router_2_1_to_router_2_0_req = router_2_1_req_out[2];
    assign router_2_1_to_router_1_1_req = router_2_1_req_out[3];
    assign router_2_1_to_cluster_ni_2_1_req = router_2_1_req_out[4];

    assign router_2_1_rsp_in[0] = router_2_2_to_router_2_1_rsp;
    assign router_2_1_rsp_in[1] = router_3_1_to_router_2_1_rsp;
    assign router_2_1_rsp_in[2] = router_2_0_to_router_2_1_rsp;
    assign router_2_1_rsp_in[3] = router_1_1_to_router_2_1_rsp;
    assign router_2_1_rsp_in[4] = cluster_ni_2_1_to_router_2_1_rsp;

    assign router_2_1_wide_in[0] = router_2_2_to_router_2_1_wide;
    assign router_2_1_wide_in[1] = router_3_1_to_router_2_1_wide;
    assign router_2_1_wide_in[2] = router_2_0_to_router_2_1_wide;
    assign router_2_1_wide_in[3] = router_1_1_to_router_2_1_wide;
    assign router_2_1_wide_in[4] = cluster_ni_2_1_to_router_2_1_wide;

    assign router_2_1_to_router_2_2_wide = router_2_1_wide_out[0];
    assign router_2_1_to_router_3_1_wide = router_2_1_wide_out[1];
    assign router_2_1_to_router_2_0_wide = router_2_1_wide_out[2];
    assign router_2_1_to_router_1_1_wide = router_2_1_wide_out[3];
    assign router_2_1_to_cluster_ni_2_1_wide = router_2_1_wide_out[4];

  localparam id_t ROUTER_2_1_ID = '{x: 3, y: 1, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_2_1 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_2_1_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_2_1_req_in),
  .floo_rsp_o (router_2_1_rsp_out),
  .floo_req_o (router_2_1_req_out),
  .floo_rsp_i (router_2_1_rsp_in),
  .floo_wide_i (router_2_1_wide_in),
  .floo_wide_o (router_2_1_wide_out)
);


floo_req_t [4:0] router_2_2_req_in;
floo_rsp_t [4:0] router_2_2_rsp_out;
floo_req_t [4:0] router_2_2_req_out;
floo_rsp_t [4:0] router_2_2_rsp_in;
floo_wide_t [4:0] router_2_2_wide_in;
floo_wide_t [4:0] router_2_2_wide_out;

    assign router_2_2_req_in[0] = router_2_3_to_router_2_2_req;
    assign router_2_2_req_in[1] = router_3_2_to_router_2_2_req;
    assign router_2_2_req_in[2] = router_2_1_to_router_2_2_req;
    assign router_2_2_req_in[3] = router_1_2_to_router_2_2_req;
    assign router_2_2_req_in[4] = cluster_ni_2_2_to_router_2_2_req;

    assign router_2_2_to_router_2_3_rsp = router_2_2_rsp_out[0];
    assign router_2_2_to_router_3_2_rsp = router_2_2_rsp_out[1];
    assign router_2_2_to_router_2_1_rsp = router_2_2_rsp_out[2];
    assign router_2_2_to_router_1_2_rsp = router_2_2_rsp_out[3];
    assign router_2_2_to_cluster_ni_2_2_rsp = router_2_2_rsp_out[4];

    assign router_2_2_to_router_2_3_req = router_2_2_req_out[0];
    assign router_2_2_to_router_3_2_req = router_2_2_req_out[1];
    assign router_2_2_to_router_2_1_req = router_2_2_req_out[2];
    assign router_2_2_to_router_1_2_req = router_2_2_req_out[3];
    assign router_2_2_to_cluster_ni_2_2_req = router_2_2_req_out[4];

    assign router_2_2_rsp_in[0] = router_2_3_to_router_2_2_rsp;
    assign router_2_2_rsp_in[1] = router_3_2_to_router_2_2_rsp;
    assign router_2_2_rsp_in[2] = router_2_1_to_router_2_2_rsp;
    assign router_2_2_rsp_in[3] = router_1_2_to_router_2_2_rsp;
    assign router_2_2_rsp_in[4] = cluster_ni_2_2_to_router_2_2_rsp;

    assign router_2_2_wide_in[0] = router_2_3_to_router_2_2_wide;
    assign router_2_2_wide_in[1] = router_3_2_to_router_2_2_wide;
    assign router_2_2_wide_in[2] = router_2_1_to_router_2_2_wide;
    assign router_2_2_wide_in[3] = router_1_2_to_router_2_2_wide;
    assign router_2_2_wide_in[4] = cluster_ni_2_2_to_router_2_2_wide;

    assign router_2_2_to_router_2_3_wide = router_2_2_wide_out[0];
    assign router_2_2_to_router_3_2_wide = router_2_2_wide_out[1];
    assign router_2_2_to_router_2_1_wide = router_2_2_wide_out[2];
    assign router_2_2_to_router_1_2_wide = router_2_2_wide_out[3];
    assign router_2_2_to_cluster_ni_2_2_wide = router_2_2_wide_out[4];

  localparam id_t ROUTER_2_2_ID = '{x: 3, y: 2, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_2_2 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_2_2_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_2_2_req_in),
  .floo_rsp_o (router_2_2_rsp_out),
  .floo_req_o (router_2_2_req_out),
  .floo_rsp_i (router_2_2_rsp_in),
  .floo_wide_i (router_2_2_wide_in),
  .floo_wide_o (router_2_2_wide_out)
);


floo_req_t [4:0] router_2_3_req_in;
floo_rsp_t [4:0] router_2_3_rsp_out;
floo_req_t [4:0] router_2_3_req_out;
floo_rsp_t [4:0] router_2_3_rsp_in;
floo_wide_t [4:0] router_2_3_wide_in;
floo_wide_t [4:0] router_2_3_wide_out;

    assign router_2_3_req_in[0] = '0;
    assign router_2_3_req_in[1] = router_3_3_to_router_2_3_req;
    assign router_2_3_req_in[2] = router_2_2_to_router_2_3_req;
    assign router_2_3_req_in[3] = router_1_3_to_router_2_3_req;
    assign router_2_3_req_in[4] = cluster_ni_2_3_to_router_2_3_req;

    assign router_2_3_to_router_3_3_rsp = router_2_3_rsp_out[1];
    assign router_2_3_to_router_2_2_rsp = router_2_3_rsp_out[2];
    assign router_2_3_to_router_1_3_rsp = router_2_3_rsp_out[3];
    assign router_2_3_to_cluster_ni_2_3_rsp = router_2_3_rsp_out[4];

    assign router_2_3_to_router_3_3_req = router_2_3_req_out[1];
    assign router_2_3_to_router_2_2_req = router_2_3_req_out[2];
    assign router_2_3_to_router_1_3_req = router_2_3_req_out[3];
    assign router_2_3_to_cluster_ni_2_3_req = router_2_3_req_out[4];

    assign router_2_3_rsp_in[0] = '0;
    assign router_2_3_rsp_in[1] = router_3_3_to_router_2_3_rsp;
    assign router_2_3_rsp_in[2] = router_2_2_to_router_2_3_rsp;
    assign router_2_3_rsp_in[3] = router_1_3_to_router_2_3_rsp;
    assign router_2_3_rsp_in[4] = cluster_ni_2_3_to_router_2_3_rsp;

    assign router_2_3_wide_in[0] = '0;
    assign router_2_3_wide_in[1] = router_3_3_to_router_2_3_wide;
    assign router_2_3_wide_in[2] = router_2_2_to_router_2_3_wide;
    assign router_2_3_wide_in[3] = router_1_3_to_router_2_3_wide;
    assign router_2_3_wide_in[4] = cluster_ni_2_3_to_router_2_3_wide;

    assign router_2_3_to_router_3_3_wide = router_2_3_wide_out[1];
    assign router_2_3_to_router_2_2_wide = router_2_3_wide_out[2];
    assign router_2_3_to_router_1_3_wide = router_2_3_wide_out[3];
    assign router_2_3_to_cluster_ni_2_3_wide = router_2_3_wide_out[4];

  localparam id_t ROUTER_2_3_ID = '{x: 3, y: 3, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_2_3 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_2_3_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_2_3_req_in),
  .floo_rsp_o (router_2_3_rsp_out),
  .floo_req_o (router_2_3_req_out),
  .floo_rsp_i (router_2_3_rsp_in),
  .floo_wide_i (router_2_3_wide_in),
  .floo_wide_o (router_2_3_wide_out)
);


floo_req_t [4:0] router_3_0_req_in;
floo_rsp_t [4:0] router_3_0_rsp_out;
floo_req_t [4:0] router_3_0_req_out;
floo_rsp_t [4:0] router_3_0_rsp_in;
floo_wide_t [4:0] router_3_0_wide_in;
floo_wide_t [4:0] router_3_0_wide_out;

    assign router_3_0_req_in[0] = router_3_1_to_router_3_0_req;
    assign router_3_0_req_in[1] = '0;
    assign router_3_0_req_in[2] = '0;
    assign router_3_0_req_in[3] = router_2_0_to_router_3_0_req;
    assign router_3_0_req_in[4] = cluster_ni_3_0_to_router_3_0_req;

    assign router_3_0_to_router_3_1_rsp = router_3_0_rsp_out[0];
    assign router_3_0_to_router_2_0_rsp = router_3_0_rsp_out[3];
    assign router_3_0_to_cluster_ni_3_0_rsp = router_3_0_rsp_out[4];

    assign router_3_0_to_router_3_1_req = router_3_0_req_out[0];
    assign router_3_0_to_router_2_0_req = router_3_0_req_out[3];
    assign router_3_0_to_cluster_ni_3_0_req = router_3_0_req_out[4];

    assign router_3_0_rsp_in[0] = router_3_1_to_router_3_0_rsp;
    assign router_3_0_rsp_in[1] = '0;
    assign router_3_0_rsp_in[2] = '0;
    assign router_3_0_rsp_in[3] = router_2_0_to_router_3_0_rsp;
    assign router_3_0_rsp_in[4] = cluster_ni_3_0_to_router_3_0_rsp;

    assign router_3_0_wide_in[0] = router_3_1_to_router_3_0_wide;
    assign router_3_0_wide_in[1] = '0;
    assign router_3_0_wide_in[2] = '0;
    assign router_3_0_wide_in[3] = router_2_0_to_router_3_0_wide;
    assign router_3_0_wide_in[4] = cluster_ni_3_0_to_router_3_0_wide;

    assign router_3_0_to_router_3_1_wide = router_3_0_wide_out[0];
    assign router_3_0_to_router_2_0_wide = router_3_0_wide_out[3];
    assign router_3_0_to_cluster_ni_3_0_wide = router_3_0_wide_out[4];

  localparam id_t ROUTER_3_0_ID = '{x: 4, y: 0, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_3_0 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_3_0_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_3_0_req_in),
  .floo_rsp_o (router_3_0_rsp_out),
  .floo_req_o (router_3_0_req_out),
  .floo_rsp_i (router_3_0_rsp_in),
  .floo_wide_i (router_3_0_wide_in),
  .floo_wide_o (router_3_0_wide_out)
);


floo_req_t [4:0] router_3_1_req_in;
floo_rsp_t [4:0] router_3_1_rsp_out;
floo_req_t [4:0] router_3_1_req_out;
floo_rsp_t [4:0] router_3_1_rsp_in;
floo_wide_t [4:0] router_3_1_wide_in;
floo_wide_t [4:0] router_3_1_wide_out;

    assign router_3_1_req_in[0] = router_3_2_to_router_3_1_req;
    assign router_3_1_req_in[1] = '0;
    assign router_3_1_req_in[2] = router_3_0_to_router_3_1_req;
    assign router_3_1_req_in[3] = router_2_1_to_router_3_1_req;
    assign router_3_1_req_in[4] = cluster_ni_3_1_to_router_3_1_req;

    assign router_3_1_to_router_3_2_rsp = router_3_1_rsp_out[0];
    assign router_3_1_to_router_3_0_rsp = router_3_1_rsp_out[2];
    assign router_3_1_to_router_2_1_rsp = router_3_1_rsp_out[3];
    assign router_3_1_to_cluster_ni_3_1_rsp = router_3_1_rsp_out[4];

    assign router_3_1_to_router_3_2_req = router_3_1_req_out[0];
    assign router_3_1_to_router_3_0_req = router_3_1_req_out[2];
    assign router_3_1_to_router_2_1_req = router_3_1_req_out[3];
    assign router_3_1_to_cluster_ni_3_1_req = router_3_1_req_out[4];

    assign router_3_1_rsp_in[0] = router_3_2_to_router_3_1_rsp;
    assign router_3_1_rsp_in[1] = '0;
    assign router_3_1_rsp_in[2] = router_3_0_to_router_3_1_rsp;
    assign router_3_1_rsp_in[3] = router_2_1_to_router_3_1_rsp;
    assign router_3_1_rsp_in[4] = cluster_ni_3_1_to_router_3_1_rsp;

    assign router_3_1_wide_in[0] = router_3_2_to_router_3_1_wide;
    assign router_3_1_wide_in[1] = '0;
    assign router_3_1_wide_in[2] = router_3_0_to_router_3_1_wide;
    assign router_3_1_wide_in[3] = router_2_1_to_router_3_1_wide;
    assign router_3_1_wide_in[4] = cluster_ni_3_1_to_router_3_1_wide;

    assign router_3_1_to_router_3_2_wide = router_3_1_wide_out[0];
    assign router_3_1_to_router_3_0_wide = router_3_1_wide_out[2];
    assign router_3_1_to_router_2_1_wide = router_3_1_wide_out[3];
    assign router_3_1_to_cluster_ni_3_1_wide = router_3_1_wide_out[4];

  localparam id_t ROUTER_3_1_ID = '{x: 4, y: 1, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_3_1 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_3_1_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_3_1_req_in),
  .floo_rsp_o (router_3_1_rsp_out),
  .floo_req_o (router_3_1_req_out),
  .floo_rsp_i (router_3_1_rsp_in),
  .floo_wide_i (router_3_1_wide_in),
  .floo_wide_o (router_3_1_wide_out)
);


floo_req_t [4:0] router_3_2_req_in;
floo_rsp_t [4:0] router_3_2_rsp_out;
floo_req_t [4:0] router_3_2_req_out;
floo_rsp_t [4:0] router_3_2_rsp_in;
floo_wide_t [4:0] router_3_2_wide_in;
floo_wide_t [4:0] router_3_2_wide_out;

    assign router_3_2_req_in[0] = router_3_3_to_router_3_2_req;
    assign router_3_2_req_in[1] = '0;
    assign router_3_2_req_in[2] = router_3_1_to_router_3_2_req;
    assign router_3_2_req_in[3] = router_2_2_to_router_3_2_req;
    assign router_3_2_req_in[4] = cluster_ni_3_2_to_router_3_2_req;

    assign router_3_2_to_router_3_3_rsp = router_3_2_rsp_out[0];
    assign router_3_2_to_router_3_1_rsp = router_3_2_rsp_out[2];
    assign router_3_2_to_router_2_2_rsp = router_3_2_rsp_out[3];
    assign router_3_2_to_cluster_ni_3_2_rsp = router_3_2_rsp_out[4];

    assign router_3_2_to_router_3_3_req = router_3_2_req_out[0];
    assign router_3_2_to_router_3_1_req = router_3_2_req_out[2];
    assign router_3_2_to_router_2_2_req = router_3_2_req_out[3];
    assign router_3_2_to_cluster_ni_3_2_req = router_3_2_req_out[4];

    assign router_3_2_rsp_in[0] = router_3_3_to_router_3_2_rsp;
    assign router_3_2_rsp_in[1] = '0;
    assign router_3_2_rsp_in[2] = router_3_1_to_router_3_2_rsp;
    assign router_3_2_rsp_in[3] = router_2_2_to_router_3_2_rsp;
    assign router_3_2_rsp_in[4] = cluster_ni_3_2_to_router_3_2_rsp;

    assign router_3_2_wide_in[0] = router_3_3_to_router_3_2_wide;
    assign router_3_2_wide_in[1] = '0;
    assign router_3_2_wide_in[2] = router_3_1_to_router_3_2_wide;
    assign router_3_2_wide_in[3] = router_2_2_to_router_3_2_wide;
    assign router_3_2_wide_in[4] = cluster_ni_3_2_to_router_3_2_wide;

    assign router_3_2_to_router_3_3_wide = router_3_2_wide_out[0];
    assign router_3_2_to_router_3_1_wide = router_3_2_wide_out[2];
    assign router_3_2_to_router_2_2_wide = router_3_2_wide_out[3];
    assign router_3_2_to_cluster_ni_3_2_wide = router_3_2_wide_out[4];

  localparam id_t ROUTER_3_2_ID = '{x: 4, y: 2, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_3_2 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_3_2_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_3_2_req_in),
  .floo_rsp_o (router_3_2_rsp_out),
  .floo_req_o (router_3_2_req_out),
  .floo_rsp_i (router_3_2_rsp_in),
  .floo_wide_i (router_3_2_wide_in),
  .floo_wide_o (router_3_2_wide_out)
);


floo_req_t [4:0] router_3_3_req_in;
floo_rsp_t [4:0] router_3_3_rsp_out;
floo_req_t [4:0] router_3_3_req_out;
floo_rsp_t [4:0] router_3_3_rsp_in;
floo_wide_t [4:0] router_3_3_wide_in;
floo_wide_t [4:0] router_3_3_wide_out;

    assign router_3_3_req_in[0] = '0;
    assign router_3_3_req_in[1] = '0;
    assign router_3_3_req_in[2] = router_3_2_to_router_3_3_req;
    assign router_3_3_req_in[3] = router_2_3_to_router_3_3_req;
    assign router_3_3_req_in[4] = cluster_ni_3_3_to_router_3_3_req;

    assign router_3_3_to_router_3_2_rsp = router_3_3_rsp_out[2];
    assign router_3_3_to_router_2_3_rsp = router_3_3_rsp_out[3];
    assign router_3_3_to_cluster_ni_3_3_rsp = router_3_3_rsp_out[4];

    assign router_3_3_to_router_3_2_req = router_3_3_req_out[2];
    assign router_3_3_to_router_2_3_req = router_3_3_req_out[3];
    assign router_3_3_to_cluster_ni_3_3_req = router_3_3_req_out[4];

    assign router_3_3_rsp_in[0] = '0;
    assign router_3_3_rsp_in[1] = '0;
    assign router_3_3_rsp_in[2] = router_3_2_to_router_3_3_rsp;
    assign router_3_3_rsp_in[3] = router_2_3_to_router_3_3_rsp;
    assign router_3_3_rsp_in[4] = cluster_ni_3_3_to_router_3_3_rsp;

    assign router_3_3_wide_in[0] = '0;
    assign router_3_3_wide_in[1] = '0;
    assign router_3_3_wide_in[2] = router_3_2_to_router_3_3_wide;
    assign router_3_3_wide_in[3] = router_2_3_to_router_3_3_wide;
    assign router_3_3_wide_in[4] = cluster_ni_3_3_to_router_3_3_wide;

    assign router_3_3_to_router_3_2_wide = router_3_3_wide_out[2];
    assign router_3_3_to_router_2_3_wide = router_3_3_wide_out[3];
    assign router_3_3_to_cluster_ni_3_3_wide = router_3_3_wide_out[4];

  localparam id_t ROUTER_3_3_ID = '{x: 4, y: 3, port_id: 0};

floo_nw_router #(
  .AxiCfgN(AxiCfgN),
  .AxiCfgW(AxiCfgW),
  .RouteAlgo (XYRouting),
  .NumRoutes (5),
  .NumInputs (5),
  .NumOutputs (5),
  .InFifoDepth (2),
  .OutFifoDepth (2),
  .id_t(id_t),
  .hdr_t(hdr_t),
  .floo_req_t(floo_req_t),
  .floo_rsp_t(floo_rsp_t),
  .floo_wide_t(floo_wide_t)
) router_3_3 (
  .clk_i,
  .rst_ni,
  .test_enable_i,
  .id_i (ROUTER_3_3_ID),
  .id_route_map_i ('0),
  .floo_req_i (router_3_3_req_in),
  .floo_rsp_o (router_3_3_rsp_out),
  .floo_req_o (router_3_3_req_out),
  .floo_rsp_i (router_3_3_rsp_in),
  .floo_wide_i (router_3_3_wide_in),
  .floo_wide_o (router_3_3_wide_out)
);



endmodule
