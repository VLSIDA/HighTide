// ===== FakeRAM wrappers for Xilinx BRAM IPs =====
// The upstream source references seven IP_*_BRAM modules but never defines
// them (they are Xilinx IP-catalog blocks). Define them here as thin wrappers
// around bsg_fakeram-style SRAM macros so the ASIC flow has implementations.
//
// Two interface flavors:
//   1r1w (separate read/write ports) — clka/wea/addra/dina + clkb/rstb/addrb/doutb
//   1rw  (single read-write port)    — clka/rsta/wea/addra/dina/douta
//
// Bodies are generated per platform from dev/generated/fakeram_<platform>.cfg.
// Each physical macro implements one depth bank, despite its aggregate-depth name.
// Synchronous bank selection follows the read clock; no extra read cycle is added.
// Reset and same-address read/write behavior remain the macro/user contract.
//
// The inner fakeram macros (fakeram_*_1r1w / fakeram_*_1rw) are blackboxed by
// yosys and resolved at P&R using the platform's LEF/LIB.

// ----- iact address SRAM in the GLB cluster (1r1w) -----
module IP_Iact_Addr_SRAM_BRAM (
    input         clka,
    input         wea,
    input  [8:0]  addra,
    input  [6:0]  dina,

    input         clkb,
    input         rstb,
    input  [8:0]  addrb,
    output [6:0]  doutb
);
@fakeram_7x512_1r1w@
endmodule

// ----- iact data SRAM in the GLB cluster (1r1w) -----
module IP_Iact_Data_SRAM_BRAM (
    input         clka,
    input         wea,
    input  [10:0] addra,
    input  [11:0] dina,

    input         clkb,
    input         rstb,
    input  [10:0] addrb,
    output [11:0] doutb
);
@fakeram_12x2048_1r1w@
endmodule

// ----- psum data SRAM in the GLB cluster (1r1w, signed 21-bit) -----
module IP_Psum_Data_SRAM_BRAM (
    input                clka,
    input                wea,
    input  [8:0]         addra,
    input  signed [20:0] dina,

    input                clkb,
    input                rstb,
    input  [8:0]         addrb,
    output signed [20:0] doutb
);
@fakeram_21x512_1r1w@
endmodule

// ----- Per-PE iact data scratchpad (1rw, 256x13) -----
module IP_Iact_DATA_Spad_BRAM (
    input         clka,
    input         rsta,
    input         wea,
    input  [7:0]  addra,
    input  [12:0] dina,
    output [12:0] douta
);
@fakeram_13x256_1rw@
endmodule

// ----- Per-PE weight data scratchpad (1rw, 128x12) -----
module IP_Weight_DATA_Spad_BRAM (
    input         clka,
    input         rsta,
    input         wea,
    input  [6:0]  addra,
    input  [11:0] dina,
    output [11:0] douta
);
@fakeram_12x128_1rw@
endmodule

// ----- Per-PE psum scratchpad (1r1w, 32x21 signed) -----
module IP_Psum_DATA_Spad_BRAM (
    input                clka,
    input                wea,
    input  [4:0]         addra,
    input  signed [20:0] dina,

    input                clkb,
    input                rstb,
    input  [4:0]         addrb,
    output signed [20:0] doutb
);
@fakeram_21x32_1r1w@
endmodule

// ----- Psum rearrange BRAM at top level (1r1w, 4096x8 signed) -----
module IP_Psum_Rearrange_BRAM (
    input               clka,
    input               wea,
    input  [11:0]       addra,
    input  signed [7:0] dina,

    input               clkb,
    input               rstb,
    input  [11:0]       addrb,
    output signed [7:0] doutb
);
@fakeram_8x4096_1r1w@
endmodule
