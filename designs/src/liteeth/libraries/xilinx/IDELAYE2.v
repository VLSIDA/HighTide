///////////////////////////////////////////////////////////////////////////////
//    Copyright (c) 1995/2004 Xilinx, Inc.
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
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 12.0
//  \   \         Description : Xilinx Functional and Timing Simulation Library Component
//  /   /                  Input Fixed or Variable Delay Element.
// /___/   /\     Filename : IDELAYE2.v
// \   \  /  \    Timestamp : Sat Sep 19 14:17:57 PDT 2009
//  \___\/\___\
//
// Revision:
//    09/19/09 - Initial version.
//    12/13/11 - Added `celldefine and `endcelldefine (CR 524859).
//    10/22/14 - Added #1 to $finish (CR 808642).
//    10/13/25 - ASIC synthesizable.
// End Revision
///////////////////////////////////////////////////////////////////////////////

module IDELAYE2 (
    input wire C,
    input wire CE, 
    input wire CINVCTRL,
    input wire [4:0] CNTVALUEIN,
    input wire DATAIN,
    input wire IDATAIN,
    input wire INC,
    input wire LD,
    input wire LDPIPEEN,
    input wire REGRST,
    output wire [4:0] CNTVALUEOUT,
    output wire DATAOUT
);

    parameter CINVCTRL_SEL = "FALSE";
    parameter DELAY_SRC = "IDATAIN";
    parameter HIGH_PERFORMANCE_MODE = "FALSE";
    parameter IDELAY_TYPE = "FIXED";
    parameter integer IDELAY_VALUE = 0;
    parameter [0:0] IS_C_INVERTED = 1'b0;
    parameter [0:0] IS_DATAIN_INVERTED = 1'b0;
    parameter [0:0] IS_IDATAIN_INVERTED = 1'b0;
    parameter PIPE_SEL = "FALSE";
    parameter real REFCLK_FREQUENCY = 200.0;
    parameter SIGNAL_PATTERN = "DATA";

    reg [4:0] idelay_count;
    reg [4:0] cntvalueout_pre;
    reg [4:0] qcntvalueout_reg;
    reg [4:0] qcntvalueout_mux;
    integer CNTVALUEIN_INTEGER;
    
    wire c_buf, ce_buf, cinvctrl_buf, inc_buf, ld_buf, ldpipeen_buf, regrst_buf;
    wire datain_buf, idatain_buf;
    wire [4:0] cntvaluein_buf;
    
    `ifdef USE_ASAP7_CELLS
        BUFx2_ASAP7_75t_R input_clk_buf (.A(C), .Y(c_buf));
        BUFx2_ASAP7_75t_R input_ce_buf (.A(CE), .Y(ce_buf)); 
        BUFx2_ASAP7_75t_R input_cinv_buf (.A(CINVCTRL), .Y(cinvctrl_buf));
        BUFx2_ASAP7_75t_R input_inc_buf (.A(INC), .Y(inc_buf));
        BUFx2_ASAP7_75t_R input_ld_buf (.A(LD), .Y(ld_buf));
        BUFx2_ASAP7_75t_R input_ldpipe_buf (.A(LDPIPEEN), .Y(ldpipeen_buf));
        BUFx2_ASAP7_75t_R input_regrst_buf (.A(REGRST), .Y(regrst_buf));
        BUFx2_ASAP7_75t_R input_datain_buf (.A(DATAIN), .Y(datain_buf));
        BUFx2_ASAP7_75t_R input_idatain_buf (.A(IDATAIN), .Y(idatain_buf));
        BUFx2_ASAP7_75t_R input_cnt0_buf (.A(CNTVALUEIN[0]), .Y(cntvaluein_buf[0]));
        BUFx2_ASAP7_75t_R input_cnt1_buf (.A(CNTVALUEIN[1]), .Y(cntvaluein_buf[1]));
        BUFx2_ASAP7_75t_R input_cnt2_buf (.A(CNTVALUEIN[2]), .Y(cntvaluein_buf[2]));
        BUFx2_ASAP7_75t_R input_cnt3_buf (.A(CNTVALUEIN[3]), .Y(cntvaluein_buf[3]));
        BUFx2_ASAP7_75t_R input_cnt4_buf (.A(CNTVALUEIN[4]), .Y(cntvaluein_buf[4]));
    `elsif USE_NANGATE45_CELLS
        BUF_X1 input_clk_buf (.A(C), .Z(c_buf));
        BUF_X1 input_ce_buf (.A(CE), .Z(ce_buf)); 
        BUF_X1 input_cinv_buf (.A(CINVCTRL), .Z(cinvctrl_buf));
        BUF_X1 input_inc_buf (.A(INC), .Z(inc_buf));
        BUF_X1 input_ld_buf (.A(LD), .Z(ld_buf));
        BUF_X1 input_ldpipe_buf (.A(LDPIPEEN), .Z(ldpipeen_buf));
        BUF_X1 input_regrst_buf (.A(REGRST), .Z(regrst_buf));
        BUF_X1 input_datain_buf (.A(DATAIN), .Z(datain_buf));
        BUF_X1 input_idatain_buf (.A(IDATAIN), .Z(idatain_buf));
        BUF_X1 input_cnt0_buf (.A(CNTVALUEIN[0]), .Z(cntvaluein_buf[0]));
        BUF_X1 input_cnt1_buf (.A(CNTVALUEIN[1]), .Z(cntvaluein_buf[1]));
        BUF_X1 input_cnt2_buf (.A(CNTVALUEIN[2]), .Z(cntvaluein_buf[2]));
        BUF_X1 input_cnt3_buf (.A(CNTVALUEIN[3]), .Z(cntvaluein_buf[3]));
        BUF_X1 input_cnt4_buf (.A(CNTVALUEIN[4]), .Z(cntvaluein_buf[4]));
    `elsif USE_SKY130HD_CELLS
        sky130_fd_sc_hd__buf_1 input_clk_buf (.A(C), .X(c_buf));
        sky130_fd_sc_hd__buf_1 input_ce_buf (.A(CE), .X(ce_buf)); 
        sky130_fd_sc_hd__buf_1 input_cinv_buf (.A(CINVCTRL), .X(cinvctrl_buf));
        sky130_fd_sc_hd__buf_1 input_inc_buf (.A(INC), .X(inc_buf));
        sky130_fd_sc_hd__buf_1 input_ld_buf (.A(LD), .X(ld_buf));
        sky130_fd_sc_hd__buf_1 input_ldpipe_buf (.A(LDPIPEEN), .X(ldpipeen_buf));
        sky130_fd_sc_hd__buf_1 input_regrst_buf (.A(REGRST), .X(regrst_buf));
        sky130_fd_sc_hd__buf_1 input_datain_buf (.A(DATAIN), .X(datain_buf));
        sky130_fd_sc_hd__buf_1 input_idatain_buf (.A(IDATAIN), .X(idatain_buf));
        sky130_fd_sc_hd__buf_1 input_cnt0_buf (.A(CNTVALUEIN[0]), .X(cntvaluein_buf[0]));
        sky130_fd_sc_hd__buf_1 input_cnt1_buf (.A(CNTVALUEIN[1]), .X(cntvaluein_buf[1]));
        sky130_fd_sc_hd__buf_1 input_cnt2_buf (.A(CNTVALUEIN[2]), .X(cntvaluein_buf[2]));
        sky130_fd_sc_hd__buf_1 input_cnt3_buf (.A(CNTVALUEIN[3]), .X(cntvaluein_buf[3]));
        sky130_fd_sc_hd__buf_1 input_cnt4_buf (.A(CNTVALUEIN[4]), .X(cntvaluein_buf[4]));
`elsif USE_GT2N_CELLS
        gt2_6t_buf_x2_w31_svt input_clk_buf (.A(C), .Y(c_buf));
        gt2_6t_buf_x2_w31_svt input_ce_buf (.A(CE), .Y(ce_buf)); 
        gt2_6t_buf_x2_w31_svt input_cinv_buf (.A(CINVCTRL), .Y(cinvctrl_buf));
        gt2_6t_buf_x2_w31_svt input_inc_buf (.A(INC), .Y(inc_buf));
        gt2_6t_buf_x2_w31_svt input_ld_buf (.A(LD), .Y(ld_buf));
        gt2_6t_buf_x2_w31_svt input_ldpipe_buf (.A(LDPIPEEN), .Y(ldpipeen_buf));
        gt2_6t_buf_x2_w31_svt input_regrst_buf (.A(REGRST), .Y(regrst_buf));
        gt2_6t_buf_x2_w31_svt input_datain_buf (.A(DATAIN), .Y(datain_buf));
        gt2_6t_buf_x2_w31_svt input_idatain_buf (.A(IDATAIN), .Y(idatain_buf));
        gt2_6t_buf_x2_w31_svt input_cnt0_buf (.A(CNTVALUEIN[0]), .Y(cntvaluein_buf[0]));
        gt2_6t_buf_x2_w31_svt input_cnt1_buf (.A(CNTVALUEIN[1]), .Y(cntvaluein_buf[1]));
        gt2_6t_buf_x2_w31_svt input_cnt2_buf (.A(CNTVALUEIN[2]), .Y(cntvaluein_buf[2]));
        gt2_6t_buf_x2_w31_svt input_cnt3_buf (.A(CNTVALUEIN[3]), .Y(cntvaluein_buf[3]));
        gt2_6t_buf_x2_w31_svt input_cnt4_buf (.A(CNTVALUEIN[4]), .Y(cntvaluein_buf[4]));
    `endif


    // assign c_buf = C;
    // assign ce_buf = CE;
    // assign cinvctrl_buf = CINVCTRL;
    // assign inc_buf = INC;
    // assign ld_buf = LD;
    // assign ldpipeen_buf = LDPIPEEN;
    // assign regrst_buf = REGRST;
    // assign datain_buf = DATAIN;
    // assign idatain_buf = IDATAIN;
    // assign cntvaluein_buf = CNTVALUEIN;

    wire c_in_pre = c_buf ^ IS_C_INVERTED;
    wire ce_in = ce_buf;
    wire [4:0] cntvaluein_in = cntvaluein_buf;
    wire inc_in = inc_buf;
    wire ld_in = ld_buf;
    wire ldpipeen_in = ldpipeen_buf;
    wire regrst_in = regrst_buf;
    wire cinvctrl_in = cinvctrl_buf;
    wire datain_in = IS_DATAIN_INVERTED ^ datain_buf;
    wire idatain_in = IS_IDATAIN_INVERTED ^ idatain_buf;

    reg c_in;
    always @(*) begin
        if (CINVCTRL_SEL == "TRUE")
            c_in = cinvctrl_in ? ~c_in_pre : c_in_pre;
        else
            c_in = c_in_pre;
    end

    wire c_in_gated;
    `ifdef USE_ASAP7_CELLS
        BUFx2_ASAP7_75t_R clk_tree_buf (.A(c_in), .Y(c_in_gated));
    `elsif USE_NANGATE45_CELLS
        CLKBUF_X1 clk_tree_buf (.A(c_in), .Z(c_in_gated));
    `elsif USE_SKY130HD_CELLS
        sky130_fd_sc_hd__clkbuf_1 clk_tree_buf (.A(c_in), .X(c_in_gated));
