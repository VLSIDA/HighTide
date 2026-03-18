module fakeram7_64x512
(
   rw0_wd_in,
   rw0_we_in,
   rw0_wmask_in,
   rw0_rd_out,
   rw0_clk,
   rw0_ce_in,
   rw0_addr_in,
);
   parameter BITS = 512;
   parameter WORD_DEPTH = 64;
   parameter ADDR_WIDTH = 6;
   parameter corrupt_mem_on_X_p = 1;

   input                    rw0_clk;
   input                    rw0_ce_in;
   input  [ADDR_WIDTH-1:0]  rw0_addr_in;
   output reg [BITS-1:0]    rw0_rd_out;
   input                    rw0_we_in;
   input  [BITS-1:0]        rw0_wd_in;
   input  [0:0]             rw0_wmask_in;

endmodule
