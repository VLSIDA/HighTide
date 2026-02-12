module fakeram_w16_l8192
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
   parameter WORD_DEPTH = 4096;
   parameter ADDR_WIDTH = 12;
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

   reg    [BITS-1:0]        mem [0:WORD_DEPTH-1];
   integer j;

   always @(posedge rw0_clk) begin
      if (rw0_ce_in) begin
         // Write Port
         if (corrupt_mem_on_X_p &&
             ((^rw0_we_in === 1'bx) || (^rw0_addr_in === 1'bx))) begin
            // WEN or ADDR is unknown, so corrupt entire array (using unsynthesizeable for loop)
            for (j = 0; j < WORD_DEPTH; j = j + 1) begin
               mem[j] <= 'x;
            end
            $display("warning: rw0_ce_in=1, rw0_we_in is %b, rw0_addr_in = %x in fakeram_w16_l8192", rw0_we_in, rw0_addr_in);
         end
         else if (rw0_we_in) begin 
            mem[rw0_addr_in] <= rw0_wd_in;
         end
         // Read Port
         rw0_rd_out <= mem[rw0_addr_in];
      end
      else begin
         // Make sure read fails if rw0_ce_in is low
         rw0_rd_out <= 'x;
      end
   end

   always @(posedge rw1_clk) begin
      if (rw1_ce_in) begin
         // Write Port
         if (corrupt_mem_on_X_p &&
             ((^rw1_we_in === 1'bx) || (^rw1_addr_in === 1'bx))) begin
            // WEN or ADDR is unknown, so corrupt entire array (using unsynthesizeable for loop)
            for (j = 0; j < WORD_DEPTH; j = j + 1) begin
               mem[j] <= 'x;
            end
            $display("warning: rw1_ce_in=1, rw1_we_in is %b, rw1_addr_in = %x in fakeram_w16_l8192", rw1_we_in, rw1_addr_in);
         end
         else if (rw1_we_in) begin 
            mem[rw1_addr_in] <= rw1_wd_in;
         end
         // Read Port
         rw1_rd_out <= mem[rw1_addr_in];
      end
      else begin
         // Make sure read fails if rw1_ce_in is low
         rw1_rd_out <= 'x;
      end
   end


   // Timing check placeholders (will be replaced during SDF back-annotation)
   `ifdef SRAM_TIMING   reg notifier;
   specify
      (posedge rw0_clk *> rw0_rd_out) = (0, 0);
      (posedge rw1_clk *> rw1_rd_out) = (0, 0);
      $width     (posedge rw0_clk,            0, 0, notifier);
      $width     (negedge rw0_clk,            0, 0, notifier);
      $period    (posedge rw0_clk,            0,    notifier);
      $setuphold (posedge rw0_clk, rw0_we_in,     0, 0, notifier);
      $setuphold (posedge rw0_clk, rw0_wd_in,     0, 0, notifier);
      $setuphold (posedge rw0_clk, rw0_ce_in,     0, 0, notifier);
      $setuphold (posedge rw0_clk, rw0_addr_in,   0, 0, notifier);

      $width     (posedge rw1_clk,            0, 0, notifier);
      $width     (negedge rw1_clk,            0, 0, notifier);
      $period    (posedge rw1_clk,            0,    notifier);
      $setuphold (posedge rw1_clk, rw1_we_in,     0, 0, notifier);
      $setuphold (posedge rw1_clk, rw1_wd_in,     0, 0, notifier);
      $setuphold (posedge rw1_clk, rw1_ce_in,     0, 0, notifier);
      $setuphold (posedge rw1_clk, rw1_addr_in,   0, 0, notifier);

   endspecify
   `endif

endmodule