`elsif USE_GT2N_CELLS
        gt2_6t_buf_x2_w31_svt clk_tree_buf (.A(c_in), .Y(c_in_gated));
    `endif
    reg data_mux;
    always @(*) begin
        case (DELAY_SRC)
            "IDATAIN": data_mux = idatain_in;
            "DATAIN":  data_mux = datain_in;
            default:   data_mux = idatain_in;
        endcase
    end

    wire [31:0] delay_chain;

    `ifdef USE_ASAP7_CELLS
        BUFx2_ASAP7_75t_R del_buf_0 (.A(data_mux), .Y(delay_chain[0]));
    `elsif USE_NANGATE45_CELLS
        BUF_X1 del_buf_0 (.A(data_mux), .Z(delay_chain[0]));
    `elsif USE_SKY130HD_CELLS
        sky130_fd_sc_hd__buf_1 del_buf_0 (.A(data_mux), .X(delay_chain[0]));
`elsif USE_GT2N_CELLS
        gt2_6t_buf_x2_w31_svt del_buf_0 (.A(data_mux), .Y(delay_chain[0]));
    `endif

    genvar i;
    generate
        for (i=0; i<31; i=i+1) begin : delay_chain_inst
        `ifdef USE_ASAP7_CELLS
            BUFx2_ASAP7_75t_R del_buf (.A(delay_chain[i]), .Y(delay_chain[i+1]));
        `elsif USE_NANGATE45_CELLS
            BUF_X1 del_buf (.A(delay_chain[i]), .Z(delay_chain[i+1]));
        `elsif USE_SKY130HD_CELLS
            sky130_fd_sc_hd__buf_1 del_buf (.A(delay_chain[i]), .X(delay_chain[i+1]));
