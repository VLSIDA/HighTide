module fakeram_2048x128(
	clock,
	enable,
	addr,
	rdata,
	write,
	wdata,
    wmask
);
	parameter DATA_WIDTH = 2048;
	parameter SIZE = 128;
	parameter READ_DURING_WRITE = "NEW_DATA";
	parameter ADDR_WIDTH = $clog2(SIZE);
	input clock;
	input enable;
	input [ADDR_WIDTH - 1:0] addr;
    input [15:0] wmask;
	output reg [DATA_WIDTH - 1:0] rdata;
	input write;
	input [DATA_WIDTH - 1:0] wdata;
	fakeram_2048x128_1rw sram (
		.rw0_clk       (clock),
		.rw0_rd_out (rdata),
		.rw0_addr_in   (addr),
		.rw0_we_in  (write),
		.rw0_wd_in  (wdata),
   		.rw0_ce_in 	   (enable),
        .rw0_wmask_in (wmask)
	);
endmodule
module fakeram_512x128(
	clock,
	enable,
	addr,
	rdata,
	write,
	wdata,
    wmask
);
	parameter DATA_WIDTH = 512;
	parameter SIZE = 128;
	parameter READ_DURING_WRITE = "NEW_DATA";
	parameter ADDR_WIDTH = $clog2(SIZE);
	input clock;
	input enable;
	input [ADDR_WIDTH - 1:0] addr;
    input [15:0] wmask;
	output reg [DATA_WIDTH - 1:0] rdata;
	input write;
	input [DATA_WIDTH - 1:0] wdata;
	fakeram_512x128_1rw sram (
		.rw0_clk       (clock),
		.rw0_rd_out (rdata),
		.rw0_addr_in   (addr),
		.rw0_we_in  (write),
		.rw0_wd_in  (wdata),
   		.rw0_ce_in 	   (enable),
        .rw0_wmask_in (wmask)
	);
endmodule