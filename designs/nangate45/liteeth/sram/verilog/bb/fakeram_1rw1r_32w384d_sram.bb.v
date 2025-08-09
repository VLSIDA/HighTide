module fakeram_1rw1r_32w384d_sram
(
   r0_rd_out,
   r0_clk,
   r0_ce_in,
   r0_addr_in,
   rw0_wd_in,
   rw0_we_in,
   rw0_rd_out,
   rw0_clk,
   rw0_ce_in,
   rw0_addr_in,
);
   parameter BITS = 32;
   parameter WORD_DEPTH = 384;
   parameter ADDR_WIDTH = 9;
   parameter corrupt_mem_on_X_p = 1;

   input                    r0_clk;
   input                    r0_ce_in;
   input  [ADDR_WIDTH-1:0]  r0_addr_in;
   output reg [BITS-1:0]    r0_rd_out;
   input                    rw0_clk;
   input                    rw0_ce_in;
   input  [ADDR_WIDTH-1:0]  rw0_addr_in;
   output reg [BITS-1:0]    rw0_rd_out;
   input                    rw0_we_in;
   input  [BITS-1:0]        rw0_wd_in;

endmodule
