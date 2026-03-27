////////////////////////////////////////////////////////////////////////
// Macro wrappers for SRAM primitives (1RW with bit mask)
// Auto-generated — do not edit manually
////////////////////////////////////////////////////////////////////////

module fakeram_1rw_64x64 (
    clk,
    en,
    we,
    wmask,
    addr,
    wdata,
    rdata
);
    parameter DATA_WIDTH = 64;
    parameter SIZE       = 64;
    parameter ADDR_WIDTH = $clog2(SIZE);

    input                       clk;
    input                       en;
    input                       we;
    input  [DATA_WIDTH-1:0]     wmask;
    input  [ADDR_WIDTH-1:0]     addr;
    input  [DATA_WIDTH-1:0]     wdata;
    output reg [DATA_WIDTH-1:0] rdata;

    fakeram_1rw_64x64 fakeram_1rw_64x64_inst (
        .rw0_clk      (clk),
        .rw0_ce_in    (en),
        .rw0_we_in    (we),
        .rw0_wmask_in (wmask),
        .rw0_addr_in  (addr),
        .rw0_wd_in    (wdata),
        .rw0_rd_out   (rdata)
    );
endmodule


module fakeram_1rw_48x256 (
    clk,
    en,
    we,
    wmask,
    addr,
    wdata,
    rdata
);
    parameter DATA_WIDTH = 48;
    parameter SIZE       = 256;
    parameter ADDR_WIDTH = $clog2(SIZE);

    input                       clk;
    input                       en;
    input                       we;
    input  [DATA_WIDTH-1:0]     wmask;
    input  [ADDR_WIDTH-1:0]     addr;
    input  [DATA_WIDTH-1:0]     wdata;
    output reg [DATA_WIDTH-1:0] rdata;

    fakeram_1rw_48x256 fakeram_1rw_48x256_inst (
        .rw0_clk      (clk),
        .rw0_ce_in    (en),
        .rw0_we_in    (we),
        .rw0_wmask_in (wmask),
        .rw0_addr_in  (addr),
        .rw0_wd_in    (wdata),
        .rw0_rd_out   (rdata)
    );
endmodule


module fakeram_1rw_64x256 (
    clk,
    en,
    we,
    wmask,
    addr,
    wdata,
    rdata
);
    parameter DATA_WIDTH = 64;
    parameter SIZE       = 256;
    parameter ADDR_WIDTH = $clog2(SIZE);

    input                       clk;
    input                       en;
    input                       we;
    input  [DATA_WIDTH-1:0]     wmask;
    input  [ADDR_WIDTH-1:0]     addr;
    input  [DATA_WIDTH-1:0]     wdata;
    output reg [DATA_WIDTH-1:0] rdata;

    fakeram_1rw_64x256 fakeram_1rw_64x256_inst (
        .rw0_clk      (clk),
        .rw0_ce_in    (en),
        .rw0_we_in    (we),
        .rw0_wmask_in (wmask),
        .rw0_addr_in  (addr),
        .rw0_wd_in    (wdata),
        .rw0_rd_out   (rdata)
    );
endmodule


module fakeram_1rw_64x512 (
    clk,
    en,
    we,
    wmask,
    addr,
    wdata,
    rdata
);
    parameter DATA_WIDTH = 64;
    parameter SIZE       = 512;
    parameter ADDR_WIDTH = $clog2(SIZE);

    input                       clk;
    input                       en;
    input                       we;
    input  [DATA_WIDTH-1:0]     wmask;
    input  [ADDR_WIDTH-1:0]     addr;
    input  [DATA_WIDTH-1:0]     wdata;
    output reg [DATA_WIDTH-1:0] rdata;

    fakeram_1rw_64x512 fakeram_1rw_64x512_inst (
        .rw0_clk      (clk),
        .rw0_ce_in    (en),
        .rw0_we_in    (we),
        .rw0_wmask_in (wmask),
        .rw0_addr_in  (addr),
        .rw0_wd_in    (wdata),
        .rw0_rd_out   (rdata)
    );
endmodule


module fakeram_1rw_64x1024 (
    clk,
    en,
    we,
    wmask,
    addr,
    wdata,
    rdata
);
    parameter DATA_WIDTH = 64;
    parameter SIZE       = 1024;
    parameter ADDR_WIDTH = $clog2(SIZE);

    input                       clk;
    input                       en;
    input                       we;
    input  [DATA_WIDTH-1:0]     wmask;
    input  [ADDR_WIDTH-1:0]     addr;
    input  [DATA_WIDTH-1:0]     wdata;
    output reg [DATA_WIDTH-1:0] rdata;

    fakeram_1rw_64x1024 fakeram_1rw_64x1024_inst (
        .rw0_clk      (clk),
        .rw0_ce_in    (en),
        .rw0_we_in    (we),
        .rw0_wmask_in (wmask),
        .rw0_addr_in  (addr),
        .rw0_wd_in    (wdata),
        .rw0_rd_out   (rdata)
    );
endmodule


module fakeram_1rw_64x2048 (
    clk,
    en,
    we,
    wmask,
    addr,
    wdata,
    rdata
);
    parameter DATA_WIDTH = 64;
    parameter SIZE       = 2048;
    parameter ADDR_WIDTH = $clog2(SIZE);

    input                       clk;
    input                       en;
    input                       we;
    input  [DATA_WIDTH-1:0]     wmask;
    input  [ADDR_WIDTH-1:0]     addr;
    input  [DATA_WIDTH-1:0]     wdata;
    output reg [DATA_WIDTH-1:0] rdata;

    fakeram_1rw_64x2048 fakeram_1rw_64x2048_inst (
        .rw0_clk      (clk),
        .rw0_ce_in    (en),
        .rw0_we_in    (we),
        .rw0_wmask_in (wmask),
        .rw0_addr_in  (addr),
        .rw0_wd_in    (wdata),
        .rw0_rd_out   (rdata)
    );
endmodule
