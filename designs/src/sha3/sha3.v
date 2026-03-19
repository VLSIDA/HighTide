module ThetaModule(
  input  [63:0] io_state_i_0,
  input  [63:0] io_state_i_1,
  input  [63:0] io_state_i_2,
  input  [63:0] io_state_i_3,
  input  [63:0] io_state_i_4,
  input  [63:0] io_state_i_5,
  input  [63:0] io_state_i_6,
  input  [63:0] io_state_i_7,
  input  [63:0] io_state_i_8,
  input  [63:0] io_state_i_9,
  input  [63:0] io_state_i_10,
  input  [63:0] io_state_i_11,
  input  [63:0] io_state_i_12,
  input  [63:0] io_state_i_13,
  input  [63:0] io_state_i_14,
  input  [63:0] io_state_i_15,
  input  [63:0] io_state_i_16,
  input  [63:0] io_state_i_17,
  input  [63:0] io_state_i_18,
  input  [63:0] io_state_i_19,
  input  [63:0] io_state_i_20,
  input  [63:0] io_state_i_21,
  input  [63:0] io_state_i_22,
  input  [63:0] io_state_i_23,
  input  [63:0] io_state_i_24,
  output [63:0] io_state_o_0,
  output [63:0] io_state_o_1,
  output [63:0] io_state_o_2,
  output [63:0] io_state_o_3,
  output [63:0] io_state_o_4,
  output [63:0] io_state_o_5,
  output [63:0] io_state_o_6,
  output [63:0] io_state_o_7,
  output [63:0] io_state_o_8,
  output [63:0] io_state_o_9,
  output [63:0] io_state_o_10,
  output [63:0] io_state_o_11,
  output [63:0] io_state_o_12,
  output [63:0] io_state_o_13,
  output [63:0] io_state_o_14,
  output [63:0] io_state_o_15,
  output [63:0] io_state_o_16,
  output [63:0] io_state_o_17,
  output [63:0] io_state_o_18,
  output [63:0] io_state_o_19,
  output [63:0] io_state_o_20,
  output [63:0] io_state_o_21,
  output [63:0] io_state_o_22,
  output [63:0] io_state_o_23,
  output [63:0] io_state_o_24
);
  wire [63:0] _bc_0_T = io_state_i_0 ^ io_state_i_1; // @[src/main/scala/sha3/theta.scala 21:32]
  wire [63:0] _bc_0_T_1 = _bc_0_T ^ io_state_i_2; // @[src/main/scala/sha3/theta.scala 21:52]
  wire [63:0] _bc_0_T_2 = _bc_0_T_1 ^ io_state_i_3; // @[src/main/scala/sha3/theta.scala 21:72]
  wire [63:0] bc_0 = _bc_0_T_2 ^ io_state_i_4; // @[src/main/scala/sha3/theta.scala 21:92]
  wire [63:0] _bc_1_T = io_state_i_5 ^ io_state_i_6; // @[src/main/scala/sha3/theta.scala 21:32]
  wire [63:0] _bc_1_T_1 = _bc_1_T ^ io_state_i_7; // @[src/main/scala/sha3/theta.scala 21:52]
  wire [63:0] _bc_1_T_2 = _bc_1_T_1 ^ io_state_i_8; // @[src/main/scala/sha3/theta.scala 21:72]
  wire [63:0] bc_1 = _bc_1_T_2 ^ io_state_i_9; // @[src/main/scala/sha3/theta.scala 21:92]
  wire [63:0] _bc_2_T = io_state_i_10 ^ io_state_i_11; // @[src/main/scala/sha3/theta.scala 21:32]
  wire [63:0] _bc_2_T_1 = _bc_2_T ^ io_state_i_12; // @[src/main/scala/sha3/theta.scala 21:52]
  wire [63:0] _bc_2_T_2 = _bc_2_T_1 ^ io_state_i_13; // @[src/main/scala/sha3/theta.scala 21:72]
  wire [63:0] bc_2 = _bc_2_T_2 ^ io_state_i_14; // @[src/main/scala/sha3/theta.scala 21:92]
  wire [63:0] _bc_3_T = io_state_i_15 ^ io_state_i_16; // @[src/main/scala/sha3/theta.scala 21:32]
  wire [63:0] _bc_3_T_1 = _bc_3_T ^ io_state_i_17; // @[src/main/scala/sha3/theta.scala 21:52]
  wire [63:0] _bc_3_T_2 = _bc_3_T_1 ^ io_state_i_18; // @[src/main/scala/sha3/theta.scala 21:72]
  wire [63:0] bc_3 = _bc_3_T_2 ^ io_state_i_19; // @[src/main/scala/sha3/theta.scala 21:92]
  wire [63:0] _bc_4_T = io_state_i_20 ^ io_state_i_21; // @[src/main/scala/sha3/theta.scala 21:32]
  wire [63:0] _bc_4_T_1 = _bc_4_T ^ io_state_i_22; // @[src/main/scala/sha3/theta.scala 21:52]
  wire [63:0] _bc_4_T_2 = _bc_4_T_1 ^ io_state_i_23; // @[src/main/scala/sha3/theta.scala 21:72]
  wire [63:0] bc_4 = _bc_4_T_2 ^ io_state_i_24; // @[src/main/scala/sha3/theta.scala 21:92]
  wire [64:0] _t_T = {bc_1, 1'h0}; // @[src/main/scala/sha3/common.scala 24:47]
  wire [6:0] _t_T_2 = 7'h40 - 7'h1; // @[src/main/scala/sha3/common.scala 24:68]
  wire [63:0] _t_T_3 = bc_1 >> _t_T_2; // @[src/main/scala/sha3/common.scala 24:62]
  wire [64:0] _GEN_0 = {{1'd0}, _t_T_3}; // @[src/main/scala/sha3/common.scala 24:55]
  wire [64:0] _t_T_4 = _t_T | _GEN_0; // @[src/main/scala/sha3/common.scala 24:55]
  wire [64:0] _GEN_1 = {{1'd0}, bc_4}; // @[src/main/scala/sha3/theta.scala 26:22]
  wire [64:0] _t_T_5 = _GEN_1 ^ _t_T_4; // @[src/main/scala/sha3/theta.scala 26:22]
  wire [63:0] t = _t_T_5[63:0]; // @[src/main/scala/sha3/theta.scala 25:17 26:7]
  wire [64:0] _t_T_6 = {bc_2, 1'h0}; // @[src/main/scala/sha3/common.scala 24:47]
  wire [63:0] _t_T_9 = bc_2 >> _t_T_2; // @[src/main/scala/sha3/common.scala 24:62]
  wire [64:0] _GEN_2 = {{1'd0}, _t_T_9}; // @[src/main/scala/sha3/common.scala 24:55]
  wire [64:0] _t_T_10 = _t_T_6 | _GEN_2; // @[src/main/scala/sha3/common.scala 24:55]
  wire [64:0] _GEN_3 = {{1'd0}, bc_0}; // @[src/main/scala/sha3/theta.scala 26:22]
  wire [64:0] _t_T_11 = _GEN_3 ^ _t_T_10; // @[src/main/scala/sha3/theta.scala 26:22]
  wire [63:0] t_1 = _t_T_11[63:0]; // @[src/main/scala/sha3/theta.scala 25:17 26:7]
  wire [64:0] _t_T_12 = {bc_3, 1'h0}; // @[src/main/scala/sha3/common.scala 24:47]
  wire [63:0] _t_T_15 = bc_3 >> _t_T_2; // @[src/main/scala/sha3/common.scala 24:62]
  wire [64:0] _GEN_4 = {{1'd0}, _t_T_15}; // @[src/main/scala/sha3/common.scala 24:55]
  wire [64:0] _t_T_16 = _t_T_12 | _GEN_4; // @[src/main/scala/sha3/common.scala 24:55]
  wire [64:0] _GEN_5 = {{1'd0}, bc_1}; // @[src/main/scala/sha3/theta.scala 26:22]
  wire [64:0] _t_T_17 = _GEN_5 ^ _t_T_16; // @[src/main/scala/sha3/theta.scala 26:22]
  wire [63:0] t_2 = _t_T_17[63:0]; // @[src/main/scala/sha3/theta.scala 25:17 26:7]
  wire [64:0] _t_T_18 = {bc_4, 1'h0}; // @[src/main/scala/sha3/common.scala 24:47]
  wire [63:0] _t_T_21 = bc_4 >> _t_T_2; // @[src/main/scala/sha3/common.scala 24:62]
  wire [64:0] _GEN_6 = {{1'd0}, _t_T_21}; // @[src/main/scala/sha3/common.scala 24:55]
  wire [64:0] _t_T_22 = _t_T_18 | _GEN_6; // @[src/main/scala/sha3/common.scala 24:55]
  wire [64:0] _GEN_7 = {{1'd0}, bc_2}; // @[src/main/scala/sha3/theta.scala 26:22]
  wire [64:0] _t_T_23 = _GEN_7 ^ _t_T_22; // @[src/main/scala/sha3/theta.scala 26:22]
  wire [63:0] t_3 = _t_T_23[63:0]; // @[src/main/scala/sha3/theta.scala 25:17 26:7]
  wire [64:0] _t_T_24 = {bc_0, 1'h0}; // @[src/main/scala/sha3/common.scala 24:47]
  wire [63:0] _t_T_27 = bc_0 >> _t_T_2; // @[src/main/scala/sha3/common.scala 24:62]
  wire [64:0] _GEN_8 = {{1'd0}, _t_T_27}; // @[src/main/scala/sha3/common.scala 24:55]
  wire [64:0] _t_T_28 = _t_T_24 | _GEN_8; // @[src/main/scala/sha3/common.scala 24:55]
  wire [64:0] _GEN_9 = {{1'd0}, bc_3}; // @[src/main/scala/sha3/theta.scala 26:22]
  wire [64:0] _t_T_29 = _GEN_9 ^ _t_T_28; // @[src/main/scala/sha3/theta.scala 26:22]
  wire [63:0] t_4 = _t_T_29[63:0]; // @[src/main/scala/sha3/theta.scala 25:17 26:7]
  assign io_state_o_0 = io_state_i_0 ^ t; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_1 = io_state_i_1 ^ t; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_2 = io_state_i_2 ^ t; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_3 = io_state_i_3 ^ t; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_4 = io_state_i_4 ^ t; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_5 = io_state_i_5 ^ t_1; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_6 = io_state_i_6 ^ t_1; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_7 = io_state_i_7 ^ t_1; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_8 = io_state_i_8 ^ t_1; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_9 = io_state_i_9 ^ t_1; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_10 = io_state_i_10 ^ t_2; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_11 = io_state_i_11 ^ t_2; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_12 = io_state_i_12 ^ t_2; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_13 = io_state_i_13 ^ t_2; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_14 = io_state_i_14 ^ t_2; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_15 = io_state_i_15 ^ t_3; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_16 = io_state_i_16 ^ t_3; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_17 = io_state_i_17 ^ t_3; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_18 = io_state_i_18 ^ t_3; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_19 = io_state_i_19 ^ t_3; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_20 = io_state_i_20 ^ t_4; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_21 = io_state_i_21 ^ t_4; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_22 = io_state_i_22 ^ t_4; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_23 = io_state_i_23 ^ t_4; // @[src/main/scala/sha3/theta.scala 28:46]
  assign io_state_o_24 = io_state_i_24 ^ t_4; // @[src/main/scala/sha3/theta.scala 28:46]
endmodule
module RhoPiModule(
  input  [63:0] io_state_i_0,
  input  [63:0] io_state_i_1,
  input  [63:0] io_state_i_2,
  input  [63:0] io_state_i_3,
  input  [63:0] io_state_i_4,
  input  [63:0] io_state_i_5,
  input  [63:0] io_state_i_6,
  input  [63:0] io_state_i_7,
  input  [63:0] io_state_i_8,
  input  [63:0] io_state_i_9,
  input  [63:0] io_state_i_10,
  input  [63:0] io_state_i_11,
  input  [63:0] io_state_i_12,
  input  [63:0] io_state_i_13,
  input  [63:0] io_state_i_14,
  input  [63:0] io_state_i_15,
  input  [63:0] io_state_i_16,
  input  [63:0] io_state_i_17,
  input  [63:0] io_state_i_18,
  input  [63:0] io_state_i_19,
  input  [63:0] io_state_i_20,
  input  [63:0] io_state_i_21,
  input  [63:0] io_state_i_22,
  input  [63:0] io_state_i_23,
  input  [63:0] io_state_i_24,
  output [63:0] io_state_o_0,
  output [63:0] io_state_o_1,
  output [63:0] io_state_o_2,
  output [63:0] io_state_o_3,
  output [63:0] io_state_o_4,
  output [63:0] io_state_o_5,
  output [63:0] io_state_o_6,
  output [63:0] io_state_o_7,
  output [63:0] io_state_o_8,
  output [63:0] io_state_o_9,
  output [63:0] io_state_o_10,
  output [63:0] io_state_o_11,
  output [63:0] io_state_o_12,
  output [63:0] io_state_o_13,
  output [63:0] io_state_o_14,
  output [63:0] io_state_o_15,
  output [63:0] io_state_o_16,
  output [63:0] io_state_o_17,
  output [63:0] io_state_o_18,
  output [63:0] io_state_o_19,
  output [63:0] io_state_o_20,
  output [63:0] io_state_o_21,
  output [63:0] io_state_o_22,
  output [63:0] io_state_o_23,
  output [63:0] io_state_o_24
);
  wire [64:0] temp_1 = {io_state_i_1[28:0],io_state_i_1[63:28]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_2 = {io_state_i_2[61:0],io_state_i_2[63:61]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_3 = {io_state_i_3[23:0],io_state_i_3[63:23]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_4 = {io_state_i_4[46:0],io_state_i_4[63:46]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_5 = {io_state_i_5,io_state_i_5[63]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_6 = {io_state_i_6[20:0],io_state_i_6[63:20]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_7 = {io_state_i_7[54:0],io_state_i_7[63:54]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_8 = {io_state_i_8[19:0],io_state_i_8[63:19]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_9 = {io_state_i_9[62:0],io_state_i_9[63:62]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_10 = {io_state_i_10[2:0],io_state_i_10[63:2]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_11 = {io_state_i_11[58:0],io_state_i_11[63:58]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_12 = {io_state_i_12[21:0],io_state_i_12[63:21]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_13 = {io_state_i_13[49:0],io_state_i_13[63:49]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_14 = {io_state_i_14[3:0],io_state_i_14[63:3]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_15 = {io_state_i_15[36:0],io_state_i_15[63:36]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_16 = {io_state_i_16[9:0],io_state_i_16[63:9]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_17 = {io_state_i_17[39:0],io_state_i_17[63:39]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_18 = {io_state_i_18[43:0],io_state_i_18[63:43]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_19 = {io_state_i_19[8:0],io_state_i_19[63:8]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_20 = {io_state_i_20[37:0],io_state_i_20[63:37]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_21 = {io_state_i_21[44:0],io_state_i_21[63:44]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_22 = {io_state_i_22[25:0],io_state_i_22[63:25]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_23 = {io_state_i_23[56:0],io_state_i_23[63:56]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  wire [64:0] temp_24 = {io_state_i_24[50:0],io_state_i_24[63:50]}; // @[src/main/scala/sha3/rhopi.scala 43:20]
  assign io_state_o_0 = io_state_i_0; // @[src/main/scala/sha3/rhopi.scala 39:22 41:14]
  assign io_state_o_1 = temp_15[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_2 = temp_5[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_3 = temp_20[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_4 = temp_10[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_5 = temp_6[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_6 = temp_21[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_7 = temp_11[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_8 = temp_1[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_9 = temp_16[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_10 = temp_12[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_11 = temp_2[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_12 = temp_17[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_13 = temp_7[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_14 = temp_22[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_15 = temp_18[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_16 = temp_8[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_17 = temp_23[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_18 = temp_13[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_19 = temp_3[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_20 = temp_24[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_21 = temp_14[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_22 = temp_4[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_23 = temp_19[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
  assign io_state_o_24 = temp_9[63:0]; // @[src/main/scala/sha3/rhopi.scala 45:37]
endmodule
module ChiModule(
  input  [63:0] io_state_i_0,
  input  [63:0] io_state_i_1,
  input  [63:0] io_state_i_2,
  input  [63:0] io_state_i_3,
  input  [63:0] io_state_i_4,
  input  [63:0] io_state_i_5,
  input  [63:0] io_state_i_6,
  input  [63:0] io_state_i_7,
  input  [63:0] io_state_i_8,
  input  [63:0] io_state_i_9,
  input  [63:0] io_state_i_10,
  input  [63:0] io_state_i_11,
  input  [63:0] io_state_i_12,
  input  [63:0] io_state_i_13,
  input  [63:0] io_state_i_14,
  input  [63:0] io_state_i_15,
  input  [63:0] io_state_i_16,
  input  [63:0] io_state_i_17,
  input  [63:0] io_state_i_18,
  input  [63:0] io_state_i_19,
  input  [63:0] io_state_i_20,
  input  [63:0] io_state_i_21,
  input  [63:0] io_state_i_22,
  input  [63:0] io_state_i_23,
  input  [63:0] io_state_i_24,
  output [63:0] io_state_o_0,
  output [63:0] io_state_o_1,
  output [63:0] io_state_o_2,
  output [63:0] io_state_o_3,
  output [63:0] io_state_o_4,
  output [63:0] io_state_o_5,
  output [63:0] io_state_o_6,
  output [63:0] io_state_o_7,
  output [63:0] io_state_o_8,
  output [63:0] io_state_o_9,
  output [63:0] io_state_o_10,
  output [63:0] io_state_o_11,
  output [63:0] io_state_o_12,
  output [63:0] io_state_o_13,
  output [63:0] io_state_o_14,
  output [63:0] io_state_o_15,
  output [63:0] io_state_o_16,
  output [63:0] io_state_o_17,
  output [63:0] io_state_o_18,
  output [63:0] io_state_o_19,
  output [63:0] io_state_o_20,
  output [63:0] io_state_o_21,
  output [63:0] io_state_o_22,
  output [63:0] io_state_o_23,
  output [63:0] io_state_o_24
);
  wire [63:0] _T = ~io_state_i_5; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _T_1 = _T & io_state_i_10; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_1_T = ~io_state_i_6; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_1_T_1 = _io_state_o_1_T & io_state_i_11; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_2_T = ~io_state_i_7; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_2_T_1 = _io_state_o_2_T & io_state_i_12; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_3_T = ~io_state_i_8; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_3_T_1 = _io_state_o_3_T & io_state_i_13; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_4_T = ~io_state_i_9; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_4_T_1 = _io_state_o_4_T & io_state_i_14; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_5_T = ~io_state_i_10; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_5_T_1 = _io_state_o_5_T & io_state_i_15; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_6_T = ~io_state_i_11; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_6_T_1 = _io_state_o_6_T & io_state_i_16; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_7_T = ~io_state_i_12; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_7_T_1 = _io_state_o_7_T & io_state_i_17; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_8_T = ~io_state_i_13; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_8_T_1 = _io_state_o_8_T & io_state_i_18; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_9_T = ~io_state_i_14; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_9_T_1 = _io_state_o_9_T & io_state_i_19; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_10_T = ~io_state_i_15; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_10_T_1 = _io_state_o_10_T & io_state_i_20; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_11_T = ~io_state_i_16; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_11_T_1 = _io_state_o_11_T & io_state_i_21; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_12_T = ~io_state_i_17; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_12_T_1 = _io_state_o_12_T & io_state_i_22; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_13_T = ~io_state_i_18; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_13_T_1 = _io_state_o_13_T & io_state_i_23; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_14_T = ~io_state_i_19; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_14_T_1 = _io_state_o_14_T & io_state_i_24; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_15_T = ~io_state_i_20; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_15_T_1 = _io_state_o_15_T & io_state_i_0; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_16_T = ~io_state_i_21; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_16_T_1 = _io_state_o_16_T & io_state_i_1; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_17_T = ~io_state_i_22; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_17_T_1 = _io_state_o_17_T & io_state_i_2; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_18_T = ~io_state_i_23; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_18_T_1 = _io_state_o_18_T & io_state_i_3; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_19_T = ~io_state_i_24; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_19_T_1 = _io_state_o_19_T & io_state_i_4; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_20_T = ~io_state_i_0; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_20_T_1 = _io_state_o_20_T & io_state_i_5; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_21_T = ~io_state_i_1; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_21_T_1 = _io_state_o_21_T & io_state_i_6; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_22_T = ~io_state_i_2; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_22_T_1 = _io_state_o_22_T & io_state_i_7; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_23_T = ~io_state_i_3; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_23_T_1 = _io_state_o_23_T & io_state_i_8; // @[src/main/scala/sha3/chi.scala 22:44]
  wire [63:0] _io_state_o_24_T = ~io_state_i_4; // @[src/main/scala/sha3/chi.scala 22:10]
  wire [63:0] _io_state_o_24_T_1 = _io_state_o_24_T & io_state_i_9; // @[src/main/scala/sha3/chi.scala 22:44]
  assign io_state_o_0 = io_state_i_0 ^ _T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_1 = io_state_i_1 ^ _io_state_o_1_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_2 = io_state_i_2 ^ _io_state_o_2_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_3 = io_state_i_3 ^ _io_state_o_3_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_4 = io_state_i_4 ^ _io_state_o_4_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_5 = io_state_i_5 ^ _io_state_o_5_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_6 = io_state_i_6 ^ _io_state_o_6_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_7 = io_state_i_7 ^ _io_state_o_7_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_8 = io_state_i_8 ^ _io_state_o_8_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_9 = io_state_i_9 ^ _io_state_o_9_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_10 = io_state_i_10 ^ _io_state_o_10_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_11 = io_state_i_11 ^ _io_state_o_11_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_12 = io_state_i_12 ^ _io_state_o_12_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_13 = io_state_i_13 ^ _io_state_o_13_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_14 = io_state_i_14 ^ _io_state_o_14_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_15 = io_state_i_15 ^ _io_state_o_15_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_16 = io_state_i_16 ^ _io_state_o_16_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_17 = io_state_i_17 ^ _io_state_o_17_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_18 = io_state_i_18 ^ _io_state_o_18_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_19 = io_state_i_19 ^ _io_state_o_19_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_20 = io_state_i_20 ^ _io_state_o_20_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_21 = io_state_i_21 ^ _io_state_o_21_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_22 = io_state_i_22 ^ _io_state_o_22_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_23 = io_state_i_23 ^ _io_state_o_23_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
  assign io_state_o_24 = io_state_i_24 ^ _io_state_o_24_T_1; // @[src/main/scala/sha3/chi.scala 21:46]
endmodule
module IotaModule(
  input  [63:0] io_state_i_0,
  input  [63:0] io_state_i_1,
  input  [63:0] io_state_i_2,
  input  [63:0] io_state_i_3,
  input  [63:0] io_state_i_4,
  input  [63:0] io_state_i_5,
  input  [63:0] io_state_i_6,
  input  [63:0] io_state_i_7,
  input  [63:0] io_state_i_8,
  input  [63:0] io_state_i_9,
  input  [63:0] io_state_i_10,
  input  [63:0] io_state_i_11,
  input  [63:0] io_state_i_12,
  input  [63:0] io_state_i_13,
  input  [63:0] io_state_i_14,
  input  [63:0] io_state_i_15,
  input  [63:0] io_state_i_16,
  input  [63:0] io_state_i_17,
  input  [63:0] io_state_i_18,
  input  [63:0] io_state_i_19,
  input  [63:0] io_state_i_20,
  input  [63:0] io_state_i_21,
  input  [63:0] io_state_i_22,
  input  [63:0] io_state_i_23,
  input  [63:0] io_state_i_24,
  output [63:0] io_state_o_0,
  output [63:0] io_state_o_1,
  output [63:0] io_state_o_2,
  output [63:0] io_state_o_3,
  output [63:0] io_state_o_4,
  output [63:0] io_state_o_5,
  output [63:0] io_state_o_6,
  output [63:0] io_state_o_7,
  output [63:0] io_state_o_8,
  output [63:0] io_state_o_9,
  output [63:0] io_state_o_10,
  output [63:0] io_state_o_11,
  output [63:0] io_state_o_12,
  output [63:0] io_state_o_13,
  output [63:0] io_state_o_14,
  output [63:0] io_state_o_15,
  output [63:0] io_state_o_16,
  output [63:0] io_state_o_17,
  output [63:0] io_state_o_18,
  output [63:0] io_state_o_19,
  output [63:0] io_state_o_20,
  output [63:0] io_state_o_21,
  output [63:0] io_state_o_22,
  output [63:0] io_state_o_23,
  output [63:0] io_state_o_24,
  input  [4:0]  io_round
);
  wire [63:0] _GEN_1 = 5'h1 == io_round ? 64'h8082 : 64'h1; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_2 = 5'h2 == io_round ? 64'h800000000000808a : _GEN_1; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_3 = 5'h3 == io_round ? 64'h8000000080008000 : _GEN_2; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_4 = 5'h4 == io_round ? 64'h808b : _GEN_3; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_5 = 5'h5 == io_round ? 64'h80000001 : _GEN_4; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_6 = 5'h6 == io_round ? 64'h8000000080008081 : _GEN_5; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_7 = 5'h7 == io_round ? 64'h8000000000008009 : _GEN_6; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_8 = 5'h8 == io_round ? 64'h8a : _GEN_7; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_9 = 5'h9 == io_round ? 64'h88 : _GEN_8; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_10 = 5'ha == io_round ? 64'h80008009 : _GEN_9; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_11 = 5'hb == io_round ? 64'h8000000a : _GEN_10; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_12 = 5'hc == io_round ? 64'h8000808b : _GEN_11; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_13 = 5'hd == io_round ? 64'h800000000000008b : _GEN_12; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_14 = 5'he == io_round ? 64'h8000000000008089 : _GEN_13; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_15 = 5'hf == io_round ? 64'h8000000000008003 : _GEN_14; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_16 = 5'h10 == io_round ? 64'h8000000000008002 : _GEN_15; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_17 = 5'h11 == io_round ? 64'h8000000000000080 : _GEN_16; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_18 = 5'h12 == io_round ? 64'h800a : _GEN_17; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_19 = 5'h13 == io_round ? 64'h800000008000000a : _GEN_18; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_20 = 5'h14 == io_round ? 64'h8000000080008081 : _GEN_19; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_21 = 5'h15 == io_round ? 64'h8000000000008080 : _GEN_20; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_22 = 5'h16 == io_round ? 64'h80000001 : _GEN_21; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_23 = 5'h17 == io_round ? 64'h8000000080008008 : _GEN_22; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  wire [63:0] _GEN_24 = 5'h18 == io_round ? 64'h0 : _GEN_23; // @[src/main/scala/sha3/iota.scala 27:{34,34}]
  assign io_state_o_0 = io_state_i_0 ^ _GEN_24; // @[src/main/scala/sha3/iota.scala 27:34]
  assign io_state_o_1 = io_state_i_1; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_2 = io_state_i_2; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_3 = io_state_i_3; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_4 = io_state_i_4; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_5 = io_state_i_5; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_6 = io_state_i_6; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_7 = io_state_i_7; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_8 = io_state_i_8; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_9 = io_state_i_9; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_10 = io_state_i_10; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_11 = io_state_i_11; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_12 = io_state_i_12; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_13 = io_state_i_13; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_14 = io_state_i_14; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_15 = io_state_i_15; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_16 = io_state_i_16; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_17 = io_state_i_17; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_18 = io_state_i_18; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_19 = io_state_i_19; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_20 = io_state_i_20; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_21 = io_state_i_21; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_22 = io_state_i_22; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_23 = io_state_i_23; // @[src/main/scala/sha3/iota.scala 22:27]
  assign io_state_o_24 = io_state_i_24; // @[src/main/scala/sha3/iota.scala 22:27]
endmodule
module DpathModule(
  input         clock,
  input         reset,
  input         io_absorb,
  input         io_init,
  input         io_write,
  input  [4:0]  io_round,
  input  [4:0]  io_aindex,
  input  [63:0] io_message_in,
  output [63:0] io_hash_out_0,
  output [63:0] io_hash_out_1,
  output [63:0] io_hash_out_2,
  output [63:0] io_hash_out_3
);
`ifdef RANDOMIZE_REG_INIT
  reg [63:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [63:0] _RAND_2;
  reg [63:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [63:0] _RAND_6;
  reg [63:0] _RAND_7;
  reg [63:0] _RAND_8;
  reg [63:0] _RAND_9;
  reg [63:0] _RAND_10;
  reg [63:0] _RAND_11;
  reg [63:0] _RAND_12;
  reg [63:0] _RAND_13;
  reg [63:0] _RAND_14;
  reg [63:0] _RAND_15;
  reg [63:0] _RAND_16;
  reg [63:0] _RAND_17;
  reg [63:0] _RAND_18;
  reg [63:0] _RAND_19;
  reg [63:0] _RAND_20;
  reg [63:0] _RAND_21;
  reg [63:0] _RAND_22;
  reg [63:0] _RAND_23;
  reg [63:0] _RAND_24;
`endif // RANDOMIZE_REG_INIT
  wire [63:0] ThetaModule_io_state_i_0; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_1; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_2; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_3; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_4; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_5; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_6; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_7; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_8; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_9; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_10; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_11; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_12; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_13; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_14; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_15; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_16; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_17; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_18; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_19; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_20; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_21; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_22; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_23; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_i_24; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_0; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_1; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_2; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_3; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_4; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_5; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_6; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_7; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_8; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_9; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_10; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_11; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_12; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_13; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_14; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_15; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_16; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_17; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_18; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_19; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_20; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_21; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_22; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_23; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] ThetaModule_io_state_o_24; // @[src/main/scala/sha3/DpathModule.scala 31:21]
  wire [63:0] RhoPiModule_io_state_i_0; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_1; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_2; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_3; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_4; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_5; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_6; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_7; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_8; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_9; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_10; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_11; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_12; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_13; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_14; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_15; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_16; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_17; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_18; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_19; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_20; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_21; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_22; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_23; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_i_24; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_0; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_1; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_2; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_3; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_4; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_5; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_6; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_7; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_8; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_9; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_10; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_11; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_12; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_13; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_14; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_15; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_16; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_17; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_18; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_19; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_20; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_21; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_22; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_23; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] RhoPiModule_io_state_o_24; // @[src/main/scala/sha3/DpathModule.scala 32:21]
  wire [63:0] ChiModule_io_state_i_0; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_1; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_2; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_3; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_4; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_5; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_6; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_7; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_8; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_9; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_10; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_11; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_12; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_13; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_14; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_15; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_16; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_17; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_18; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_19; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_20; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_21; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_22; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_23; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_i_24; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_0; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_1; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_2; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_3; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_4; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_5; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_6; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_7; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_8; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_9; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_10; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_11; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_12; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_13; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_14; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_15; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_16; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_17; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_18; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_19; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_20; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_21; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_22; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_23; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] ChiModule_io_state_o_24; // @[src/main/scala/sha3/DpathModule.scala 33:21]
  wire [63:0] iota_io_state_i_0; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_1; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_2; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_3; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_4; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_5; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_6; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_7; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_8; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_9; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_10; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_11; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_12; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_13; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_14; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_15; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_16; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_17; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_18; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_19; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_20; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_21; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_22; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_23; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_i_24; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_0; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_1; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_2; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_3; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_4; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_5; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_6; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_7; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_8; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_9; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_10; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_11; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_12; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_13; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_14; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_15; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_16; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_17; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_18; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_19; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_20; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_21; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_22; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_23; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [63:0] iota_io_state_o_24; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  wire [4:0] iota_io_round; // @[src/main/scala/sha3/DpathModule.scala 34:21]
  reg [63:0] state_0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_1; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_2; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_3; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_4; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_5; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_6; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_7; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_8; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_9; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_10; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_11; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_12; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_13; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_14; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_15; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_16; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_17; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_18; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_19; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_20; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_21; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_22; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_23; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  reg [63:0] state_24; // @[src/main/scala/sha3/DpathModule.scala 28:18]
  wire [63:0] _GEN_0 = iota_io_state_o_0; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_1 = iota_io_state_o_1; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_2 = iota_io_state_o_2; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_3 = iota_io_state_o_3; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_4 = iota_io_state_o_4; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_5 = iota_io_state_o_5; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_6 = iota_io_state_o_6; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_7 = iota_io_state_o_7; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_8 = iota_io_state_o_8; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_9 = iota_io_state_o_9; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_10 = iota_io_state_o_10; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_11 = iota_io_state_o_11; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_12 = iota_io_state_o_12; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_13 = iota_io_state_o_13; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_14 = iota_io_state_o_14; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_15 = iota_io_state_o_15; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_16 = iota_io_state_o_16; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_17 = iota_io_state_o_17; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_18 = iota_io_state_o_18; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_19 = iota_io_state_o_19; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_20 = iota_io_state_o_20; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_21 = iota_io_state_o_21; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_22 = iota_io_state_o_22; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_23 = iota_io_state_o_23; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [63:0] _GEN_24 = iota_io_state_o_24; // @[src/main/scala/sha3/DpathModule.scala 71:19 74:17 46:21]
  wire [4:0] _GEN_25 = io_aindex % 5'h5; // @[src/main/scala/sha3/DpathModule.scala 103:23]
  wire [5:0] _T_6 = _GEN_25[2:0] * 3'h5; // @[src/main/scala/sha3/DpathModule.scala 103:32]
  wire [4:0] _T_7 = io_aindex / 3'h5; // @[src/main/scala/sha3/DpathModule.scala 103:51]
  wire [5:0] _GEN_202 = {{1'd0}, _T_7}; // @[src/main/scala/sha3/DpathModule.scala 103:40]
  wire [5:0] _T_9 = _T_6 + _GEN_202; // @[src/main/scala/sha3/DpathModule.scala 103:40]
  wire [63:0] _GEN_26 = 5'h1 == _T_9[4:0] ? state_1 : state_0; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_27 = 5'h2 == _T_9[4:0] ? state_2 : _GEN_26; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_28 = 5'h3 == _T_9[4:0] ? state_3 : _GEN_27; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_29 = 5'h4 == _T_9[4:0] ? state_4 : _GEN_28; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_30 = 5'h5 == _T_9[4:0] ? state_5 : _GEN_29; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_31 = 5'h6 == _T_9[4:0] ? state_6 : _GEN_30; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_32 = 5'h7 == _T_9[4:0] ? state_7 : _GEN_31; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_33 = 5'h8 == _T_9[4:0] ? state_8 : _GEN_32; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_34 = 5'h9 == _T_9[4:0] ? state_9 : _GEN_33; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_35 = 5'ha == _T_9[4:0] ? state_10 : _GEN_34; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_36 = 5'hb == _T_9[4:0] ? state_11 : _GEN_35; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_37 = 5'hc == _T_9[4:0] ? state_12 : _GEN_36; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_38 = 5'hd == _T_9[4:0] ? state_13 : _GEN_37; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_39 = 5'he == _T_9[4:0] ? state_14 : _GEN_38; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_40 = 5'hf == _T_9[4:0] ? state_15 : _GEN_39; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_41 = 5'h10 == _T_9[4:0] ? state_16 : _GEN_40; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_42 = 5'h11 == _T_9[4:0] ? state_17 : _GEN_41; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_43 = 5'h12 == _T_9[4:0] ? state_18 : _GEN_42; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_44 = 5'h13 == _T_9[4:0] ? state_19 : _GEN_43; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_45 = 5'h14 == _T_9[4:0] ? state_20 : _GEN_44; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_46 = 5'h15 == _T_9[4:0] ? state_21 : _GEN_45; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_47 = 5'h16 == _T_9[4:0] ? state_22 : _GEN_46; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_48 = 5'h17 == _T_9[4:0] ? state_23 : _GEN_47; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _GEN_49 = 5'h18 == _T_9[4:0] ? state_24 : _GEN_48; // @[src/main/scala/sha3/DpathModule.scala 104:{64,64}]
  wire [63:0] _state_T_6 = _GEN_49 ^ io_message_in; // @[src/main/scala/sha3/DpathModule.scala 104:64]
  wire [63:0] _GEN_50 = 5'h0 == _T_9[4:0] ? _state_T_6 : state_0; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_51 = 5'h1 == _T_9[4:0] ? _state_T_6 : state_1; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_52 = 5'h2 == _T_9[4:0] ? _state_T_6 : state_2; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_53 = 5'h3 == _T_9[4:0] ? _state_T_6 : state_3; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_54 = 5'h4 == _T_9[4:0] ? _state_T_6 : state_4; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_55 = 5'h5 == _T_9[4:0] ? _state_T_6 : state_5; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_56 = 5'h6 == _T_9[4:0] ? _state_T_6 : state_6; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_57 = 5'h7 == _T_9[4:0] ? _state_T_6 : state_7; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_58 = 5'h8 == _T_9[4:0] ? _state_T_6 : state_8; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_59 = 5'h9 == _T_9[4:0] ? _state_T_6 : state_9; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_60 = 5'ha == _T_9[4:0] ? _state_T_6 : state_10; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_61 = 5'hb == _T_9[4:0] ? _state_T_6 : state_11; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_62 = 5'hc == _T_9[4:0] ? _state_T_6 : state_12; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_63 = 5'hd == _T_9[4:0] ? _state_T_6 : state_13; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_64 = 5'he == _T_9[4:0] ? _state_T_6 : state_14; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_65 = 5'hf == _T_9[4:0] ? _state_T_6 : state_15; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_66 = 5'h10 == _T_9[4:0] ? _state_T_6 : state_16; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_67 = 5'h11 == _T_9[4:0] ? _state_T_6 : state_17; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_68 = 5'h12 == _T_9[4:0] ? _state_T_6 : state_18; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_69 = 5'h13 == _T_9[4:0] ? _state_T_6 : state_19; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_70 = 5'h14 == _T_9[4:0] ? _state_T_6 : state_20; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_71 = 5'h15 == _T_9[4:0] ? _state_T_6 : state_21; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_72 = 5'h16 == _T_9[4:0] ? _state_T_6 : state_22; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_73 = 5'h17 == _T_9[4:0] ? _state_T_6 : state_23; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_74 = 5'h18 == _T_9[4:0] ? _state_T_6 : state_24; // @[src/main/scala/sha3/DpathModule.scala 101:11 103:{62,62}]
  wire [63:0] _GEN_75 = io_aindex < 5'h11 ? _GEN_50 : state_0; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_76 = io_aindex < 5'h11 ? _GEN_51 : state_1; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_77 = io_aindex < 5'h11 ? _GEN_52 : state_2; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_78 = io_aindex < 5'h11 ? _GEN_53 : state_3; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_79 = io_aindex < 5'h11 ? _GEN_54 : state_4; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_80 = io_aindex < 5'h11 ? _GEN_55 : state_5; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_81 = io_aindex < 5'h11 ? _GEN_56 : state_6; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_82 = io_aindex < 5'h11 ? _GEN_57 : state_7; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_83 = io_aindex < 5'h11 ? _GEN_58 : state_8; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_84 = io_aindex < 5'h11 ? _GEN_59 : state_9; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_85 = io_aindex < 5'h11 ? _GEN_60 : state_10; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_86 = io_aindex < 5'h11 ? _GEN_61 : state_11; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_87 = io_aindex < 5'h11 ? _GEN_62 : state_12; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_88 = io_aindex < 5'h11 ? _GEN_63 : state_13; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_89 = io_aindex < 5'h11 ? _GEN_64 : state_14; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_90 = io_aindex < 5'h11 ? _GEN_65 : state_15; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_91 = io_aindex < 5'h11 ? _GEN_66 : state_16; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_92 = io_aindex < 5'h11 ? _GEN_67 : state_17; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_93 = io_aindex < 5'h11 ? _GEN_68 : state_18; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_94 = io_aindex < 5'h11 ? _GEN_69 : state_19; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_95 = io_aindex < 5'h11 ? _GEN_70 : state_20; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_96 = io_aindex < 5'h11 ? _GEN_71 : state_21; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_97 = io_aindex < 5'h11 ? _GEN_72 : state_22; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_98 = io_aindex < 5'h11 ? _GEN_73 : state_23; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_99 = io_aindex < 5'h11 ? _GEN_74 : state_24; // @[src/main/scala/sha3/DpathModule.scala 101:11 102:45]
  wire [63:0] _GEN_100 = io_absorb ? _GEN_75 : _GEN_0; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_101 = io_absorb ? _GEN_76 : _GEN_1; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_102 = io_absorb ? _GEN_77 : _GEN_2; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_103 = io_absorb ? _GEN_78 : _GEN_3; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_104 = io_absorb ? _GEN_79 : _GEN_4; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_105 = io_absorb ? _GEN_80 : _GEN_5; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_106 = io_absorb ? _GEN_81 : _GEN_6; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_107 = io_absorb ? _GEN_82 : _GEN_7; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_108 = io_absorb ? _GEN_83 : _GEN_8; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_109 = io_absorb ? _GEN_84 : _GEN_9; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_110 = io_absorb ? _GEN_85 : _GEN_10; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_111 = io_absorb ? _GEN_86 : _GEN_11; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_112 = io_absorb ? _GEN_87 : _GEN_12; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_113 = io_absorb ? _GEN_88 : _GEN_13; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_114 = io_absorb ? _GEN_89 : _GEN_14; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_115 = io_absorb ? _GEN_90 : _GEN_15; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_116 = io_absorb ? _GEN_91 : _GEN_16; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_117 = io_absorb ? _GEN_92 : _GEN_17; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_118 = io_absorb ? _GEN_93 : _GEN_18; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_119 = io_absorb ? _GEN_94 : _GEN_19; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_120 = io_absorb ? _GEN_95 : _GEN_20; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_121 = io_absorb ? _GEN_96 : _GEN_21; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_122 = io_absorb ? _GEN_97 : _GEN_22; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_123 = io_absorb ? _GEN_98 : _GEN_23; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  wire [63:0] _GEN_124 = io_absorb ? _GEN_99 : _GEN_24; // @[src/main/scala/sha3/DpathModule.scala 100:18]
  ThetaModule ThetaModule ( // @[src/main/scala/sha3/DpathModule.scala 31:21]
    .io_state_i_0(ThetaModule_io_state_i_0),
    .io_state_i_1(ThetaModule_io_state_i_1),
    .io_state_i_2(ThetaModule_io_state_i_2),
    .io_state_i_3(ThetaModule_io_state_i_3),
    .io_state_i_4(ThetaModule_io_state_i_4),
    .io_state_i_5(ThetaModule_io_state_i_5),
    .io_state_i_6(ThetaModule_io_state_i_6),
    .io_state_i_7(ThetaModule_io_state_i_7),
    .io_state_i_8(ThetaModule_io_state_i_8),
    .io_state_i_9(ThetaModule_io_state_i_9),
    .io_state_i_10(ThetaModule_io_state_i_10),
    .io_state_i_11(ThetaModule_io_state_i_11),
    .io_state_i_12(ThetaModule_io_state_i_12),
    .io_state_i_13(ThetaModule_io_state_i_13),
    .io_state_i_14(ThetaModule_io_state_i_14),
    .io_state_i_15(ThetaModule_io_state_i_15),
    .io_state_i_16(ThetaModule_io_state_i_16),
    .io_state_i_17(ThetaModule_io_state_i_17),
    .io_state_i_18(ThetaModule_io_state_i_18),
    .io_state_i_19(ThetaModule_io_state_i_19),
    .io_state_i_20(ThetaModule_io_state_i_20),
    .io_state_i_21(ThetaModule_io_state_i_21),
    .io_state_i_22(ThetaModule_io_state_i_22),
    .io_state_i_23(ThetaModule_io_state_i_23),
    .io_state_i_24(ThetaModule_io_state_i_24),
    .io_state_o_0(ThetaModule_io_state_o_0),
    .io_state_o_1(ThetaModule_io_state_o_1),
    .io_state_o_2(ThetaModule_io_state_o_2),
    .io_state_o_3(ThetaModule_io_state_o_3),
    .io_state_o_4(ThetaModule_io_state_o_4),
    .io_state_o_5(ThetaModule_io_state_o_5),
    .io_state_o_6(ThetaModule_io_state_o_6),
    .io_state_o_7(ThetaModule_io_state_o_7),
    .io_state_o_8(ThetaModule_io_state_o_8),
    .io_state_o_9(ThetaModule_io_state_o_9),
    .io_state_o_10(ThetaModule_io_state_o_10),
    .io_state_o_11(ThetaModule_io_state_o_11),
    .io_state_o_12(ThetaModule_io_state_o_12),
    .io_state_o_13(ThetaModule_io_state_o_13),
    .io_state_o_14(ThetaModule_io_state_o_14),
    .io_state_o_15(ThetaModule_io_state_o_15),
    .io_state_o_16(ThetaModule_io_state_o_16),
    .io_state_o_17(ThetaModule_io_state_o_17),
    .io_state_o_18(ThetaModule_io_state_o_18),
    .io_state_o_19(ThetaModule_io_state_o_19),
    .io_state_o_20(ThetaModule_io_state_o_20),
    .io_state_o_21(ThetaModule_io_state_o_21),
    .io_state_o_22(ThetaModule_io_state_o_22),
    .io_state_o_23(ThetaModule_io_state_o_23),
    .io_state_o_24(ThetaModule_io_state_o_24)
  );
  RhoPiModule RhoPiModule ( // @[src/main/scala/sha3/DpathModule.scala 32:21]
    .io_state_i_0(RhoPiModule_io_state_i_0),
    .io_state_i_1(RhoPiModule_io_state_i_1),
    .io_state_i_2(RhoPiModule_io_state_i_2),
    .io_state_i_3(RhoPiModule_io_state_i_3),
    .io_state_i_4(RhoPiModule_io_state_i_4),
    .io_state_i_5(RhoPiModule_io_state_i_5),
    .io_state_i_6(RhoPiModule_io_state_i_6),
    .io_state_i_7(RhoPiModule_io_state_i_7),
    .io_state_i_8(RhoPiModule_io_state_i_8),
    .io_state_i_9(RhoPiModule_io_state_i_9),
    .io_state_i_10(RhoPiModule_io_state_i_10),
    .io_state_i_11(RhoPiModule_io_state_i_11),
    .io_state_i_12(RhoPiModule_io_state_i_12),
    .io_state_i_13(RhoPiModule_io_state_i_13),
    .io_state_i_14(RhoPiModule_io_state_i_14),
    .io_state_i_15(RhoPiModule_io_state_i_15),
    .io_state_i_16(RhoPiModule_io_state_i_16),
    .io_state_i_17(RhoPiModule_io_state_i_17),
    .io_state_i_18(RhoPiModule_io_state_i_18),
    .io_state_i_19(RhoPiModule_io_state_i_19),
    .io_state_i_20(RhoPiModule_io_state_i_20),
    .io_state_i_21(RhoPiModule_io_state_i_21),
    .io_state_i_22(RhoPiModule_io_state_i_22),
    .io_state_i_23(RhoPiModule_io_state_i_23),
    .io_state_i_24(RhoPiModule_io_state_i_24),
    .io_state_o_0(RhoPiModule_io_state_o_0),
    .io_state_o_1(RhoPiModule_io_state_o_1),
    .io_state_o_2(RhoPiModule_io_state_o_2),
    .io_state_o_3(RhoPiModule_io_state_o_3),
    .io_state_o_4(RhoPiModule_io_state_o_4),
    .io_state_o_5(RhoPiModule_io_state_o_5),
    .io_state_o_6(RhoPiModule_io_state_o_6),
    .io_state_o_7(RhoPiModule_io_state_o_7),
    .io_state_o_8(RhoPiModule_io_state_o_8),
    .io_state_o_9(RhoPiModule_io_state_o_9),
    .io_state_o_10(RhoPiModule_io_state_o_10),
    .io_state_o_11(RhoPiModule_io_state_o_11),
    .io_state_o_12(RhoPiModule_io_state_o_12),
    .io_state_o_13(RhoPiModule_io_state_o_13),
    .io_state_o_14(RhoPiModule_io_state_o_14),
    .io_state_o_15(RhoPiModule_io_state_o_15),
    .io_state_o_16(RhoPiModule_io_state_o_16),
    .io_state_o_17(RhoPiModule_io_state_o_17),
    .io_state_o_18(RhoPiModule_io_state_o_18),
    .io_state_o_19(RhoPiModule_io_state_o_19),
    .io_state_o_20(RhoPiModule_io_state_o_20),
    .io_state_o_21(RhoPiModule_io_state_o_21),
    .io_state_o_22(RhoPiModule_io_state_o_22),
    .io_state_o_23(RhoPiModule_io_state_o_23),
    .io_state_o_24(RhoPiModule_io_state_o_24)
  );
  ChiModule ChiModule ( // @[src/main/scala/sha3/DpathModule.scala 33:21]
    .io_state_i_0(ChiModule_io_state_i_0),
    .io_state_i_1(ChiModule_io_state_i_1),
    .io_state_i_2(ChiModule_io_state_i_2),
    .io_state_i_3(ChiModule_io_state_i_3),
    .io_state_i_4(ChiModule_io_state_i_4),
    .io_state_i_5(ChiModule_io_state_i_5),
    .io_state_i_6(ChiModule_io_state_i_6),
    .io_state_i_7(ChiModule_io_state_i_7),
    .io_state_i_8(ChiModule_io_state_i_8),
    .io_state_i_9(ChiModule_io_state_i_9),
    .io_state_i_10(ChiModule_io_state_i_10),
    .io_state_i_11(ChiModule_io_state_i_11),
    .io_state_i_12(ChiModule_io_state_i_12),
    .io_state_i_13(ChiModule_io_state_i_13),
    .io_state_i_14(ChiModule_io_state_i_14),
    .io_state_i_15(ChiModule_io_state_i_15),
    .io_state_i_16(ChiModule_io_state_i_16),
    .io_state_i_17(ChiModule_io_state_i_17),
    .io_state_i_18(ChiModule_io_state_i_18),
    .io_state_i_19(ChiModule_io_state_i_19),
    .io_state_i_20(ChiModule_io_state_i_20),
    .io_state_i_21(ChiModule_io_state_i_21),
    .io_state_i_22(ChiModule_io_state_i_22),
    .io_state_i_23(ChiModule_io_state_i_23),
    .io_state_i_24(ChiModule_io_state_i_24),
    .io_state_o_0(ChiModule_io_state_o_0),
    .io_state_o_1(ChiModule_io_state_o_1),
    .io_state_o_2(ChiModule_io_state_o_2),
    .io_state_o_3(ChiModule_io_state_o_3),
    .io_state_o_4(ChiModule_io_state_o_4),
    .io_state_o_5(ChiModule_io_state_o_5),
    .io_state_o_6(ChiModule_io_state_o_6),
    .io_state_o_7(ChiModule_io_state_o_7),
    .io_state_o_8(ChiModule_io_state_o_8),
    .io_state_o_9(ChiModule_io_state_o_9),
    .io_state_o_10(ChiModule_io_state_o_10),
    .io_state_o_11(ChiModule_io_state_o_11),
    .io_state_o_12(ChiModule_io_state_o_12),
    .io_state_o_13(ChiModule_io_state_o_13),
    .io_state_o_14(ChiModule_io_state_o_14),
    .io_state_o_15(ChiModule_io_state_o_15),
    .io_state_o_16(ChiModule_io_state_o_16),
    .io_state_o_17(ChiModule_io_state_o_17),
    .io_state_o_18(ChiModule_io_state_o_18),
    .io_state_o_19(ChiModule_io_state_o_19),
    .io_state_o_20(ChiModule_io_state_o_20),
    .io_state_o_21(ChiModule_io_state_o_21),
    .io_state_o_22(ChiModule_io_state_o_22),
    .io_state_o_23(ChiModule_io_state_o_23),
    .io_state_o_24(ChiModule_io_state_o_24)
  );
  IotaModule iota ( // @[src/main/scala/sha3/DpathModule.scala 34:21]
    .io_state_i_0(iota_io_state_i_0),
    .io_state_i_1(iota_io_state_i_1),
    .io_state_i_2(iota_io_state_i_2),
    .io_state_i_3(iota_io_state_i_3),
    .io_state_i_4(iota_io_state_i_4),
    .io_state_i_5(iota_io_state_i_5),
    .io_state_i_6(iota_io_state_i_6),
    .io_state_i_7(iota_io_state_i_7),
    .io_state_i_8(iota_io_state_i_8),
    .io_state_i_9(iota_io_state_i_9),
    .io_state_i_10(iota_io_state_i_10),
    .io_state_i_11(iota_io_state_i_11),
    .io_state_i_12(iota_io_state_i_12),
    .io_state_i_13(iota_io_state_i_13),
    .io_state_i_14(iota_io_state_i_14),
    .io_state_i_15(iota_io_state_i_15),
    .io_state_i_16(iota_io_state_i_16),
    .io_state_i_17(iota_io_state_i_17),
    .io_state_i_18(iota_io_state_i_18),
    .io_state_i_19(iota_io_state_i_19),
    .io_state_i_20(iota_io_state_i_20),
    .io_state_i_21(iota_io_state_i_21),
    .io_state_i_22(iota_io_state_i_22),
    .io_state_i_23(iota_io_state_i_23),
    .io_state_i_24(iota_io_state_i_24),
    .io_state_o_0(iota_io_state_o_0),
    .io_state_o_1(iota_io_state_o_1),
    .io_state_o_2(iota_io_state_o_2),
    .io_state_o_3(iota_io_state_o_3),
    .io_state_o_4(iota_io_state_o_4),
    .io_state_o_5(iota_io_state_o_5),
    .io_state_o_6(iota_io_state_o_6),
    .io_state_o_7(iota_io_state_o_7),
    .io_state_o_8(iota_io_state_o_8),
    .io_state_o_9(iota_io_state_o_9),
    .io_state_o_10(iota_io_state_o_10),
    .io_state_o_11(iota_io_state_o_11),
    .io_state_o_12(iota_io_state_o_12),
    .io_state_o_13(iota_io_state_o_13),
    .io_state_o_14(iota_io_state_o_14),
    .io_state_o_15(iota_io_state_o_15),
    .io_state_o_16(iota_io_state_o_16),
    .io_state_o_17(iota_io_state_o_17),
    .io_state_o_18(iota_io_state_o_18),
    .io_state_o_19(iota_io_state_o_19),
    .io_state_o_20(iota_io_state_o_20),
    .io_state_o_21(iota_io_state_o_21),
    .io_state_o_22(iota_io_state_o_22),
    .io_state_o_23(iota_io_state_o_23),
    .io_state_o_24(iota_io_state_o_24),
    .io_round(iota_io_round)
  );
  assign io_hash_out_0 = state_0; // @[src/main/scala/sha3/DpathModule.scala 110:20]
  assign io_hash_out_1 = state_5; // @[src/main/scala/sha3/DpathModule.scala 110:20]
  assign io_hash_out_2 = state_10; // @[src/main/scala/sha3/DpathModule.scala 110:20]
  assign io_hash_out_3 = state_15; // @[src/main/scala/sha3/DpathModule.scala 110:20]
  assign ThetaModule_io_state_i_0 = state_0; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_1 = state_1; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_2 = state_2; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_3 = state_3; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_4 = state_4; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_5 = state_5; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_6 = state_6; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_7 = state_7; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_8 = state_8; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_9 = state_9; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_10 = state_10; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_11 = state_11; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_12 = state_12; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_13 = state_13; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_14 = state_14; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_15 = state_15; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_16 = state_16; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_17 = state_17; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_18 = state_18; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_19 = state_19; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_20 = state_20; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_21 = state_21; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_22 = state_22; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_23 = state_23; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign ThetaModule_io_state_i_24 = state_24; // @[src/main/scala/sha3/DpathModule.scala 42:21]
  assign RhoPiModule_io_state_i_0 = ThetaModule_io_state_o_0; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_1 = ThetaModule_io_state_o_1; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_2 = ThetaModule_io_state_o_2; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_3 = ThetaModule_io_state_o_3; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_4 = ThetaModule_io_state_o_4; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_5 = ThetaModule_io_state_o_5; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_6 = ThetaModule_io_state_o_6; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_7 = ThetaModule_io_state_o_7; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_8 = ThetaModule_io_state_o_8; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_9 = ThetaModule_io_state_o_9; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_10 = ThetaModule_io_state_o_10; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_11 = ThetaModule_io_state_o_11; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_12 = ThetaModule_io_state_o_12; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_13 = ThetaModule_io_state_o_13; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_14 = ThetaModule_io_state_o_14; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_15 = ThetaModule_io_state_o_15; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_16 = ThetaModule_io_state_o_16; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_17 = ThetaModule_io_state_o_17; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_18 = ThetaModule_io_state_o_18; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_19 = ThetaModule_io_state_o_19; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_20 = ThetaModule_io_state_o_20; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_21 = ThetaModule_io_state_o_21; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_22 = ThetaModule_io_state_o_22; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_23 = ThetaModule_io_state_o_23; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign RhoPiModule_io_state_i_24 = ThetaModule_io_state_o_24; // @[src/main/scala/sha3/DpathModule.scala 43:21]
  assign ChiModule_io_state_i_0 = RhoPiModule_io_state_o_0; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_1 = RhoPiModule_io_state_o_1; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_2 = RhoPiModule_io_state_o_2; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_3 = RhoPiModule_io_state_o_3; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_4 = RhoPiModule_io_state_o_4; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_5 = RhoPiModule_io_state_o_5; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_6 = RhoPiModule_io_state_o_6; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_7 = RhoPiModule_io_state_o_7; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_8 = RhoPiModule_io_state_o_8; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_9 = RhoPiModule_io_state_o_9; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_10 = RhoPiModule_io_state_o_10; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_11 = RhoPiModule_io_state_o_11; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_12 = RhoPiModule_io_state_o_12; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_13 = RhoPiModule_io_state_o_13; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_14 = RhoPiModule_io_state_o_14; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_15 = RhoPiModule_io_state_o_15; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_16 = RhoPiModule_io_state_o_16; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_17 = RhoPiModule_io_state_o_17; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_18 = RhoPiModule_io_state_o_18; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_19 = RhoPiModule_io_state_o_19; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_20 = RhoPiModule_io_state_o_20; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_21 = RhoPiModule_io_state_o_21; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_22 = RhoPiModule_io_state_o_22; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_23 = RhoPiModule_io_state_o_23; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign ChiModule_io_state_i_24 = RhoPiModule_io_state_o_24; // @[src/main/scala/sha3/DpathModule.scala 44:21]
  assign iota_io_state_i_0 = ChiModule_io_state_o_0; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_1 = ChiModule_io_state_o_1; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_2 = ChiModule_io_state_o_2; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_3 = ChiModule_io_state_o_3; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_4 = ChiModule_io_state_o_4; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_5 = ChiModule_io_state_o_5; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_6 = ChiModule_io_state_o_6; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_7 = ChiModule_io_state_o_7; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_8 = ChiModule_io_state_o_8; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_9 = ChiModule_io_state_o_9; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_10 = ChiModule_io_state_o_10; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_11 = ChiModule_io_state_o_11; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_12 = ChiModule_io_state_o_12; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_13 = ChiModule_io_state_o_13; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_14 = ChiModule_io_state_o_14; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_15 = ChiModule_io_state_o_15; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_16 = ChiModule_io_state_o_16; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_17 = ChiModule_io_state_o_17; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_18 = ChiModule_io_state_o_18; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_19 = ChiModule_io_state_o_19; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_20 = ChiModule_io_state_o_20; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_21 = ChiModule_io_state_o_21; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_22 = ChiModule_io_state_o_22; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_23 = ChiModule_io_state_o_23; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_state_i_24 = ChiModule_io_state_o_24; // @[src/main/scala/sha3/DpathModule.scala 45:24]
  assign iota_io_round = io_round; // @[src/main/scala/sha3/DpathModule.scala 68:20]
  always @(posedge clock) begin
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_0 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_0 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_0 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_0 <= _GEN_100;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_1 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_1 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_1 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_1 <= _GEN_101;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_2 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_2 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_2 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_2 <= _GEN_102;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_3 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_3 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_3 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_3 <= _GEN_103;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_4 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_4 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_4 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_4 <= _GEN_104;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_5 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_5 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_5 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_5 <= _GEN_105;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_6 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_6 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_6 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_6 <= _GEN_106;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_7 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_7 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_7 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_7 <= _GEN_107;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_8 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_8 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_8 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_8 <= _GEN_108;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_9 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_9 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_9 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_9 <= _GEN_109;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_10 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_10 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_10 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_10 <= _GEN_110;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_11 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_11 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_11 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_11 <= _GEN_111;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_12 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_12 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_12 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_12 <= _GEN_112;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_13 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_13 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_13 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_13 <= _GEN_113;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_14 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_14 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_14 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_14 <= _GEN_114;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_15 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_15 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_15 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_15 <= _GEN_115;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_16 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_16 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_16 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_16 <= _GEN_116;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_17 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_17 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_17 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_17 <= _GEN_117;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_18 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_18 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_18 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_18 <= _GEN_118;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_19 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_19 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_19 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_19 <= _GEN_119;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_20 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_20 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_20 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_20 <= _GEN_120;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_21 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_21 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_21 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_21 <= _GEN_121;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_22 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_22 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_22 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_22 <= _GEN_122;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_23 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_23 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_23 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_23 <= _GEN_123;
    end
    if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 28:18]
      state_24 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 28:18]
    end else if (reset) begin // @[src/main/scala/sha3/DpathModule.scala 123:14]
      state_24 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 124:11]
    end else if (io_init) begin // @[src/main/scala/sha3/DpathModule.scala 119:16]
      state_24 <= 64'h0; // @[src/main/scala/sha3/DpathModule.scala 120:11]
    end else if (!(io_write)) begin // @[src/main/scala/sha3/DpathModule.scala 114:17]
      state_24 <= _GEN_124;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {2{`RANDOM}};
  state_0 = _RAND_0[63:0];
  _RAND_1 = {2{`RANDOM}};
  state_1 = _RAND_1[63:0];
  _RAND_2 = {2{`RANDOM}};
  state_2 = _RAND_2[63:0];
  _RAND_3 = {2{`RANDOM}};
  state_3 = _RAND_3[63:0];
  _RAND_4 = {2{`RANDOM}};
  state_4 = _RAND_4[63:0];
  _RAND_5 = {2{`RANDOM}};
  state_5 = _RAND_5[63:0];
  _RAND_6 = {2{`RANDOM}};
  state_6 = _RAND_6[63:0];
  _RAND_7 = {2{`RANDOM}};
  state_7 = _RAND_7[63:0];
  _RAND_8 = {2{`RANDOM}};
  state_8 = _RAND_8[63:0];
  _RAND_9 = {2{`RANDOM}};
  state_9 = _RAND_9[63:0];
  _RAND_10 = {2{`RANDOM}};
  state_10 = _RAND_10[63:0];
  _RAND_11 = {2{`RANDOM}};
  state_11 = _RAND_11[63:0];
  _RAND_12 = {2{`RANDOM}};
  state_12 = _RAND_12[63:0];
  _RAND_13 = {2{`RANDOM}};
  state_13 = _RAND_13[63:0];
  _RAND_14 = {2{`RANDOM}};
  state_14 = _RAND_14[63:0];
  _RAND_15 = {2{`RANDOM}};
  state_15 = _RAND_15[63:0];
  _RAND_16 = {2{`RANDOM}};
  state_16 = _RAND_16[63:0];
  _RAND_17 = {2{`RANDOM}};
  state_17 = _RAND_17[63:0];
  _RAND_18 = {2{`RANDOM}};
  state_18 = _RAND_18[63:0];
  _RAND_19 = {2{`RANDOM}};
  state_19 = _RAND_19[63:0];
  _RAND_20 = {2{`RANDOM}};
  state_20 = _RAND_20[63:0];
  _RAND_21 = {2{`RANDOM}};
  state_21 = _RAND_21[63:0];
  _RAND_22 = {2{`RANDOM}};
  state_22 = _RAND_22[63:0];
  _RAND_23 = {2{`RANDOM}};
  state_23 = _RAND_23[63:0];
  _RAND_24 = {2{`RANDOM}};
  state_24 = _RAND_24[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module sha3(
  input         clock,
  input         reset,
  input         io_absorb, // @[src/main/scala/sha3/Sha3Top.scala 23:14]
  input         io_init, // @[src/main/scala/sha3/Sha3Top.scala 23:14]
  input         io_write, // @[src/main/scala/sha3/Sha3Top.scala 23:14]
  input  [4:0]  io_round, // @[src/main/scala/sha3/Sha3Top.scala 23:14]
  input         io_stage, // @[src/main/scala/sha3/Sha3Top.scala 23:14]
  input  [4:0]  io_aindex, // @[src/main/scala/sha3/Sha3Top.scala 23:14]
  input  [63:0] io_message_in, // @[src/main/scala/sha3/Sha3Top.scala 23:14]
  output [63:0] io_hash_out_0, // @[src/main/scala/sha3/Sha3Top.scala 23:14]
  output [63:0] io_hash_out_1, // @[src/main/scala/sha3/Sha3Top.scala 23:14]
  output [63:0] io_hash_out_2, // @[src/main/scala/sha3/Sha3Top.scala 23:14]
  output [63:0] io_hash_out_3 // @[src/main/scala/sha3/Sha3Top.scala 23:14]
);
  wire  dpath_clock; // @[src/main/scala/sha3/Sha3Top.scala 17:21]
  wire  dpath_reset; // @[src/main/scala/sha3/Sha3Top.scala 17:21]
  wire  dpath_io_absorb; // @[src/main/scala/sha3/Sha3Top.scala 17:21]
  wire  dpath_io_init; // @[src/main/scala/sha3/Sha3Top.scala 17:21]
  wire  dpath_io_write; // @[src/main/scala/sha3/Sha3Top.scala 17:21]
  wire [4:0] dpath_io_round; // @[src/main/scala/sha3/Sha3Top.scala 17:21]
  wire [4:0] dpath_io_aindex; // @[src/main/scala/sha3/Sha3Top.scala 17:21]
  wire [63:0] dpath_io_message_in; // @[src/main/scala/sha3/Sha3Top.scala 17:21]
  wire [63:0] dpath_io_hash_out_0; // @[src/main/scala/sha3/Sha3Top.scala 17:21]
  wire [63:0] dpath_io_hash_out_1; // @[src/main/scala/sha3/Sha3Top.scala 17:21]
  wire [63:0] dpath_io_hash_out_2; // @[src/main/scala/sha3/Sha3Top.scala 17:21]
  wire [63:0] dpath_io_hash_out_3; // @[src/main/scala/sha3/Sha3Top.scala 17:21]
  DpathModule dpath ( // @[src/main/scala/sha3/Sha3Top.scala 17:21]
    .clock(dpath_clock),
    .reset(dpath_reset),
    .io_absorb(dpath_io_absorb),
    .io_init(dpath_io_init),
    .io_write(dpath_io_write),
    .io_round(dpath_io_round),
    .io_aindex(dpath_io_aindex),
    .io_message_in(dpath_io_message_in),
    .io_hash_out_0(dpath_io_hash_out_0),
    .io_hash_out_1(dpath_io_hash_out_1),
    .io_hash_out_2(dpath_io_hash_out_2),
    .io_hash_out_3(dpath_io_hash_out_3)
  );
  assign io_hash_out_0 = dpath_io_hash_out_0; // @[src/main/scala/sha3/Sha3Top.scala 43:20]
  assign io_hash_out_1 = dpath_io_hash_out_1; // @[src/main/scala/sha3/Sha3Top.scala 43:20]
  assign io_hash_out_2 = dpath_io_hash_out_2; // @[src/main/scala/sha3/Sha3Top.scala 43:20]
  assign io_hash_out_3 = dpath_io_hash_out_3; // @[src/main/scala/sha3/Sha3Top.scala 43:20]
  assign dpath_clock = clock;
  assign dpath_reset = reset;
  assign dpath_io_absorb = io_absorb; // @[src/main/scala/sha3/Sha3Top.scala 34:23]
  assign dpath_io_init = io_init; // @[src/main/scala/sha3/Sha3Top.scala 35:23]
  assign dpath_io_write = io_write; // @[src/main/scala/sha3/Sha3Top.scala 36:23]
  assign dpath_io_round = io_round; // @[src/main/scala/sha3/Sha3Top.scala 37:23]
  assign dpath_io_aindex = io_aindex; // @[src/main/scala/sha3/Sha3Top.scala 39:23]
  assign dpath_io_message_in = io_message_in; // @[src/main/scala/sha3/Sha3Top.scala 40:23]
endmodule
