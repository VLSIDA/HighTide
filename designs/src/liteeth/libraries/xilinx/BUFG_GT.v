///////////////////////////////////////////////////////////////////////////////
//     Copyright (c) 1995/2019 Xilinx, Inc.
//
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /     Vendor      : Xilinx
// \   \   \/      Version     : 2020.1
//  \   \          Description : Xilinx Unified Simulation Library Component
//  /   /                        BUFG_GT
// /___/   /\      Filename    : BUFG_GT.v
// \   \  /  \
//  \___\/\___\
//
///////////////////////////////////////////////////////////////////////////////
//  Revision:
//    10/13/25 - ASIC synthesizable.
//
//  End Revision:
///////////////////////////////////////////////////////////////////////////////

module BUFG_GT
(
    input        CE,
    input        CEMASK,
    input        CLR,
    input        CLRMASK,
    input [2:0]  DIV,
    input        I,
    output       O
);

    wire ce_active, clr_active;
    wire clk_enabled, clk_divided;
    // Deterministic startup phase for this synthesizable primitive surrogate.
    reg [2:0] div_counter = 3'b000;

    // CEMASK bypasses CE; CLRMASK suppresses CLR. The LiteEth adaptation
    // ties these controls explicitly instead of leaving primitive inputs open.
    assign ce_active = CE | CEMASK;
    assign clr_active = CLR & ~CLRMASK;

    // DIV encodes divide-by-(DIV+1), including DIV=7 (divide by eight).
    // The previous toggle-after-N implementation divided by 2*N.
    always @(posedge I or posedge clr_active) begin
        if (clr_active)
            div_counter <= 3'b000;
        else if (ce_active) begin
            if (div_counter == DIV)
                div_counter <= 3'b000;
            else
                div_counter <= div_counter + 1'b1;
        end
    end
    assign clk_divided = (DIV == 0) ? I :
                        ({1'b0, div_counter} < (({1'b0, DIV} + 4'd2) >> 1));

    wire clk_gated;

`ifdef USE_ASAP7_CELLS
    AND2x2_ASAP7_75t_R clk_and_gate (
        .A(clk_divided),
        .B(1'b1),
        .Y(clk_gated)
    );
`elsif USE_NANGATE45_CELLS
    AND2_X1 clk_and_gate (
        .A1(clk_divided),
        .A2(1'b1),
        .ZN(clk_gated)
    );
`elsif USE_SKY130HD_CELLS
    sky130_fd_sc_hd__and2_0 clk_and_gate (
        .A(clk_divided),
        .B(1'b1),
        .X(clk_gated)
    );
`endif

    wire clk_final;
    assign clk_final = (clr_active || !ce_active) ? 1'b0 : clk_gated;

`ifdef USE_ASAP7_CELLS
    BUFx2_ASAP7_75t_R  clk_buf (.A(clk_final), .Y(O));
    // BUFx3_ASAP7_75t_R  clk_buf (.A(clk_final), .Y(O));
    // BUFx4_ASAP7_75t_R  clk_buf (.A(clk_final), .Y(O));
`elsif USE_NANGATE45_CELLS
    CLKBUF_X1  clk_buf0 (.A(clk_final), .Z(O));
    // CLKBUF_X2  clk_buf0 (.A(clk_final), .Z(O));
    // CLKBUF_X3  clk_buf0 (.A(clk_final), .Z(O));
`elsif USE_SKY130HD_CELLS
    sky130_fd_sc_hd__clkbuf_1  clk_buf (.A(clk_final), .X(O));
    // sky130_fd_sc_hd__clkbuf_2  clk_buf (.A(clk_final), .X(O));
    // sky130_fd_sc_hd__clkbuf_4  clk_buf (.A(clk_final), .X(O));
    // sky130_fd_sc_hd__clkbuf_8  clk_buf (.A(clk_final), .X(O));
    // sky130_fd_sc_hd__clkbuf_16 clk_buf (.A(clk_final), .X(O));
`endif

endmodule
