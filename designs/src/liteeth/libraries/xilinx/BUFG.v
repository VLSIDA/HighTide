///////////////////////////////////////////////////////////////////////////////
//     Copyright (c) 1995/2018 Xilinx, Inc.
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
// \   \   \/      Version     : 2018.3
//  \   \          Description : Xilinx Unified Simulation Library Component
//  /   /                        General Clock Buffer
// /___/   /\      Filename    : BUFG.v
// \   \  /  \
//  \___\/\___\
//
///////////////////////////////////////////////////////////////////////////////
//  Revision:
//    03/23/04 - Initial version.
//    05/23/07 - Changed timescale to 1 ps / 1 ps.
//    12/13/11 - 524859 - Added `celldefine and `endcelldefine
//    10/13/25 - ASIC synthesizable.
//  End Revision:
///////////////////////////////////////////////////////////////////////////////

module BUFG
(
    input  I,
    output O
);

    `ifdef USE_ASAP7_CELLS
        BUFx2_ASAP7_75t_R  clk_buf (.A(I), .Y(O));
        // BUFx3_ASAP7_75t_R  clk_buf (.A(I), .Y(O));
        // BUFx4_ASAP7_75t_R  clk_buf (.A(I), .Y(O));
    `elsif USE_NANGATE45_CELLS
        CLKBUF_X1  clk_buf (.A(I), .Z(O));
        // CLKBUF_X2  clk_buf (.A(I), .Z(O));
        // CLKBUF_X3  clk_buf (.A(I), .Z(O));
    `elsif USE_SKY130HD_CELLS
        sky130_fd_sc_hd__clkbuf_1  clk_buf (.A(I), .X(O));
        // sky130_fd_sc_hd__clkbuf_2  clk_buf (.A(I), .X(O));
        // sky130_fd_sc_hd__clkbuf_4  clk_buf (.A(I), .X(O));
        // sky130_fd_sc_hd__clkbuf_8  clk_buf (.A(I), .X(O));
        // sky130_fd_sc_hd__clkbuf_16 clk_buf (.A(I), .X(O));
`elsif USE_GT2N_CELLS
        gt2_6t_buf_x2_w31_svt  clk_buf (.A(I), .Y(O));
    `endif

endmodule
