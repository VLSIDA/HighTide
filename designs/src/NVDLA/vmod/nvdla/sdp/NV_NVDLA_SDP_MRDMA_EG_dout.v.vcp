// ================================================================
// NVDLA Open Source Project
//
// Copyright(c) 2016 - 2017 NVIDIA Corporation. Licensed under the
// NVDLA Open Hardware License; Check "LICENSE" which comes with
// this distribution for more information.
// ================================================================
// File Name: NV_NVDLA_SDP_MRDMA_EG_dout.v
`include "simulate_x_tick.vh"
// ================================================================
// NVDLA Open Source Project
// 
// Copyright(c) 2016 - 2017 NVIDIA Corporation.  Licensed under the
// NVDLA Open Hardware License; Check "LICENSE" which comes with 
// this distribution for more information.
// ================================================================
// File Name: NV_NVDLA_SDP_define.h
module NV_NVDLA_SDP_MRDMA_EG_dout (
   nvdla_core_clk //|< i
  ,nvdla_core_rstn //|< i
  ,op_load //|< i
  ,eg_done //|> o
  ,cmd2dat_dma_pd //|< i
  ,cmd2dat_dma_pvld //|< i
  ,cmd2dat_dma_prdy //|> o
  ,pfifo0_rd_pd //|< i
  ,pfifo0_rd_pvld //|< i
  ,pfifo1_rd_pd //|< i
  ,pfifo1_rd_pvld //|< i
  ,pfifo2_rd_pd //|< i
  ,pfifo2_rd_pvld //|< i
  ,pfifo3_rd_pd //|< i
  ,pfifo3_rd_pvld //|< i
  ,pfifo0_rd_prdy //|> o
  ,pfifo1_rd_prdy //|> o
  ,pfifo2_rd_prdy //|> o
  ,pfifo3_rd_prdy //|> o
  ,sdp_mrdma2cmux_pd //|> o
  ,sdp_mrdma2cmux_valid //|> o
  ,sdp_mrdma2cmux_ready //|< i
  ,reg2dp_height //|< i
  ,reg2dp_width //|< i
  ,reg2dp_in_precision //|< i
  ,reg2dp_proc_precision //|< i
  ,reg2dp_perf_nan_inf_count_en //|< i
  ,dp2reg_status_inf_input_num //|> o
  ,dp2reg_status_nan_input_num //|> o
  );
//
// NV_NVDLA_SDP_MRDMA_EG_dout_ports.v
//
input nvdla_core_clk;
input nvdla_core_rstn;
input op_load;
output eg_done;
input [12:0] reg2dp_height;
input [12:0] reg2dp_width;
input [1:0] reg2dp_in_precision;
input [1:0] reg2dp_proc_precision;
input reg2dp_perf_nan_inf_count_en;
output [31:0] dp2reg_status_inf_input_num;
output [31:0] dp2reg_status_nan_input_num;
output sdp_mrdma2cmux_valid;
input sdp_mrdma2cmux_ready;
output [32*8 +1:0] sdp_mrdma2cmux_pd;
input cmd2dat_dma_pvld;
output cmd2dat_dma_prdy;
input [14:0] cmd2dat_dma_pd;
input pfifo0_rd_pvld;
output pfifo0_rd_prdy;
input [8*8 -1:0] pfifo0_rd_pd;
input pfifo1_rd_pvld;
output pfifo1_rd_prdy;
input [8*8 -1:0] pfifo1_rd_pd;
input pfifo2_rd_pvld;
output pfifo2_rd_prdy;
input [8*8 -1:0] pfifo2_rd_pd;
input pfifo3_rd_pvld;
output pfifo3_rd_prdy;
input [8*8 -1:0] pfifo3_rd_pd;
reg eg_done;
wire cfg_di_16;
wire cfg_di_fp16;
wire cfg_di_int16;
wire cfg_di_int8;
wire cfg_do_int8;
wire cfg_mode_1x1_pack;
wire cfg_perf_nan_inf_count_en;
wire [13:0] size_of_beat;
reg [13:0] beat_cnt;
wire is_last_beat;
wire cmd2dat_dma_cube_end;
wire [13:0] cmd2dat_dma_size;
wire cmd_cube_end;
wire dat_accept;
wire dat_batch_end;
wire [32*8 -1:0] dat_data;
wire dat_layer_end;
wire [32*8 +1:0] dat_pd;
wire dat_rdy;
wire dat_vld;
wire fifo_vld;
wire pfifo0_sel;
wire pfifo1_sel;
wire pfifo2_sel;
wire pfifo3_sel;
wire [8*8 -1:0] pfifo0_rd_data;
wire [8*8 -1:0] pfifo1_rd_data;
wire [8*8 -1:0] pfifo2_rd_data;
wire [8*8 -1:0] pfifo3_rd_data;
//: my $k = 8/2;
//: foreach my $j (0..3) {
//: foreach my $i (0..${k}-1) {
//: print "wire    [15:0] pfifo${j}_data_byte${i}_16; \n";
//: }
//: }
//: foreach my $j (0..3) {
//: foreach my $i (0..${k}-1) {
//: print "wire    [31:0] pfifo${j}_data_ext_byte${i}_int16; \n";
//: print "wire    [31:0] pfifo${j}_data_ext_byte${i}_16; \n";
//: }
//: }
//: my $k = 8;
//: my $dw = $k * 8 -1;
//: foreach my $j (0..3) {
//: foreach my $i (0..${k}-1) {
//: print "wire     [7:0] pfifo${j}_data_byte${i}_8; \n";
//: }
//: }
//: foreach my $j (0..3) {
//: foreach my $i (0..${k}-1) {
//: print "wire    [31:0] pfifo${j}_data_ext_byte${i}_8; \n";
//: }
//: }
wire [32*8 -1:0] pfifo_data0_16;
wire [32*8 -1:0] pfifo_data1_16;
wire [32*8 -1:0] pfifo_data2_16;
wire [32*8 -1:0] pfifo_data3_16;
wire [32*8 -1:0] pfifo_data0_8;
wire [32*8 -1:0] pfifo_data1_8;
wire [32*8 -1:0] pfifo_data2_8;
wire [32*8 -1:0] pfifo_data3_8;
reg [32*8 -1:0] pfifo_data_r;
wire [32*8 -1:0] pfifo_data;
wire pfifo_sel;
wire pfifo_vld;
wire sdp_mrdma2cmux_layer_end;
//==============
// CFG
//==============
assign cfg_di_int8 = reg2dp_in_precision == 0 ;
assign cfg_di_int16 = reg2dp_in_precision == 1 ;
assign cfg_di_fp16 = reg2dp_in_precision == 2 ;
assign cfg_di_16 = cfg_di_int16 | cfg_di_fp16;
assign cfg_do_int8 = reg2dp_proc_precision == 0 ;
assign cfg_mode_1x1_pack = (reg2dp_width==0) & (reg2dp_height==0);
assign cfg_perf_nan_inf_count_en = reg2dp_perf_nan_inf_count_en;
//pop command dat fifo //
assign cmd2dat_dma_prdy = dat_accept & is_last_beat & fifo_vld & dat_rdy;
assign cmd2dat_dma_size[13:0] = cmd2dat_dma_pd[13:0];
assign cmd2dat_dma_cube_end = cmd2dat_dma_pd[14];
assign size_of_beat = {14 {cmd2dat_dma_pvld}} & cmd2dat_dma_size;
assign cmd_cube_end = {1 {cmd2dat_dma_pvld}} & cmd2dat_dma_cube_end;
always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
  if (!nvdla_core_rstn) begin
    beat_cnt <= {14{1'b0}};
  end else begin
    if (dat_accept) begin
        if (is_last_beat) begin
            beat_cnt <= 0;
        end else begin
            beat_cnt <= beat_cnt + 1;
        end
    end
  end
end
assign is_last_beat = (beat_cnt==size_of_beat);
assign pfifo0_sel = beat_cnt[1:0]==0;
assign pfifo1_sel = beat_cnt[1:0]==1;
assign pfifo2_sel = beat_cnt[1:0]==2;
assign pfifo3_sel = beat_cnt[1:0]==3;
assign pfifo_vld = (pfifo3_rd_pvld & pfifo3_sel) | (pfifo2_rd_pvld & pfifo2_sel) | (pfifo1_rd_pvld & pfifo1_sel) | (pfifo0_rd_pvld & pfifo0_sel);
assign fifo_vld = pfifo_vld;
assign dat_vld = fifo_vld; //& cmd2dat_dma_pvld;
assign pfifo0_rd_prdy = dat_rdy & pfifo0_sel; //& cmd2dat_dma_pvld;
assign pfifo1_rd_prdy = dat_rdy & pfifo1_sel; //& cmd2dat_dma_pvld;
assign pfifo2_rd_prdy = dat_rdy & pfifo2_sel; //& cmd2dat_dma_pvld;
assign pfifo3_rd_prdy = dat_rdy & pfifo3_sel; //& cmd2dat_dma_pvld;
assign pfifo0_rd_data = {8*8{pfifo0_sel}} & pfifo0_rd_pd;
assign pfifo1_rd_data = {8*8{pfifo1_sel}} & pfifo1_rd_pd;
assign pfifo2_rd_data = {8*8{pfifo2_sel}} & pfifo2_rd_pd;
assign pfifo3_rd_data = {8*8{pfifo3_sel}} & pfifo3_rd_pd;
//: my $k = 8/2;
//: foreach my $j (0..3) {
//: foreach my $i (0..${k}-1) {
//: print "assign pfifo${j}_data_byte${i}_16 = pfifo${j}_rd_data[${i}*16+15:${i}*16]; \n";
//: }
//: print "\n";
//: }
//: print "\n";
//: my $k = 8/2;
//: foreach my $j (0..3) {
//: foreach my $i (0..${k}-1) {
//: print "assign pfifo${j}_data_ext_byte${i}_int16 = {{16{pfifo${j}_data_byte${i}_16[15]}}, pfifo${j}_data_byte${i}_16[15:0]}; \n";
//: }
//: print "\n";
//: }
//: print "\n";
//: my $k = 8/2;
//: foreach my $j (0..3) {
//: foreach my $i (0..${k}-1) {
//: print "assign pfifo${j}_data_ext_byte${i}_16 = pfifo${j}_data_ext_byte${i}_int16; \n";
//: }
//: }
//: print "\n";
//: my $k = 8/2;
//: my $remain = $k*32;
//: foreach my $j (0..3) {
//: print "assign pfifo_data${j}_16 = {${remain}\'h0,";
//: foreach my $i (0..${k}-2) {
//: my $ii = $k - $i -1;
//: print "pfifo${j}_data_ext_byte${ii}_16,";
//: }
//: print "pfifo${j}_data_ext_byte0_16}; \n";
//: }
//// int8 ///////////
//: my $k = 8;
//: foreach my $j (0..3) {
//: foreach my $i (0..${k}-1) {
//: print "assign pfifo${j}_data_byte${i}_8 = pfifo${j}_rd_data[${i}*8+7:${i}*8]; \n";
//: }
//: print "\n";
//: }
//: print "\n";
//: my $k = 8;
//: foreach my $j (0..3) {
//: foreach my $i (0..${k}-1) {
//: print "assign pfifo${j}_data_ext_byte${i}_8 = {{24{pfifo${j}_data_byte${i}_8[7]}}, pfifo${j}_data_byte${i}_8[7:0]}; \n";
//: }
//: print "\n";
//: }
//: print "\n";
// INT8, concate
//: my $k = 8;
//: foreach my $j (0..3) {
//: print "assign pfifo_data${j}_8 = {";
//: foreach my $i (0..${k}-2) {
//: my $ii = $k - $i -1;
//: print "pfifo${j}_data_ext_byte${ii}_8,";
//: }
//: print "pfifo${j}_data_ext_byte0_8}; \n";
//: }
//=====PERF COUNT BEG=============
assign dp2reg_status_inf_input_num = 32'h0;
assign dp2reg_status_nan_input_num = 32'h0;
//=====PERF COUNT END=============
always @(
  pfifo0_sel
  or pfifo1_sel
  or pfifo2_sel
  or pfifo3_sel
  or cfg_di_16
  or pfifo_data0_8
  or pfifo_data1_8
  or pfifo_data2_8
  or pfifo_data3_8
  or pfifo_data0_16
  or pfifo_data1_16
  or pfifo_data2_16
  or pfifo_data3_16
  ) begin
//spyglass disable_block W171 W226
    case (1'b1)
     pfifo0_sel: pfifo_data_r = cfg_di_16 ? pfifo_data0_16 : pfifo_data0_8;
     pfifo1_sel: pfifo_data_r = cfg_di_16 ? pfifo_data1_16 : pfifo_data1_8;
     pfifo2_sel: pfifo_data_r = cfg_di_16 ? pfifo_data2_16 : pfifo_data2_8;
     pfifo3_sel: pfifo_data_r = cfg_di_16 ? pfifo_data3_16 : pfifo_data3_8;
    default : begin
                pfifo_data_r[32*8 -1:0] = {(32*8){`x_or_0}};
              end
    endcase
