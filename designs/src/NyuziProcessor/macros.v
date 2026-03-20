module fakeram_1r1w_1x256 (
	clk,
	read_en,
	read_addr,
	read_data,
	write_en,
	write_addr,
	write_data
);
	parameter DATA_WIDTH = 1;
	parameter SIZE = 256;
	parameter READ_DURING_WRITE = "NEW_DATA";
	parameter ADDR_WIDTH = $clog2(SIZE);
	input clk;
	input read_en;
	input [ADDR_WIDTH - 1:0] read_addr;
	output reg [DATA_WIDTH - 1:0] read_data;
	input write_en;
	input [ADDR_WIDTH - 1:0] write_addr;
	input [DATA_WIDTH - 1:0] write_data;
	fakeram_1x256_1r1w sram (
		.r0_clk       (clk),
		.w0_clk       (clk),
		.r0_rd_out (read_data),
		.r0_addr_in   (read_addr),
		.w0_addr_in   (write_addr),
		.w0_we_in  (write_en),
		.w0_wd_in  (write_data),
   		.r0_ce_in 	   (read_en),
   		.w0_ce_in	   (1'b1)
	);
endmodule
module fakeram_1r1w_18x256 (
	clk,
	read_en,
	read_addr,
	read_data,
	write_en,
	write_addr,
	write_data
);
	parameter DATA_WIDTH = 18;
	parameter SIZE = 256;
	parameter READ_DURING_WRITE = "NEW_DATA";
	parameter ADDR_WIDTH = $clog2(SIZE);
	input clk;
	input read_en;
	input [ADDR_WIDTH - 1:0] read_addr;
	output reg [DATA_WIDTH - 1:0] read_data;
	input write_en;
	input [ADDR_WIDTH - 1:0] write_addr;
	input [DATA_WIDTH - 1:0] write_data;
	fakeram_18x256_1r1w sram (
		.r0_clk       (clk),
		.w0_clk       (clk),
		.r0_rd_out (read_data),
		.r0_addr_in   (read_addr),
		.w0_addr_in   (write_addr),
		.w0_we_in  (write_en),
		.w0_wd_in  (write_data),
   		.r0_ce_in 	   (read_en),
   		.w0_ce_in	   (1'b1)
	);
endmodule
module fakeram_1r1w_16x52 (
	clk,
	read_en,
	read_addr,
	read_data,
	write_en,
	write_addr,
	write_data
);
	parameter DATA_WIDTH = 16;
	parameter SIZE = 52;
	parameter READ_DURING_WRITE = "NEW_DATA";
	parameter ADDR_WIDTH = $clog2(SIZE);
	input clk;
	input read_en;
	input [ADDR_WIDTH - 1:0] read_addr;
	output reg [DATA_WIDTH - 1:0] read_data;
	input write_en;
	input [ADDR_WIDTH - 1:0] write_addr;
	input [DATA_WIDTH - 1:0] write_data;
	fakeram_16x52_1r1w sram (
		.r0_clk       (clk),
		.w0_clk       (clk),
		.r0_rd_out (read_data),
		.r0_addr_in   (read_addr),
		.w0_addr_in   (write_addr),
		.w0_we_in  (write_en),
		.w0_wd_in  (write_data),
   		.r0_ce_in 	   (read_en),
   		.w0_ce_in	   (1'b1)
	);
endmodule
module fakeram_1r1w_20x64 (
	clk,
	read_en,
	read_addr,
	read_data,
	write_en,
	write_addr,
	write_data
);
	parameter DATA_WIDTH = 20;
	parameter SIZE = 64;
	parameter READ_DURING_WRITE = "NEW_DATA";
	parameter ADDR_WIDTH = $clog2(SIZE);
	input clk;
	input read_en;
	input [ADDR_WIDTH - 1:0] read_addr;
	output reg [DATA_WIDTH - 1:0] read_data;
	input write_en;
	input [ADDR_WIDTH - 1:0] write_addr;
	input [DATA_WIDTH - 1:0] write_data;
	fakeram_20x64_1r1w sram (
		.r0_clk       (clk),
		.w0_clk       (clk),
		.r0_rd_out (read_data),
		.r0_addr_in   (read_addr),
		.w0_addr_in   (write_addr),
		.w0_we_in  (write_en),
		.w0_wd_in  (write_data),
   		.r0_ce_in 	   (read_en),
   		.w0_ce_in	   (1'b1)
	);
endmodule
module fakeram_1r1w_512x256 (
	clk,
	read_en,
	read_addr,
	read_data,
	write_en,
	write_addr,
	write_data
);
	parameter DATA_WIDTH = 512;
	parameter SIZE = 256;
	parameter READ_DURING_WRITE = "NEW_DATA";
	parameter ADDR_WIDTH = $clog2(SIZE);
	input clk;
	input read_en;
	input [ADDR_WIDTH - 1:0] read_addr;
	output reg [DATA_WIDTH - 1:0] read_data;
	input write_en;
	input [ADDR_WIDTH - 1:0] write_addr;
	input [DATA_WIDTH - 1:0] write_data;
	fakeram_512x256_1r1w sram (
		.r0_clk       (clk),
		.w0_clk       (clk),
		.r0_rd_out    (read_data),
		.r0_addr_in   (read_addr),
		.w0_addr_in   (write_addr),
		.w0_we_in     (write_en),
		.w0_wd_in     (write_data),
   		.r0_ce_in 	  (read_en),
   		.w0_ce_in	  (1'b1)
	);
endmodule
module fakeram_1r1w_512x2048 (
	clk,
	read_en,
	read_addr,
	read_data,
	write_en,
	write_addr,
	write_data
);
	parameter DATA_WIDTH = 512;
	parameter SIZE = 2048;
	parameter READ_DURING_WRITE = "NEW_DATA";
	parameter ADDR_WIDTH = $clog2(SIZE);
	input clk;
	input read_en;
	input [ADDR_WIDTH - 1:0] read_addr;
	output reg [DATA_WIDTH - 1:0] read_data;
	input write_en;
	input [ADDR_WIDTH - 1:0] write_addr;
	input [DATA_WIDTH - 1:0] write_data;
	fakeram_512x2048_1r1w sram (
		.r0_clk       (clk),
		.w0_clk       (clk),
		.r0_rd_out    (read_data),
		.r0_addr_in   (read_addr),
		.w0_addr_in   (write_addr),
		.w0_we_in     (write_en),
		.w0_wd_in     (write_data),
   		.r0_ce_in 	  (read_en),
   		.w0_ce_in	  (1'b1)
	);
endmodule
module fakeram_2r1w_20x64 (
	clk,
	read1_en,
	read1_addr,
	read1_data,
	read2_en,
	read2_addr,
	read2_data,
	write_en,
	write_addr,
	write_data
);
	parameter DATA_WIDTH = 20;
	parameter SIZE = 64;
	parameter READ_DURING_WRITE = "NEW_DATA";
	parameter ADDR_WIDTH = $clog2(SIZE);
	input clk;
	input read1_en;
	input [ADDR_WIDTH - 1:0] read1_addr;
	output reg [DATA_WIDTH - 1:0] read1_data;
	input read2_en;
	input [ADDR_WIDTH - 1:0] read2_addr;
	output reg [DATA_WIDTH - 1:0] read2_data;
	input write_en;
	input [ADDR_WIDTH - 1:0] write_addr;
	input [DATA_WIDTH - 1:0] write_data;
	fakeram_20x64_2r1w sram (
		.r0_clk       (clk),
		.r1_clk       (clk),
		.w0_clk       (clk),
		.r0_rd_out (read1_data),
		.r1_rd_out (read2_data),
		.r0_addr_in   (read1_addr),
		.r1_addr_in   (read2_addr),
		.w0_addr_in   (write_addr),
		.w0_we_in  (write_en),
		.w0_wd_in  (write_data),
   		.r0_ce_in 	   (read1_en),
		.r1_ce_in      (read2_en),
   		.w0_ce_in	   (1'b1)
	);
endmodule
module fakeram_2r1w_32x128 (
	clk,
	read1_en,
	read1_addr,
	read1_data,
	read2_en,
	read2_addr,
	read2_data,
	write_en,
	write_addr,
	write_data
);
	parameter DATA_WIDTH = 32;
	parameter SIZE = 128;
	parameter READ_DURING_WRITE = "NEW_DATA";
	parameter ADDR_WIDTH = $clog2(SIZE);
	input clk;
	input read1_en;
	input [ADDR_WIDTH - 1:0] read1_addr;
	output reg [DATA_WIDTH - 1:0] read1_data;
	input read2_en;
	input [ADDR_WIDTH - 1:0] read2_addr;
	output reg [DATA_WIDTH - 1:0] read2_data;
	input write_en;
	input [ADDR_WIDTH - 1:0] write_addr;
	input [DATA_WIDTH - 1:0] write_data;
	fakeram_32x128_2r1w sram (
		.r0_clk       (clk),
		.r1_clk       (clk),
		.w0_clk       (clk),
		.r0_rd_out (read1_data),
		.r1_rd_out (read2_data),
		.r0_addr_in   (read1_addr),
		.r1_addr_in   (read2_addr),
		.w0_addr_in   (write_addr),
		.w0_we_in  (write_en),
		.w0_wd_in  (write_data),
   		.r0_ce_in 	   (read1_en),
		.r1_ce_in      (read2_en),
   		.w0_ce_in	   (1'b1)
	);
endmodule