`elsif USE_GT2N_CELLS
            gt2_6t_buf_x2_w31_svt del_buf (.A(delay_chain[i]), .Y(delay_chain[i+1]));
        `endif
        end
    endgenerate

    always @(*) begin
        CNTVALUEIN_INTEGER = cntvaluein_in;
    end

    always @(posedge c_in_gated) begin
        if (regrst_in) begin
            qcntvalueout_reg <= 5'b0;
        end else if (ldpipeen_in) begin
            qcntvalueout_reg <= CNTVALUEIN_INTEGER;
        end
    end

    always @(*) begin
        if (PIPE_SEL == "TRUE")
            qcntvalueout_mux = qcntvalueout_reg;
        else
            qcntvalueout_mux = CNTVALUEIN_INTEGER;
    end

    always @(posedge c_in_gated) begin
        if ((IDELAY_TYPE == "VARIABLE") || (IDELAY_TYPE == "VAR_LOAD") || (IDELAY_TYPE == "VAR_LOAD_PIPE")) begin
            if (ld_in) begin
                case (IDELAY_TYPE)
                    "VARIABLE": idelay_count <= IDELAY_VALUE;
                    "VAR_LOAD", "VAR_LOAD_PIPE": idelay_count <= qcntvalueout_mux;
                    default: idelay_count <= idelay_count;
                endcase
            end else if (ce_in) begin
                if (inc_in) begin
                    if (idelay_count < 5'd31)
                        idelay_count <= idelay_count + 1;
                    else
                        idelay_count <= 5'd0;
                end else begin
                    if (idelay_count > 5'd0)
                        idelay_count <= idelay_count - 1;
                    else
                        idelay_count <= 5'd31;
                end
            end
        end
    end

    reg [4:0] effective_delay_count;
    always @(*) begin
        if (IDELAY_TYPE == "FIXED")
            effective_delay_count = IDELAY_VALUE;
        else
            effective_delay_count = idelay_count;
    end

    reg tap_out_pre;
    always @(*) begin
        case (effective_delay_count)
            5'd0:  tap_out_pre = delay_chain[0];
            5'd1:  tap_out_pre = delay_chain[1];
            5'd2:  tap_out_pre = delay_chain[2];
            5'd3:  tap_out_pre = delay_chain[3];
            5'd4:  tap_out_pre = delay_chain[4];
            5'd5:  tap_out_pre = delay_chain[5];
            5'd6:  tap_out_pre = delay_chain[6];
            5'd7:  tap_out_pre = delay_chain[7];
            5'd8:  tap_out_pre = delay_chain[8];
            5'd9:  tap_out_pre = delay_chain[9];
            5'd10: tap_out_pre = delay_chain[10];
            5'd11: tap_out_pre = delay_chain[11];
            5'd12: tap_out_pre = delay_chain[12];
            5'd13: tap_out_pre = delay_chain[13];
            5'd14: tap_out_pre = delay_chain[14];
            5'd15: tap_out_pre = delay_chain[15];
            5'd16: tap_out_pre = delay_chain[16];
            5'd17: tap_out_pre = delay_chain[17];
            5'd18: tap_out_pre = delay_chain[18];
            5'd19: tap_out_pre = delay_chain[19];
            5'd20: tap_out_pre = delay_chain[20];
            5'd21: tap_out_pre = delay_chain[21];
            5'd22: tap_out_pre = delay_chain[22];
            5'd23: tap_out_pre = delay_chain[23];
            5'd24: tap_out_pre = delay_chain[24];
            5'd25: tap_out_pre = delay_chain[25];
            5'd26: tap_out_pre = delay_chain[26];
            5'd27: tap_out_pre = delay_chain[27];
            5'd28: tap_out_pre = delay_chain[28];
            5'd29: tap_out_pre = delay_chain[29];
            5'd30: tap_out_pre = delay_chain[30];
            5'd31: tap_out_pre = delay_chain[31];
            default: tap_out_pre = delay_chain[0];
        endcase
    end

    wire dataout_internal;
    `ifdef USE_ASAP7_CELLS
        BUFx2_ASAP7_75t_R output_data_buf (.A(tap_out_pre), .Y(dataout_internal));
    `elsif USE_NANGATE45_CELLS
        BUF_X1 output_data_buf (.A(tap_out_pre), .Z(dataout_internal));
    `elsif USE_SKY130HD_CELLS
        sky130_fd_sc_hd__buf_2 output_data_buf (.A(tap_out_pre), .X(dataout_internal));
`elsif USE_GT2N_CELLS
        gt2_6t_buf_x2_w31_svt output_data_buf (.A(tap_out_pre), .Y(dataout_internal));
    `endif

    assign DATAOUT = dataout_internal;

    always @(*) begin
        if (IDELAY_TYPE == "FIXED")
            cntvalueout_pre = IDELAY_VALUE;
        else
            cntvalueout_pre = idelay_count;
    end
    
    wire [4:0] cntvalueout_buf;
    `ifdef USE_ASAP7_CELLS
        BUFx2_ASAP7_75t_R cnt_out_0 (.A(cntvalueout_pre[0]), .Y(cntvalueout_buf[0]));
        BUFx2_ASAP7_75t_R cnt_out_1 (.A(cntvalueout_pre[1]), .Y(cntvalueout_buf[1]));
        BUFx2_ASAP7_75t_R cnt_out_2 (.A(cntvalueout_pre[2]), .Y(cntvalueout_buf[2]));
        BUFx2_ASAP7_75t_R cnt_out_3 (.A(cntvalueout_pre[3]), .Y(cntvalueout_buf[3]));
        BUFx2_ASAP7_75t_R cnt_out_4 (.A(cntvalueout_pre[4]), .Y(cntvalueout_buf[4]));
    `elsif USE_NANGATE45_CELLS
        BUF_X1 cnt_out_0 (.A(cntvalueout_pre[0]), .Z(cntvalueout_buf[0]));
        BUF_X1 cnt_out_1 (.A(cntvalueout_pre[1]), .Z(cntvalueout_buf[1]));
        BUF_X1 cnt_out_2 (.A(cntvalueout_pre[2]), .Z(cntvalueout_buf[2]));
        BUF_X1 cnt_out_3 (.A(cntvalueout_pre[3]), .Z(cntvalueout_buf[3]));
        BUF_X1 cnt_out_4 (.A(cntvalueout_pre[4]), .Z(cntvalueout_buf[4]));
    `elsif USE_SKY130HD_CELLS
        sky130_fd_sc_hd__buf_1 cnt_out_0 (.A(cntvalueout_pre[0]), .X(cntvalueout_buf[0]));
        sky130_fd_sc_hd__buf_1 cnt_out_1 (.A(cntvalueout_pre[1]), .X(cntvalueout_buf[1]));
        sky130_fd_sc_hd__buf_1 cnt_out_2 (.A(cntvalueout_pre[2]), .X(cntvalueout_buf[2]));
        sky130_fd_sc_hd__buf_1 cnt_out_3 (.A(cntvalueout_pre[3]), .X(cntvalueout_buf[3]));
        sky130_fd_sc_hd__buf_1 cnt_out_4 (.A(cntvalueout_pre[4]), .X(cntvalueout_buf[4]));
`elsif USE_GT2N_CELLS
        gt2_6t_buf_x2_w31_svt cnt_out_0 (.A(cntvalueout_pre[0]), .Y(cntvalueout_buf[0]));
        gt2_6t_buf_x2_w31_svt cnt_out_1 (.A(cntvalueout_pre[1]), .Y(cntvalueout_buf[1]));
        gt2_6t_buf_x2_w31_svt cnt_out_2 (.A(cntvalueout_pre[2]), .Y(cntvalueout_buf[2]));
        gt2_6t_buf_x2_w31_svt cnt_out_3 (.A(cntvalueout_pre[3]), .Y(cntvalueout_buf[3]));
        gt2_6t_buf_x2_w31_svt cnt_out_4 (.A(cntvalueout_pre[4]), .Y(cntvalueout_buf[4]));
    `endif
    assign CNTVALUEOUT = cntvalueout_buf;

    initial begin
        idelay_count = IDELAY_VALUE;
        qcntvalueout_reg = 5'b0;
    end

endmodule