//spyglass enable_block W171 W226
end
assign dat_data = pfifo_data_r;
assign dat_accept = dat_vld & dat_rdy;
assign dat_layer_end = cmd_cube_end & is_last_beat;
assign dat_batch_end = cmd_cube_end & is_last_beat;
assign dat_pd[32*8 -1:0] = dat_data[32*8 -1:0];
assign dat_pd[32*8] = dat_batch_end ;
assign dat_pd[32*8 +1] = dat_layer_end ;
NV_NVDLA_SDP_MRDMA_EG_DOUT_pipe_p1 pipe_p1 (
   .nvdla_core_clk (nvdla_core_clk)
  ,.nvdla_core_rstn (nvdla_core_rstn)
  ,.dat_pd (dat_pd[32*8 +1:0])
  ,.dat_vld (dat_vld)
  ,.sdp_mrdma2cmux_ready (sdp_mrdma2cmux_ready)
  ,.dat_rdy (dat_rdy)
  ,.sdp_mrdma2cmux_pd (sdp_mrdma2cmux_pd[32*8 +1:0])
  ,.sdp_mrdma2cmux_valid (sdp_mrdma2cmux_valid)
  );
assign sdp_mrdma2cmux_layer_end = sdp_mrdma2cmux_pd[32*8 +1];
always @(posedge nvdla_core_clk or negedge nvdla_core_rstn) begin
  if (!nvdla_core_rstn) begin
    eg_done <= 1'b0;
  end else begin
  eg_done <= sdp_mrdma2cmux_layer_end & sdp_mrdma2cmux_valid & sdp_mrdma2cmux_ready;
  end
