// ================================================================
// NVDLA Open Source Project
//
// Copyright(c) 2016 - 2017 NVIDIA Corporation. Licensed under the
// NVDLA Open Hardware License; Check "LICENSE" which comes with
// this distribution for more information.
// ================================================================
// File Name: NV_NVDLA_CMAC_CORE_rt_out.v
// ================================================================
// NVDLA Open Source Project
// 
// Copyright(c) 2016 - 2017 NVIDIA Corporation.  Licensed under the
// NVDLA Open Hardware License; Check "LICENSE" which comes with 
// this distribution for more information.
// ================================================================
// File Name: NV_NVDLA_CMAC.h
`define DESIGNWARE_NOEXIST 1
module NV_NVDLA_CMAC_CORE_rt_out (
   nvdla_core_clk
  ,nvdla_wg_clk
  ,nvdla_core_rstn
  ,cfg_is_wg
  ,cfg_reg_en
//: for(my $i=0; $i<8/2; $i++){
//: print qq(
//: ,out_data${i} )
//: }
  ,out_mask
  ,out_pd
  ,out_pvld
  ,dp2reg_done
//: for(my $i=0; $i<8/2; $i++){
//: print qq(
//: ,mac2accu_data${i} )
//: }
  ,mac2accu_mask
  ,mac2accu_pd
  ,mac2accu_pvld
  );
input nvdla_core_clk;
input nvdla_wg_clk;
input nvdla_core_rstn;
input cfg_is_wg;
input cfg_reg_en;
//: for(my $i=0; $i<8/2; $i++){
//: print qq(
//: input[19 -1:0] out_data${i}; )
//: }
input [8/2 -1:0] out_mask;
input [8:0] out_pd;
input out_pvld;
output dp2reg_done;
//: for(my $i=0; $i<8/2; $i++){
//: print qq(
//: output[19 -1:0] mac2accu_data${i}; )
//: }
output [8/2 -1:0] mac2accu_mask;
output [8:0] mac2accu_pd;
output mac2accu_pvld;
wire [8/2 -1:0] mac2accu_mask;
wire [8:0] mac2accu_pd;
wire mac2accu_pvld;
wire out_layer_done;
wire out_rt_done_d0;
//==========================================================
// Config logic
//==========================================================
//: &eperl::flop(" -q  \"cfg_reg_en_d1\"  -d \"cfg_reg_en\" -clk nvdla_core_clk -rst nvdla_core_rstn ");
//: &eperl::flop(" -q  \"cfg_is_wg_d1\"  -en \"cfg_reg_en\" -d  \"cfg_is_wg\" -clk nvdla_core_clk -rst nvdla_core_rstn ");
//==========================================================
// Output retiming
//==========================================================
assign out_layer_done = out_pd[8] &
                            out_pd[6] &
                            out_pvld;
//: my $kk = 8/2;
//: my $jj = 19;
//: print "wire             out_rt_pvld_d0 = out_pvld;\n";
//: print "wire [$kk-1:0]   out_rt_mask_d0 = out_mask;\n";
//: print "wire [8:0]       out_rt_pd_d0   = out_pd;\n";
//: for(my $k = 0; $k < $kk; $k ++) {
//: print "wire [${jj}-1:0]    out_rt_data${k}_d0 =  out_data${k};\n";
//: }
//: my $latency = 2;
//: my $kk = 8/2;
//: my $res_width = 19;
//: for(my $i = 0; $i < $latency; $i ++) {
//: my $j = $i + 1;
//: &eperl::flop(" -q  out_rt_pvld_d${j}  -d \"out_rt_pvld_d${i}\" -clk nvdla_core_clk -rst nvdla_core_rstn ");
//: &eperl::flop(" -q  out_rt_mask_d${j}  -d \"out_rt_mask_d${i}\" -wid $kk -clk nvdla_core_clk -rst nvdla_core_rstn ");
//: &eperl::flop("-wid 9 -q  out_rt_pd_d${j}  -en \"out_rt_pvld_d${i}\" -d  \"out_rt_pd_d${i}\" -clk nvdla_core_clk -rst nvdla_core_rstn");
//: for(my $k = 0; $k < $kk; $k ++) {
//: &eperl::flop("-norst -wid $res_width  -q out_rt_data${k}_d${j} -en \"out_rt_mask_d${i}[${k}]\" -d  \"out_rt_data${k}_d${i}\" -clk nvdla_core_clk");
//: }
//: }
//:
//: my $i = $latency;
//: print "assign    mac2accu_pvld = out_rt_pvld_d${i};\n";
//: print "assign    mac2accu_mask = out_rt_mask_d${i};\n";
//: print "assign    mac2accu_pd = out_rt_pd_d${i};\n";
//: my $kk = 8/2;
//: for(my $k = 0; $k < $kk; $k ++) {
//: print "assign    mac2accu_data${k} = out_rt_data${k}_d${i};\n";
//: }
//:
// get layer done signal
assign out_rt_done_d0 = out_layer_done;
//: my $latency = 2 + 1;
//: for(my $i = 0; $i < $latency; $i ++) {
//: my $j = $i + 1;
//: &eperl::flop(" -q  out_rt_done_d${j}  -d \"out_rt_done_d${i}\" -clk nvdla_core_clk -rst nvdla_core_rstn ");
//: };
//: my $h = $latency;
//: print "assign dp2reg_done = out_rt_done_d${h};\n";
endmodule
