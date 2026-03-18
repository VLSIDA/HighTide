// Black-box stub for snitch_cluster_wrapper.
// Represents a cluster macro attached to each FlooNoC mesh endpoint.
// Uses FlooNoC package AXI types directly for interface compatibility.

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

  // Black box: no logic, will be replaced by hard macro

endmodule