end
//Shift-left - unsigned shift argument one bit more
endmodule // NV_NVDLA_SDP_MRDMA_EG_dout
// **************************************************************************************************************
// Generated by ::pipe -m -bc -is sdp_mrdma2cmux_pd (sdp_mrdma2cmux_valid, sdp_mrdma2cmux_ready) <= dat_pd[32*8 +1:0] (dat_vld,dat_rdy)
// **************************************************************************************************************
module NV_NVDLA_SDP_MRDMA_EG_DOUT_pipe_p1 (
   nvdla_core_clk
  ,nvdla_core_rstn
  ,dat_pd
  ,dat_vld
  ,dat_rdy
  ,sdp_mrdma2cmux_pd
  ,sdp_mrdma2cmux_valid
  ,sdp_mrdma2cmux_ready
  );
input nvdla_core_clk;
input nvdla_core_rstn;
input [32*8 +1:0] dat_pd;
input dat_vld;
output dat_rdy;
output [32*8 +1:0] sdp_mrdma2cmux_pd;
output sdp_mrdma2cmux_valid;
input sdp_mrdma2cmux_ready;
//: my $dw = 32*8 +2;
//: &eperl::pipe("-is -wid $dw -do sdp_mrdma2cmux_pd -vo sdp_mrdma2cmux_valid -ri sdp_mrdma2cmux_ready -di dat_pd -vi dat_vld -ro dat_rdy");
endmodule // NV_NVDLA_SDP_MRDMA_EG_DOUT_pipe_p1
