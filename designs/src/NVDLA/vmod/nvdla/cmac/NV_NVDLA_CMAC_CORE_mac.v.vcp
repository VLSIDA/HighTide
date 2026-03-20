// ================================================================
// NVDLA Open Source Project
//
// Copyright(c) 2016 - 2017 NVIDIA Corporation. Licensed under the
// NVDLA Open Hardware License; Check "LICENSE" which comes with
// this distribution for more information.
// ================================================================
// File Name: NV_NVDLA_CMAC_CORE_mac.v
// ================================================================
// NVDLA Open Source Project
// 
// Copyright(c) 2016 - 2017 NVIDIA Corporation.  Licensed under the
// NVDLA Open Hardware License; Check "LICENSE" which comes with 
// this distribution for more information.
// ================================================================
// File Name: NV_NVDLA_CMAC.h
`define DESIGNWARE_NOEXIST 1
module NV_NVDLA_CMAC_CORE_mac (
   nvdla_core_clk //|< i
  ,nvdla_wg_clk //|< i
  ,nvdla_core_rstn //|< i
  ,cfg_is_wg //|< i
  ,cfg_reg_en //|< i
  ,dat_actv_data //|< i
  ,dat_actv_nz //|< i
  ,dat_actv_pvld //|< i
  ,wt_actv_data //|< i
  ,wt_actv_nz //|< i
  ,wt_actv_pvld //|< i
  ,mac_out_data //|> o
  ,mac_out_pvld //|> o
  );
input nvdla_core_clk;
input nvdla_wg_clk;
input nvdla_core_rstn;
input cfg_is_wg;
input cfg_reg_en;
input [8*8 -1:0] dat_actv_data;
input [8 -1:0] dat_actv_nz;
input [8 -1:0] dat_actv_pvld;
input [8*8 -1:0] wt_actv_data;
input [8 -1:0] wt_actv_nz;
input [8 -1:0] wt_actv_pvld;
output [19 -1:0] mac_out_data;
output mac_out_pvld;
////////////////// unpack data&nz //////////////
//: for(my $i=0; $i<8; $i++){
//: my $bpe = 8;
//: my $data_msb = ($i+1) * $bpe - 1;
//: my $data_lsb = $i * $bpe;
//: print qq(
//: wire [${bpe}-1:0] wt_actv_data${i} = wt_actv_data[${data_msb}:${data_lsb}];
//: wire [${bpe}-1:0] dat_actv_data${i} = dat_actv_data[${data_msb}:${data_lsb}];
//: wire wt_actv_nz${i} = wt_actv_nz[${i}];
//: wire dat_actv_nz${i} = dat_actv_nz[${i}];
//: )
//: }
`ifdef DESIGNWARE_NOEXIST
wire signed [19 -1:0] sum_out;
wire [8 -1:0] op_out_pvld;
//: my $mul_result_width = 18;
//: my $bpe = 8;
//: my $rwidth = 19;
//: my $result_width = $rwidth * 8 * 2;
//: for (my $i=0; $i < 8; ++$i) {
//: print "assign op_out_pvld[${i}] = wt_actv_pvld[${i}] & dat_actv_pvld[${i}] & wt_actv_nz${i} & dat_actv_nz${i};\n";
//: print "wire signed [${mul_result_width}-1:0] mout_$i = (\$signed(wt_actv_data${i}) * \$signed(dat_actv_data${i})) & \$signed({${mul_result_width}{op_out_pvld[${i}]}});\n";
//: }
//:
//: print "assign sum_out = \n";
//: for (my $i=0; $i < 8; ++$i) {
//: print "    ";
//: print "+ " if ($i != 0);
//: print "mout_$i\n";
//: }
//: print "; \n";
`endif
`ifndef DESIGNWARE_NOEXIST
wire [19 -1:0] sum_out;
wire [19*8*2-1:0] full_mul_result;
wire [8 -1:0] op_out_pvld;
//: my $mul_result_width = 18;
//: my $bpe = 8;
//: my $rwidth = 19;
//: for (my $i=0; $i < 8; ++$i) {
//: my $j = $i * 2;
//: my $k = $i * 2 + 1;
//: print qq(
//: wire [$mul_result_width-1:0] mout_$j;
//: wire [$mul_result_width-1:0] mout_$k;
//: DW02_multp #(${bpe}, ${bpe}, $mul_result_width) mul$i (
//: .a(wt_actv_data${i}),
//: .b(dat_actv_data${i}),
//: .tc(1'b1),
//: .out0(mout_${j}),
//: .out1(mout_${k})
//: );
//: assign op_out_pvld[${i}] = wt_actv_pvld[${i}] & dat_actv_pvld[${i}] & wt_actv_nz${i} & dat_actv_nz${i};
//: );
//:
//: my $offset = $j * $rwidth;
//: my $sign_extend_bits = 19 - $mul_result_width;
//: print qq(
//: assign full_mul_result[$offset + $rwidth - 1 : $offset] = {{${sign_extend_bits}{mout_${j}[${mul_result_width}-1]}}, mout_$j} & {${rwidth}{op_out_pvld[$i]}}; );
//: $offset = $k * $rwidth;
//: print qq(
//: assign full_mul_result[$offset + $rwidth - 1 : $offset] = {{${sign_extend_bits}{mout_${k}[${mul_result_width}-1]}}, mout_$k} & {${rwidth}{op_out_pvld[$i]}}; );
//: }
DW02_sum #(8*2, 19) fsum (.INPUT(full_mul_result), .SUM(sum_out));
`endif
//add pipeline for retiming
wire pp_pvld_d0 = (dat_actv_pvld[0] & wt_actv_pvld[0]);
//wire [19 -1:0] sum_out_d0 = $unsigned(sum_out);
wire [19 -1:0] sum_out_d0 = sum_out;
//: my $rwidth = 19;
//: my $rr=3;
//: &eperl::retime("-stage ${rr} -o sum_out_dd -i sum_out_d0 -cg_en_i pp_pvld_d0 -cg_en_o pp_pvld_dd -cg_en_rtm -wid $rwidth");
assign mac_out_pvld=pp_pvld_dd;
assign mac_out_data=sum_out_dd;
endmodule // NV_NVDLA_CMAC_CORE_mac
