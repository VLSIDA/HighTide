module Sram_2048x128(
  input          clock,
  input          enable,
  input          write,
  input  [10:0]   addr,
  input  [127:0] wdata,
  input  [15:0] wmask,
  output [127:0] rdata
);
	fakeram_512x128 sramModules_0(
		.clock(clock),
		.enable(enable),
		.write(write),
		.addr(addr),
		.wdata(wdata),
		.wmask(wmask),
		.rdata(rdata)
	);
endmodule
