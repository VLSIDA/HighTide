// ================================================================
// NVDLA Open Source Project
//
// Copyright(c) 2016 - 2017 NVIDIA Corporation. Licensed under the
// NVDLA Open Hardware License; Check "LICENSE" which comes with
// this distribution for more information.
// ================================================================
// File Name: NV_NVDLA_DMAIF_rdrsp.v
`include "simulate_x_tick.vh"
module NV_NVDLA_DMAIF_rdrsp (
   nvdla_core_clk
  ,nvdla_core_rstn
  ,mcif_rd_rsp_pd
  ,mcif_rd_rsp_valid
  ,mcif_rd_rsp_ready
  ,dmaif_rd_rsp_pd
  ,dmaif_rd_rsp_pvld
  ,dmaif_rd_rsp_prdy
);
//////////////////////////////////////////////
input nvdla_core_clk;
input nvdla_core_rstn;
//: my $dmaif = 64;
//: my $mask = int($dmaif/8/8);
//: my $maskbw;
//: $maskbw = $mask;
//: my $dmabw = ( $dmaif + $maskbw );
//: print qq( input [${dmabw}-1:0] mcif_rd_rsp_pd; \n);
//: print qq( output [${dmabw}-1:0] dmaif_rd_rsp_pd; \n);
input mcif_rd_rsp_valid;
output mcif_rd_rsp_ready;
output dmaif_rd_rsp_pvld;
input dmaif_rd_rsp_prdy;
//////////////////////////////////////////////
wire dma_rd_rsp_rdy;
wire dma_rd_rsp_vld;
//: my $dmaif = 64;
//: my $mask = int($dmaif/8/8);
//: my $maskbw;
//: $maskbw = $mask;
//: my $dmabw = ( $dmaif + $maskbw );
//: print qq( wire [${dmabw}-1:0] dma_rd_rsp_pd; \n);
//////////////////////////////////////////////
///////////////////////////////////////
// pipe before mux
///////////////////////////////////////
//: my $dmaif = 64;
//: my $mask = int($dmaif/8/8);
//: my $maskbw;
//: $maskbw = $mask;
//: my $dmabw = ( $dmaif + $maskbw );
//: &eperl::pipe(" -wid $dmabw -is -do mcif_rd_rsp_pd_d0 -vo mcif_rd_rsp_valid_d0 -ri dma_rd_rsp_rdy -di mcif_rd_rsp_pd -vi mcif_rd_rsp_valid -ro mcif_rd_rsp_ready  ");
///////////////////////////////////////
//mux
///////////////////////////////////////
assign dma_rd_rsp_vld = mcif_rd_rsp_valid_d0;
//: my $dmaif = 64;
//: my $mask = int($dmaif/8/8);
//: my $maskbw;
//: $maskbw = $mask;
//: my $dmabw = ( $dmaif + $maskbw );
//: print qq(
//: assign dma_rd_rsp_pd = ({${dmabw}{mcif_rd_rsp_valid_d0}} & mcif_rd_rsp_pd_d0);
//: );
// //: &eperl::assert(" -type never -desc 'DMAIF: mcif and cvif should never return data both' -expr 'mcif_rd_rsp_valid_d0 & cvif_rd_rsp_valid_d0' ");
///////////////////////////////////////
// pipe after mux
///////////////////////////////////////
//: my $dmaif = 64;
//: my $mask = int($dmaif/8/8);
//: my $maskbw;
//: $maskbw = $mask;
//: my $dmabw = ( $dmaif + $maskbw );
//: &eperl::pipe(" -wid $dmabw -is -do dmaif_rd_rsp_pd -vo dmaif_rd_rsp_pvld -ri dmaif_rd_rsp_prdy -di dma_rd_rsp_pd -vi dma_rd_rsp_vld -ro dma_rd_rsp_rdy_f  ");
assign dma_rd_rsp_rdy = dma_rd_rsp_rdy_f;
endmodule
