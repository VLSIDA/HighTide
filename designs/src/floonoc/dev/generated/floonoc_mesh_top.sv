// Top-level wrapper: FlooNoC 4x4 mesh with 16 black-box cluster endpoints.
// The cluster endpoints are black-box stubs representing snitch_cluster_wrapper
// hard macros. HBM ports are exposed at the top level.

module floonoc_mesh_top
  import floo_pkg::*;
  import floo_floonoc_mesh_noc_pkg::*;
(
  input  logic clk_i,
  input  logic rst_ni,
  input  logic test_enable_i,
  // HBM memory ports (exposed at top level)
  output axi_narrow_out_req_t  [3:0] hbm_narrow_out_req_o,
  input  axi_narrow_out_rsp_t  [3:0] hbm_narrow_out_rsp_i,
  output axi_wide_out_req_t    [3:0] hbm_wide_out_req_o,
  input  axi_wide_out_rsp_t    [3:0] hbm_wide_out_rsp_i
);

  // Cluster AXI signals between mesh and black-box clusters
  axi_narrow_in_req_t  [3:0][3:0] cluster_narrow_in_req;
  axi_narrow_in_rsp_t  [3:0][3:0] cluster_narrow_in_rsp;
  axi_wide_in_req_t    [3:0][3:0] cluster_wide_in_req;
  axi_wide_in_rsp_t    [3:0][3:0] cluster_wide_in_rsp;
  axi_narrow_out_req_t [3:0][3:0] cluster_narrow_out_req;
  axi_narrow_out_rsp_t [3:0][3:0] cluster_narrow_out_rsp;
  axi_wide_out_req_t   [3:0][3:0] cluster_wide_out_req;
  axi_wide_out_rsp_t   [3:0][3:0] cluster_wide_out_rsp;

  // FlooNoC mesh
  floo_floonoc_mesh_noc i_mesh (
    .clk_i,
    .rst_ni,
    .test_enable_i,
    .cluster_narrow_in_req_i  ( cluster_narrow_in_req  ),
    .cluster_narrow_in_rsp_o  ( cluster_narrow_in_rsp  ),
    .cluster_wide_in_req_i    ( cluster_wide_in_req    ),
    .cluster_wide_in_rsp_o    ( cluster_wide_in_rsp    ),
    .cluster_narrow_out_req_o ( cluster_narrow_out_req ),
    .cluster_narrow_out_rsp_i ( cluster_narrow_out_rsp ),
    .cluster_wide_out_req_o   ( cluster_wide_out_req   ),
    .cluster_wide_out_rsp_i   ( cluster_wide_out_rsp   ),
    .hbm_narrow_out_req_o,
    .hbm_narrow_out_rsp_i,
    .hbm_wide_out_req_o,
    .hbm_wide_out_rsp_i
  );

  // 16 black-box cluster instances (4x4 grid)
  for (genvar x = 0; x < 4; x++) begin : gen_x
    for (genvar y = 0; y < 4; y++) begin : gen_y
      cluster_blackbox i_cluster (
        .clk_i,
        .rst_ni,
        // Mesh narrow_out -> cluster narrow_in (slave)
        .narrow_in_req_i   ( cluster_narrow_out_req[x][y] ),
        .narrow_in_resp_o  ( cluster_narrow_out_rsp[x][y] ),
        // Cluster narrow_out -> mesh narrow_in (master)
        .narrow_out_req_o  ( cluster_narrow_in_req[x][y]  ),
        .narrow_out_resp_i ( cluster_narrow_in_rsp[x][y]  ),
        // Mesh wide_out -> cluster wide_in (slave)
        .wide_in_req_i     ( cluster_wide_out_req[x][y]   ),
        .wide_in_resp_o    ( cluster_wide_out_rsp[x][y]   ),
        // Cluster wide_out -> mesh wide_in (master)
        .wide_out_req_o    ( cluster_wide_in_req[x][y]    ),
        .wide_out_resp_i   ( cluster_wide_in_rsp[x][y]    )
      );
    end
  end

endmodule
