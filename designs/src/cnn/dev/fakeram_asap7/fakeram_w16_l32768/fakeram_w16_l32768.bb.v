module fakeram_w16_l32768
(
   rw0_wd_in,
   rw0_we_in,
   rw0_rd_out,
   rw0_clk,
   rw0_ce_in,
   rw0_addr_in,
   rw1_wd_in,
   rw1_we_in,
   rw1_rd_out,
   rw1_clk,
   rw1_ce_in,
   rw1_addr_in,
);
   parameter BITS = 16;
   parameter WORD_DEPTH = 16384;
   parameter ADDR_WIDTH = 14;
   parameter corrupt_mem_on_X_p = 1;

   input                    rw0_clk;
   input                    rw0_ce_in;
   input  [ADDR_WIDTH-1:0]  rw0_addr_in;
   output reg [BITS-1:0]    rw0_rd_out;
   input                    rw0_we_in;
   input  [BITS-1:0]        rw0_wd_in;
   input                    rw1_clk;
   input                    rw1_ce_in;
   input  [ADDR_WIDTH-1:0]  rw1_addr_in;
   output reg [BITS-1:0]    rw1_rd_out;
   input                    rw1_we_in;
   input  [BITS-1:0]        rw1_wd_in;

endmodule
