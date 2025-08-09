module fakeram_1rw1r_32w384d_8wm_sram
(
   r0_rd_out,
   r0_clk,
   r0_ce_in,
   r0_addr_in,
   rw0_wd_in,
   rw0_we_in,
   rw0_wmask_in,
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
   input  [3:0]             rw0_wmask_in;

   reg    [BITS-1:0]        mem [0:WORD_DEPTH-1];
   integer j;

   always @(posedge r0_clk) begin
      if (r0_ce_in) begin
         // Read-first
         r0_rd_out <= mem[r0_addr_in];
      end
      else begin
         // Make sure read fails if r0_ce_in is low
         r0_rd_out <= 'x;
      end
   end

   always @(posedge rw0_clk) begin
      if (rw0_ce_in) begin
         // Read-first
         rw0_rd_out <= mem[rw0_addr_in];
         // Write Port
         if (corrupt_mem_on_X_p &&
             ((^rw0_we_in === 1'bx) || (^rw0_addr_in === 1'bx))) begin
            // WEN or ADDR is unknown, so corrupt entire array (using unsynthesizeable for loop)
            for (j = 0; j < WORD_DEPTH; j = j + 1) begin
               mem[j] <= 'x;
            end
            $display("warning: rw0_ce_in=1, rw0_we_in is %b, rw0_addr_in = %x in fakeram_1rw1r_32w384d_8wm_sram", rw0_we_in, rw0_addr_in);
         end
         else if (rw0_we_in) begin 
            if (rw0_wmask_in[0])
               mem[rw0_addr_in][7:0] <= (rw0_wd_in[7:0]);
            if (rw0_wmask_in[1])
               mem[rw0_addr_in][15:8] <= (rw0_wd_in[15:8]);
            if (rw0_wmask_in[2])
               mem[rw0_addr_in][23:16] <= (rw0_wd_in[23:16]);
            if (rw0_wmask_in[3])
               mem[rw0_addr_in][31:24] <= (rw0_wd_in[31:24]);
         end
      end
      else begin
         // Make sure read fails if rw0_ce_in is low
         rw0_rd_out <= 'x;
      end
   end


   // Timing check placeholders (will be replaced during SDF back-annotation)
   `ifdef SRAM_TIMING   reg notifier;
   specify
      (posedge r0_clk *> r0_rd_out) = (0, 0);
      $width     (posedge r0_clk,            0, 0, notifier);
      $width     (negedge r0_clk,            0, 0, notifier);
      $period    (posedge r0_clk,            0,    notifier);
      $setuphold (posedge r0_clk, r0_ce_in,     0, 0, notifier);
      $setuphold (posedge r0_clk, r0_addr_in,   0, 0, notifier);

      (posedge rw0_clk *> rw0_rd_out) = (0, 0);
      $width     (posedge rw0_clk,            0, 0, notifier);
      $width     (negedge rw0_clk,            0, 0, notifier);
      $period    (posedge rw0_clk,            0,    notifier);
      $setuphold (posedge rw0_clk, rw0_we_in,     0, 0, notifier);
      $setuphold (posedge rw0_clk, rw0_wd_in,     0, 0, notifier);
      $setuphold (posedge rw0_clk, rw0_wmask_in,     0, 0, notifier);
      $setuphold (posedge rw0_clk, rw0_ce_in,     0, 0, notifier);
      $setuphold (posedge rw0_clk, rw0_addr_in,   0, 0, notifier);

   endspecify
   `endif

endmodule
