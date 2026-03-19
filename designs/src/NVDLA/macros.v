// =============================================================================
// macros.v  —  NVDLA RAM wrappers bridging original port names → fakeram ports
// Technology : ASAP7 (7nm)  |  Generator: bgoldbug/dynamic_fakeram
//
// All original ports are preserved on every wrapper so existing NVDLA RTL
// connections compile without modification.
//
// Functional port mapping  (forwarded to fakeram instance):
//   CLK_R / CLK_W  →  r0_clk / w0_clk   (RAMDP dual-clock)
//   CLK            →  r0_clk + w0_clk    (RAMPDP single-clock)
//   RE             →  r0_ce_in
//   WE             →  w0_we_in
//   (tied)         →  w0_ce_in = 1'b1
//   RADR_[N-1:0]   →  r0_addr_in  (MSB→LSB concat)
//   WADR_[N-1:0]   →  w0_addr_in  (MSB→LSB concat)
//   WD_[W-1:0]     →  w0_wd_in    (MSB→LSB concat)
//   RD_[W-1:0]     ←  r0_rd_out   (via rd_bus wire)
//
// NC ports  (declared for compatibility, not forwarded — fakeram has no equiv):
//   IDDQ           — test/IDDQ mode        → not connected
//   SVOP_[N:0]     — scan vector output     → not connected
//   SLEEP_EN_[7:0] — power-gate zone enable → not connected
//   RET_EN         — retention enable       → not connected
// =============================================================================
`timescale 1ns/1ps

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=128  width=11  addr=7b
module RAMDP_128X11_GL_M2_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [10:0] rd_bus;
    assign {RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_11x128_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_128X11_GL_M2_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=128  width=6  addr=7b
module RAMDP_128X6_GL_M2_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [5:0] rd_bus;
    assign {RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_6x128_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_128X6_GL_M2_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=16  width=256  addr=4b
module RAMDP_16X256_GL_M1_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_255,
    WD_254,
    WD_253,
    WD_252,
    WD_251,
    WD_250,
    WD_249,
    WD_248,
    WD_247,
    WD_246,
    WD_245,
    WD_244,
    WD_243,
    WD_242,
    WD_241,
    WD_240,
    WD_239,
    WD_238,
    WD_237,
    WD_236,
    WD_235,
    WD_234,
    WD_233,
    WD_232,
    WD_231,
    WD_230,
    WD_229,
    WD_228,
    WD_227,
    WD_226,
    WD_225,
    WD_224,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_255,
    RD_254,
    RD_253,
    RD_252,
    RD_251,
    RD_250,
    RD_249,
    RD_248,
    RD_247,
    RD_246,
    RD_245,
    RD_244,
    RD_243,
    RD_242,
    RD_241,
    RD_240,
    RD_239,
    RD_238,
    RD_237,
    RD_236,
    RD_235,
    RD_234,
    RD_233,
    RD_232,
    RD_231,
    RD_230,
    RD_229,
    RD_228,
    RD_227,
    RD_226,
    RD_225,
    RD_224,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_255;
    input  WD_254;
    input  WD_253;
    input  WD_252;
    input  WD_251;
    input  WD_250;
    input  WD_249;
    input  WD_248;
    input  WD_247;
    input  WD_246;
    input  WD_245;
    input  WD_244;
    input  WD_243;
    input  WD_242;
    input  WD_241;
    input  WD_240;
    input  WD_239;
    input  WD_238;
    input  WD_237;
    input  WD_236;
    input  WD_235;
    input  WD_234;
    input  WD_233;
    input  WD_232;
    input  WD_231;
    input  WD_230;
    input  WD_229;
    input  WD_228;
    input  WD_227;
    input  WD_226;
    input  WD_225;
    input  WD_224;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_255;
    output RD_254;
    output RD_253;
    output RD_252;
    output RD_251;
    output RD_250;
    output RD_249;
    output RD_248;
    output RD_247;
    output RD_246;
    output RD_245;
    output RD_244;
    output RD_243;
    output RD_242;
    output RD_241;
    output RD_240;
    output RD_239;
    output RD_238;
    output RD_237;
    output RD_236;
    output RD_235;
    output RD_234;
    output RD_233;
    output RD_232;
    output RD_231;
    output RD_230;
    output RD_229;
    output RD_228;
    output RD_227;
    output RD_226;
    output RD_225;
    output RD_224;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [255:0] rd_bus;
    assign {RD_255, RD_254, RD_253, RD_252, RD_251, RD_250, RD_249, RD_248, RD_247, RD_246, RD_245, RD_244, RD_243, RD_242, RD_241, RD_240, RD_239, RD_238, RD_237, RD_236, RD_235, RD_234, RD_233, RD_232, RD_231, RD_230, RD_229, RD_228, RD_227, RD_226, RD_225, RD_224, RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_256x16_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_255, WD_254, WD_253, WD_252, WD_251, WD_250, WD_249, WD_248, WD_247, WD_246, WD_245, WD_244, WD_243, WD_242, WD_241, WD_240, WD_239, WD_238, WD_237, WD_236, WD_235, WD_234, WD_233, WD_232, WD_231, WD_230, WD_229, WD_228, WD_227, WD_226, WD_225, WD_224, WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_16X256_GL_M1_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=16  width=272  addr=4b
module RAMDP_16X272_GL_M1_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_271,
    WD_270,
    WD_269,
    WD_268,
    WD_267,
    WD_266,
    WD_265,
    WD_264,
    WD_263,
    WD_262,
    WD_261,
    WD_260,
    WD_259,
    WD_258,
    WD_257,
    WD_256,
    WD_255,
    WD_254,
    WD_253,
    WD_252,
    WD_251,
    WD_250,
    WD_249,
    WD_248,
    WD_247,
    WD_246,
    WD_245,
    WD_244,
    WD_243,
    WD_242,
    WD_241,
    WD_240,
    WD_239,
    WD_238,
    WD_237,
    WD_236,
    WD_235,
    WD_234,
    WD_233,
    WD_232,
    WD_231,
    WD_230,
    WD_229,
    WD_228,
    WD_227,
    WD_226,
    WD_225,
    WD_224,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_271,
    RD_270,
    RD_269,
    RD_268,
    RD_267,
    RD_266,
    RD_265,
    RD_264,
    RD_263,
    RD_262,
    RD_261,
    RD_260,
    RD_259,
    RD_258,
    RD_257,
    RD_256,
    RD_255,
    RD_254,
    RD_253,
    RD_252,
    RD_251,
    RD_250,
    RD_249,
    RD_248,
    RD_247,
    RD_246,
    RD_245,
    RD_244,
    RD_243,
    RD_242,
    RD_241,
    RD_240,
    RD_239,
    RD_238,
    RD_237,
    RD_236,
    RD_235,
    RD_234,
    RD_233,
    RD_232,
    RD_231,
    RD_230,
    RD_229,
    RD_228,
    RD_227,
    RD_226,
    RD_225,
    RD_224,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_271;
    input  WD_270;
    input  WD_269;
    input  WD_268;
    input  WD_267;
    input  WD_266;
    input  WD_265;
    input  WD_264;
    input  WD_263;
    input  WD_262;
    input  WD_261;
    input  WD_260;
    input  WD_259;
    input  WD_258;
    input  WD_257;
    input  WD_256;
    input  WD_255;
    input  WD_254;
    input  WD_253;
    input  WD_252;
    input  WD_251;
    input  WD_250;
    input  WD_249;
    input  WD_248;
    input  WD_247;
    input  WD_246;
    input  WD_245;
    input  WD_244;
    input  WD_243;
    input  WD_242;
    input  WD_241;
    input  WD_240;
    input  WD_239;
    input  WD_238;
    input  WD_237;
    input  WD_236;
    input  WD_235;
    input  WD_234;
    input  WD_233;
    input  WD_232;
    input  WD_231;
    input  WD_230;
    input  WD_229;
    input  WD_228;
    input  WD_227;
    input  WD_226;
    input  WD_225;
    input  WD_224;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_271;
    output RD_270;
    output RD_269;
    output RD_268;
    output RD_267;
    output RD_266;
    output RD_265;
    output RD_264;
    output RD_263;
    output RD_262;
    output RD_261;
    output RD_260;
    output RD_259;
    output RD_258;
    output RD_257;
    output RD_256;
    output RD_255;
    output RD_254;
    output RD_253;
    output RD_252;
    output RD_251;
    output RD_250;
    output RD_249;
    output RD_248;
    output RD_247;
    output RD_246;
    output RD_245;
    output RD_244;
    output RD_243;
    output RD_242;
    output RD_241;
    output RD_240;
    output RD_239;
    output RD_238;
    output RD_237;
    output RD_236;
    output RD_235;
    output RD_234;
    output RD_233;
    output RD_232;
    output RD_231;
    output RD_230;
    output RD_229;
    output RD_228;
    output RD_227;
    output RD_226;
    output RD_225;
    output RD_224;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [271:0] rd_bus;
    assign {RD_271, RD_270, RD_269, RD_268, RD_267, RD_266, RD_265, RD_264, RD_263, RD_262, RD_261, RD_260, RD_259, RD_258, RD_257, RD_256, RD_255, RD_254, RD_253, RD_252, RD_251, RD_250, RD_249, RD_248, RD_247, RD_246, RD_245, RD_244, RD_243, RD_242, RD_241, RD_240, RD_239, RD_238, RD_237, RD_236, RD_235, RD_234, RD_233, RD_232, RD_231, RD_230, RD_229, RD_228, RD_227, RD_226, RD_225, RD_224, RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_272x16_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_271, WD_270, WD_269, WD_268, WD_267, WD_266, WD_265, WD_264, WD_263, WD_262, WD_261, WD_260, WD_259, WD_258, WD_257, WD_256, WD_255, WD_254, WD_253, WD_252, WD_251, WD_250, WD_249, WD_248, WD_247, WD_246, WD_245, WD_244, WD_243, WD_242, WD_241, WD_240, WD_239, WD_238, WD_237, WD_236, WD_235, WD_234, WD_233, WD_232, WD_231, WD_230, WD_229, WD_228, WD_227, WD_226, WD_225, WD_224, WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_16X272_GL_M1_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=16  width=64  addr=4b
module RAMDP_16X64_GL_M1_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [63:0] rd_bus;
    assign {RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_64x16_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_16X64_GL_M1_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=20  width=288  addr=5b
module RAMDP_20X288_GL_M1_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_287,
    WD_286,
    WD_285,
    WD_284,
    WD_283,
    WD_282,
    WD_281,
    WD_280,
    WD_279,
    WD_278,
    WD_277,
    WD_276,
    WD_275,
    WD_274,
    WD_273,
    WD_272,
    WD_271,
    WD_270,
    WD_269,
    WD_268,
    WD_267,
    WD_266,
    WD_265,
    WD_264,
    WD_263,
    WD_262,
    WD_261,
    WD_260,
    WD_259,
    WD_258,
    WD_257,
    WD_256,
    WD_255,
    WD_254,
    WD_253,
    WD_252,
    WD_251,
    WD_250,
    WD_249,
    WD_248,
    WD_247,
    WD_246,
    WD_245,
    WD_244,
    WD_243,
    WD_242,
    WD_241,
    WD_240,
    WD_239,
    WD_238,
    WD_237,
    WD_236,
    WD_235,
    WD_234,
    WD_233,
    WD_232,
    WD_231,
    WD_230,
    WD_229,
    WD_228,
    WD_227,
    WD_226,
    WD_225,
    WD_224,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_287,
    RD_286,
    RD_285,
    RD_284,
    RD_283,
    RD_282,
    RD_281,
    RD_280,
    RD_279,
    RD_278,
    RD_277,
    RD_276,
    RD_275,
    RD_274,
    RD_273,
    RD_272,
    RD_271,
    RD_270,
    RD_269,
    RD_268,
    RD_267,
    RD_266,
    RD_265,
    RD_264,
    RD_263,
    RD_262,
    RD_261,
    RD_260,
    RD_259,
    RD_258,
    RD_257,
    RD_256,
    RD_255,
    RD_254,
    RD_253,
    RD_252,
    RD_251,
    RD_250,
    RD_249,
    RD_248,
    RD_247,
    RD_246,
    RD_245,
    RD_244,
    RD_243,
    RD_242,
    RD_241,
    RD_240,
    RD_239,
    RD_238,
    RD_237,
    RD_236,
    RD_235,
    RD_234,
    RD_233,
    RD_232,
    RD_231,
    RD_230,
    RD_229,
    RD_228,
    RD_227,
    RD_226,
    RD_225,
    RD_224,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_287;
    input  WD_286;
    input  WD_285;
    input  WD_284;
    input  WD_283;
    input  WD_282;
    input  WD_281;
    input  WD_280;
    input  WD_279;
    input  WD_278;
    input  WD_277;
    input  WD_276;
    input  WD_275;
    input  WD_274;
    input  WD_273;
    input  WD_272;
    input  WD_271;
    input  WD_270;
    input  WD_269;
    input  WD_268;
    input  WD_267;
    input  WD_266;
    input  WD_265;
    input  WD_264;
    input  WD_263;
    input  WD_262;
    input  WD_261;
    input  WD_260;
    input  WD_259;
    input  WD_258;
    input  WD_257;
    input  WD_256;
    input  WD_255;
    input  WD_254;
    input  WD_253;
    input  WD_252;
    input  WD_251;
    input  WD_250;
    input  WD_249;
    input  WD_248;
    input  WD_247;
    input  WD_246;
    input  WD_245;
    input  WD_244;
    input  WD_243;
    input  WD_242;
    input  WD_241;
    input  WD_240;
    input  WD_239;
    input  WD_238;
    input  WD_237;
    input  WD_236;
    input  WD_235;
    input  WD_234;
    input  WD_233;
    input  WD_232;
    input  WD_231;
    input  WD_230;
    input  WD_229;
    input  WD_228;
    input  WD_227;
    input  WD_226;
    input  WD_225;
    input  WD_224;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_287;
    output RD_286;
    output RD_285;
    output RD_284;
    output RD_283;
    output RD_282;
    output RD_281;
    output RD_280;
    output RD_279;
    output RD_278;
    output RD_277;
    output RD_276;
    output RD_275;
    output RD_274;
    output RD_273;
    output RD_272;
    output RD_271;
    output RD_270;
    output RD_269;
    output RD_268;
    output RD_267;
    output RD_266;
    output RD_265;
    output RD_264;
    output RD_263;
    output RD_262;
    output RD_261;
    output RD_260;
    output RD_259;
    output RD_258;
    output RD_257;
    output RD_256;
    output RD_255;
    output RD_254;
    output RD_253;
    output RD_252;
    output RD_251;
    output RD_250;
    output RD_249;
    output RD_248;
    output RD_247;
    output RD_246;
    output RD_245;
    output RD_244;
    output RD_243;
    output RD_242;
    output RD_241;
    output RD_240;
    output RD_239;
    output RD_238;
    output RD_237;
    output RD_236;
    output RD_235;
    output RD_234;
    output RD_233;
    output RD_232;
    output RD_231;
    output RD_230;
    output RD_229;
    output RD_228;
    output RD_227;
    output RD_226;
    output RD_225;
    output RD_224;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [287:0] rd_bus;
    assign {RD_287, RD_286, RD_285, RD_284, RD_283, RD_282, RD_281, RD_280, RD_279, RD_278, RD_277, RD_276, RD_275, RD_274, RD_273, RD_272, RD_271, RD_270, RD_269, RD_268, RD_267, RD_266, RD_265, RD_264, RD_263, RD_262, RD_261, RD_260, RD_259, RD_258, RD_257, RD_256, RD_255, RD_254, RD_253, RD_252, RD_251, RD_250, RD_249, RD_248, RD_247, RD_246, RD_245, RD_244, RD_243, RD_242, RD_241, RD_240, RD_239, RD_238, RD_237, RD_236, RD_235, RD_234, RD_233, RD_232, RD_231, RD_230, RD_229, RD_228, RD_227, RD_226, RD_225, RD_224, RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_288x20_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_287, WD_286, WD_285, WD_284, WD_283, WD_282, WD_281, WD_280, WD_279, WD_278, WD_277, WD_276, WD_275, WD_274, WD_273, WD_272, WD_271, WD_270, WD_269, WD_268, WD_267, WD_266, WD_265, WD_264, WD_263, WD_262, WD_261, WD_260, WD_259, WD_258, WD_257, WD_256, WD_255, WD_254, WD_253, WD_252, WD_251, WD_250, WD_249, WD_248, WD_247, WD_246, WD_245, WD_244, WD_243, WD_242, WD_241, WD_240, WD_239, WD_238, WD_237, WD_236, WD_235, WD_234, WD_233, WD_232, WD_231, WD_230, WD_229, WD_228, WD_227, WD_226, WD_225, WD_224, WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_20X288_GL_M1_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=20  width=80  addr=5b
module RAMDP_20X80_GL_M1_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [79:0] rd_bus;
    assign {RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_80x20_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_20X80_GL_M1_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=256  width=4  addr=8b
module RAMDP_256X4_GL_M2_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [3:0] rd_bus;
    assign {RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_4x256_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_256X4_GL_M2_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=256  width=7  addr=8b
module RAMDP_256X7_GL_M2_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [6:0] rd_bus;
    assign {RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_7x256_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_256X7_GL_M2_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=256  width=8  addr=8b
module RAMDP_256X8_GL_M2_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [7:0] rd_bus;
    assign {RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_8x256_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_256X8_GL_M2_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=32  width=16  addr=5b
module RAMDP_32X16_GL_M1_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [15:0] rd_bus;
    assign {RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_16x32_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_32X16_GL_M1_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=32  width=32  addr=5b
module RAMDP_32X32_GL_M1_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [31:0] rd_bus;
    assign {RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_32x32_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_32X32_GL_M1_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=60  width=22  addr=6b
module RAMDP_60X22_GL_M1_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [21:0] rd_bus;
    assign {RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_22x60_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_60X22_GL_M1_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=64  width=10  addr=6b
module RAMDP_64X10_GL_M2_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [9:0] rd_bus;
    assign {RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_10x64_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_64X10_GL_M2_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=64  width=18  addr=6b
module RAMDP_64X18_GL_M2_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [17:0] rd_bus;
    assign {RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_18x64_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_64X18_GL_M2_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=80  width=14  addr=7b
module RAMDP_80X14_GL_M2_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [13:0] rd_bus;
    assign {RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_14x80_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_80X14_GL_M2_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=80  width=15  addr=7b
module RAMDP_80X15_GL_M2_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [14:0] rd_bus;
    assign {RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_15x80_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_80X15_GL_M2_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=80  width=9  addr=7b
module RAMDP_80X9_GL_M2_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [8:0] rd_bus;
    assign {RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_9x80_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_80X9_GL_M2_E2

// RAMDP dual-clock 1R1W (CLK_R / CLK_W)  |  depth=8  width=66  addr=3b
module RAMDP_8X66_GL_M1_E2 (
    CLK_R,
    CLK_W,
    RE,
    WE,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_2,
    WADR_1,
    WADR_0,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    SLEEP_EN_7,
    SLEEP_EN_6,
    SLEEP_EN_5,
    SLEEP_EN_4,
    SLEEP_EN_3,
    SLEEP_EN_2,
    SLEEP_EN_1,
    SLEEP_EN_0,
    RET_EN,
    IDDQ,
    SVOP_1,
    SVOP_0,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK_R;
    input  CLK_W;
    input  RE;
    input  WE;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  SLEEP_EN_7;
    input  SLEEP_EN_6;
    input  SLEEP_EN_5;
    input  SLEEP_EN_4;
    input  SLEEP_EN_3;
    input  SLEEP_EN_2;
    input  SLEEP_EN_1;
    input  SLEEP_EN_0;
    input  RET_EN;
    input  IDDQ;
    input  SVOP_1;
    input  SVOP_0;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [65:0] rd_bus;
    assign {RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // SLEEP_EN_7, SLEEP_EN_6, SLEEP_EN_5, SLEEP_EN_4, SLEEP_EN_3, SLEEP_EN_2, SLEEP_EN_1, SLEEP_EN_0, RET_EN, IDDQ, SVOP_1, SVOP_0

    fakeram_66x8_1r1w sram (
        .r0_clk     (CLK_R),
        .w0_clk     (CLK_W),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMDP_8X66_GL_M1_E2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=128  width=18  addr=7b
module RAMPDP_128X18_GL_M2_D2 (
    CLK,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [17:0] rd_bus;
    assign {RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_18x128_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_128X18_GL_M2_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=128  width=256  addr=7b
module RAMPDP_128X256_GL_M1_D2 (
    CLK,
    WD_255,
    WD_254,
    WD_253,
    WD_252,
    WD_251,
    WD_250,
    WD_249,
    WD_248,
    WD_247,
    WD_246,
    WD_245,
    WD_244,
    WD_243,
    WD_242,
    WD_241,
    WD_240,
    WD_239,
    WD_238,
    WD_237,
    WD_236,
    WD_235,
    WD_234,
    WD_233,
    WD_232,
    WD_231,
    WD_230,
    WD_229,
    WD_228,
    WD_227,
    WD_226,
    WD_225,
    WD_224,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_255,
    RD_254,
    RD_253,
    RD_252,
    RD_251,
    RD_250,
    RD_249,
    RD_248,
    RD_247,
    RD_246,
    RD_245,
    RD_244,
    RD_243,
    RD_242,
    RD_241,
    RD_240,
    RD_239,
    RD_238,
    RD_237,
    RD_236,
    RD_235,
    RD_234,
    RD_233,
    RD_232,
    RD_231,
    RD_230,
    RD_229,
    RD_228,
    RD_227,
    RD_226,
    RD_225,
    RD_224,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_255;
    input  WD_254;
    input  WD_253;
    input  WD_252;
    input  WD_251;
    input  WD_250;
    input  WD_249;
    input  WD_248;
    input  WD_247;
    input  WD_246;
    input  WD_245;
    input  WD_244;
    input  WD_243;
    input  WD_242;
    input  WD_241;
    input  WD_240;
    input  WD_239;
    input  WD_238;
    input  WD_237;
    input  WD_236;
    input  WD_235;
    input  WD_234;
    input  WD_233;
    input  WD_232;
    input  WD_231;
    input  WD_230;
    input  WD_229;
    input  WD_228;
    input  WD_227;
    input  WD_226;
    input  WD_225;
    input  WD_224;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_255;
    output RD_254;
    output RD_253;
    output RD_252;
    output RD_251;
    output RD_250;
    output RD_249;
    output RD_248;
    output RD_247;
    output RD_246;
    output RD_245;
    output RD_244;
    output RD_243;
    output RD_242;
    output RD_241;
    output RD_240;
    output RD_239;
    output RD_238;
    output RD_237;
    output RD_236;
    output RD_235;
    output RD_234;
    output RD_233;
    output RD_232;
    output RD_231;
    output RD_230;
    output RD_229;
    output RD_228;
    output RD_227;
    output RD_226;
    output RD_225;
    output RD_224;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [255:0] rd_bus;
    assign {RD_255, RD_254, RD_253, RD_252, RD_251, RD_250, RD_249, RD_248, RD_247, RD_246, RD_245, RD_244, RD_243, RD_242, RD_241, RD_240, RD_239, RD_238, RD_237, RD_236, RD_235, RD_234, RD_233, RD_232, RD_231, RD_230, RD_229, RD_228, RD_227, RD_226, RD_225, RD_224, RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_256x128_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_255, WD_254, WD_253, WD_252, WD_251, WD_250, WD_249, WD_248, WD_247, WD_246, WD_245, WD_244, WD_243, WD_242, WD_241, WD_240, WD_239, WD_238, WD_237, WD_236, WD_235, WD_234, WD_233, WD_232, WD_231, WD_230, WD_229, WD_228, WD_227, WD_226, WD_225, WD_224, WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_128X256_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=128  width=64  addr=7b
module RAMPDP_128X64_GL_M1_D2 (
    CLK,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [63:0] rd_bus;
    assign {RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_64x128_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_128X64_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=160  width=144  addr=8b
module RAMPDP_160X144_GL_M2_D2 (
    CLK,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [143:0] rd_bus;
    assign {RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_144x160_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_160X144_GL_M2_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=160  width=16  addr=8b
module RAMPDP_160X16_GL_M2_D2 (
    CLK,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [15:0] rd_bus;
    assign {RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_16x160_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_160X16_GL_M2_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=160  width=65  addr=8b
module RAMPDP_160X65_GL_M2_D2 (
    CLK,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [64:0] rd_bus;
    assign {RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_65x160_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_160X65_GL_M2_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=160  width=82  addr=8b
module RAMPDP_160X82_GL_M2_D2 (
    CLK,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [81:0] rd_bus;
    assign {RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_82x160_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_160X82_GL_M2_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=248  width=144  addr=8b
module RAMPDP_248X144_GL_M2_D2 (
    CLK,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [143:0] rd_bus;
    assign {RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_144x248_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_248X144_GL_M2_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=248  width=82  addr=8b
module RAMPDP_248X82_GL_M2_D2 (
    CLK,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [81:0] rd_bus;
    assign {RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_82x248_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_248X82_GL_M2_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=256  width=11  addr=8b
module RAMPDP_256X11_GL_M4_D2 (
    CLK,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [10:0] rd_bus;
    assign {RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_11x256_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_256X11_GL_M4_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=256  width=144  addr=8b
module RAMPDP_256X144_GL_M2_D2 (
    CLK,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [143:0] rd_bus;
    assign {RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_144x256_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_256X144_GL_M2_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=256  width=64  addr=8b
module RAMPDP_256X64_GL_M2_D2 (
    CLK,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [63:0] rd_bus;
    assign {RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_64x256_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_256X64_GL_M2_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=256  width=80  addr=8b
module RAMPDP_256X80_GL_M2_D2 (
    CLK,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [79:0] rd_bus;
    assign {RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_80x256_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_256X80_GL_M2_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=32  width=192  addr=5b
module RAMPDP_32X192_GL_M1_D2 (
    CLK,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [191:0] rd_bus;
    assign {RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_192x32_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_32X192_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=32  width=224  addr=5b
module RAMPDP_32X224_GL_M1_D2 (
    CLK,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [223:0] rd_bus;
    assign {RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_224x32_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_32X224_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=32  width=256  addr=5b
module RAMPDP_32X256_GL_M1_D2 (
    CLK,
    WD_255,
    WD_254,
    WD_253,
    WD_252,
    WD_251,
    WD_250,
    WD_249,
    WD_248,
    WD_247,
    WD_246,
    WD_245,
    WD_244,
    WD_243,
    WD_242,
    WD_241,
    WD_240,
    WD_239,
    WD_238,
    WD_237,
    WD_236,
    WD_235,
    WD_234,
    WD_233,
    WD_232,
    WD_231,
    WD_230,
    WD_229,
    WD_228,
    WD_227,
    WD_226,
    WD_225,
    WD_224,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_255,
    RD_254,
    RD_253,
    RD_252,
    RD_251,
    RD_250,
    RD_249,
    RD_248,
    RD_247,
    RD_246,
    RD_245,
    RD_244,
    RD_243,
    RD_242,
    RD_241,
    RD_240,
    RD_239,
    RD_238,
    RD_237,
    RD_236,
    RD_235,
    RD_234,
    RD_233,
    RD_232,
    RD_231,
    RD_230,
    RD_229,
    RD_228,
    RD_227,
    RD_226,
    RD_225,
    RD_224,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_255;
    input  WD_254;
    input  WD_253;
    input  WD_252;
    input  WD_251;
    input  WD_250;
    input  WD_249;
    input  WD_248;
    input  WD_247;
    input  WD_246;
    input  WD_245;
    input  WD_244;
    input  WD_243;
    input  WD_242;
    input  WD_241;
    input  WD_240;
    input  WD_239;
    input  WD_238;
    input  WD_237;
    input  WD_236;
    input  WD_235;
    input  WD_234;
    input  WD_233;
    input  WD_232;
    input  WD_231;
    input  WD_230;
    input  WD_229;
    input  WD_228;
    input  WD_227;
    input  WD_226;
    input  WD_225;
    input  WD_224;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_255;
    output RD_254;
    output RD_253;
    output RD_252;
    output RD_251;
    output RD_250;
    output RD_249;
    output RD_248;
    output RD_247;
    output RD_246;
    output RD_245;
    output RD_244;
    output RD_243;
    output RD_242;
    output RD_241;
    output RD_240;
    output RD_239;
    output RD_238;
    output RD_237;
    output RD_236;
    output RD_235;
    output RD_234;
    output RD_233;
    output RD_232;
    output RD_231;
    output RD_230;
    output RD_229;
    output RD_228;
    output RD_227;
    output RD_226;
    output RD_225;
    output RD_224;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [255:0] rd_bus;
    assign {RD_255, RD_254, RD_253, RD_252, RD_251, RD_250, RD_249, RD_248, RD_247, RD_246, RD_245, RD_244, RD_243, RD_242, RD_241, RD_240, RD_239, RD_238, RD_237, RD_236, RD_235, RD_234, RD_233, RD_232, RD_231, RD_230, RD_229, RD_228, RD_227, RD_226, RD_225, RD_224, RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_256x32_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_255, WD_254, WD_253, WD_252, WD_251, WD_250, WD_249, WD_248, WD_247, WD_246, WD_245, WD_244, WD_243, WD_242, WD_241, WD_240, WD_239, WD_238, WD_237, WD_236, WD_235, WD_234, WD_233, WD_232, WD_231, WD_230, WD_229, WD_228, WD_227, WD_226, WD_225, WD_224, WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_32X256_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=32  width=272  addr=5b
module RAMPDP_32X272_GL_M1_D2 (
    CLK,
    WD_271,
    WD_270,
    WD_269,
    WD_268,
    WD_267,
    WD_266,
    WD_265,
    WD_264,
    WD_263,
    WD_262,
    WD_261,
    WD_260,
    WD_259,
    WD_258,
    WD_257,
    WD_256,
    WD_255,
    WD_254,
    WD_253,
    WD_252,
    WD_251,
    WD_250,
    WD_249,
    WD_248,
    WD_247,
    WD_246,
    WD_245,
    WD_244,
    WD_243,
    WD_242,
    WD_241,
    WD_240,
    WD_239,
    WD_238,
    WD_237,
    WD_236,
    WD_235,
    WD_234,
    WD_233,
    WD_232,
    WD_231,
    WD_230,
    WD_229,
    WD_228,
    WD_227,
    WD_226,
    WD_225,
    WD_224,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_271,
    RD_270,
    RD_269,
    RD_268,
    RD_267,
    RD_266,
    RD_265,
    RD_264,
    RD_263,
    RD_262,
    RD_261,
    RD_260,
    RD_259,
    RD_258,
    RD_257,
    RD_256,
    RD_255,
    RD_254,
    RD_253,
    RD_252,
    RD_251,
    RD_250,
    RD_249,
    RD_248,
    RD_247,
    RD_246,
    RD_245,
    RD_244,
    RD_243,
    RD_242,
    RD_241,
    RD_240,
    RD_239,
    RD_238,
    RD_237,
    RD_236,
    RD_235,
    RD_234,
    RD_233,
    RD_232,
    RD_231,
    RD_230,
    RD_229,
    RD_228,
    RD_227,
    RD_226,
    RD_225,
    RD_224,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_271;
    input  WD_270;
    input  WD_269;
    input  WD_268;
    input  WD_267;
    input  WD_266;
    input  WD_265;
    input  WD_264;
    input  WD_263;
    input  WD_262;
    input  WD_261;
    input  WD_260;
    input  WD_259;
    input  WD_258;
    input  WD_257;
    input  WD_256;
    input  WD_255;
    input  WD_254;
    input  WD_253;
    input  WD_252;
    input  WD_251;
    input  WD_250;
    input  WD_249;
    input  WD_248;
    input  WD_247;
    input  WD_246;
    input  WD_245;
    input  WD_244;
    input  WD_243;
    input  WD_242;
    input  WD_241;
    input  WD_240;
    input  WD_239;
    input  WD_238;
    input  WD_237;
    input  WD_236;
    input  WD_235;
    input  WD_234;
    input  WD_233;
    input  WD_232;
    input  WD_231;
    input  WD_230;
    input  WD_229;
    input  WD_228;
    input  WD_227;
    input  WD_226;
    input  WD_225;
    input  WD_224;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_271;
    output RD_270;
    output RD_269;
    output RD_268;
    output RD_267;
    output RD_266;
    output RD_265;
    output RD_264;
    output RD_263;
    output RD_262;
    output RD_261;
    output RD_260;
    output RD_259;
    output RD_258;
    output RD_257;
    output RD_256;
    output RD_255;
    output RD_254;
    output RD_253;
    output RD_252;
    output RD_251;
    output RD_250;
    output RD_249;
    output RD_248;
    output RD_247;
    output RD_246;
    output RD_245;
    output RD_244;
    output RD_243;
    output RD_242;
    output RD_241;
    output RD_240;
    output RD_239;
    output RD_238;
    output RD_237;
    output RD_236;
    output RD_235;
    output RD_234;
    output RD_233;
    output RD_232;
    output RD_231;
    output RD_230;
    output RD_229;
    output RD_228;
    output RD_227;
    output RD_226;
    output RD_225;
    output RD_224;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [271:0] rd_bus;
    assign {RD_271, RD_270, RD_269, RD_268, RD_267, RD_266, RD_265, RD_264, RD_263, RD_262, RD_261, RD_260, RD_259, RD_258, RD_257, RD_256, RD_255, RD_254, RD_253, RD_252, RD_251, RD_250, RD_249, RD_248, RD_247, RD_246, RD_245, RD_244, RD_243, RD_242, RD_241, RD_240, RD_239, RD_238, RD_237, RD_236, RD_235, RD_234, RD_233, RD_232, RD_231, RD_230, RD_229, RD_228, RD_227, RD_226, RD_225, RD_224, RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_272x32_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_271, WD_270, WD_269, WD_268, WD_267, WD_266, WD_265, WD_264, WD_263, WD_262, WD_261, WD_260, WD_259, WD_258, WD_257, WD_256, WD_255, WD_254, WD_253, WD_252, WD_251, WD_250, WD_249, WD_248, WD_247, WD_246, WD_245, WD_244, WD_243, WD_242, WD_241, WD_240, WD_239, WD_238, WD_237, WD_236, WD_235, WD_234, WD_233, WD_232, WD_231, WD_230, WD_229, WD_228, WD_227, WD_226, WD_225, WD_224, WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_32X272_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=32  width=288  addr=5b
module RAMPDP_32X288_GL_M1_D2 (
    CLK,
    WD_287,
    WD_286,
    WD_285,
    WD_284,
    WD_283,
    WD_282,
    WD_281,
    WD_280,
    WD_279,
    WD_278,
    WD_277,
    WD_276,
    WD_275,
    WD_274,
    WD_273,
    WD_272,
    WD_271,
    WD_270,
    WD_269,
    WD_268,
    WD_267,
    WD_266,
    WD_265,
    WD_264,
    WD_263,
    WD_262,
    WD_261,
    WD_260,
    WD_259,
    WD_258,
    WD_257,
    WD_256,
    WD_255,
    WD_254,
    WD_253,
    WD_252,
    WD_251,
    WD_250,
    WD_249,
    WD_248,
    WD_247,
    WD_246,
    WD_245,
    WD_244,
    WD_243,
    WD_242,
    WD_241,
    WD_240,
    WD_239,
    WD_238,
    WD_237,
    WD_236,
    WD_235,
    WD_234,
    WD_233,
    WD_232,
    WD_231,
    WD_230,
    WD_229,
    WD_228,
    WD_227,
    WD_226,
    WD_225,
    WD_224,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_287,
    RD_286,
    RD_285,
    RD_284,
    RD_283,
    RD_282,
    RD_281,
    RD_280,
    RD_279,
    RD_278,
    RD_277,
    RD_276,
    RD_275,
    RD_274,
    RD_273,
    RD_272,
    RD_271,
    RD_270,
    RD_269,
    RD_268,
    RD_267,
    RD_266,
    RD_265,
    RD_264,
    RD_263,
    RD_262,
    RD_261,
    RD_260,
    RD_259,
    RD_258,
    RD_257,
    RD_256,
    RD_255,
    RD_254,
    RD_253,
    RD_252,
    RD_251,
    RD_250,
    RD_249,
    RD_248,
    RD_247,
    RD_246,
    RD_245,
    RD_244,
    RD_243,
    RD_242,
    RD_241,
    RD_240,
    RD_239,
    RD_238,
    RD_237,
    RD_236,
    RD_235,
    RD_234,
    RD_233,
    RD_232,
    RD_231,
    RD_230,
    RD_229,
    RD_228,
    RD_227,
    RD_226,
    RD_225,
    RD_224,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_287;
    input  WD_286;
    input  WD_285;
    input  WD_284;
    input  WD_283;
    input  WD_282;
    input  WD_281;
    input  WD_280;
    input  WD_279;
    input  WD_278;
    input  WD_277;
    input  WD_276;
    input  WD_275;
    input  WD_274;
    input  WD_273;
    input  WD_272;
    input  WD_271;
    input  WD_270;
    input  WD_269;
    input  WD_268;
    input  WD_267;
    input  WD_266;
    input  WD_265;
    input  WD_264;
    input  WD_263;
    input  WD_262;
    input  WD_261;
    input  WD_260;
    input  WD_259;
    input  WD_258;
    input  WD_257;
    input  WD_256;
    input  WD_255;
    input  WD_254;
    input  WD_253;
    input  WD_252;
    input  WD_251;
    input  WD_250;
    input  WD_249;
    input  WD_248;
    input  WD_247;
    input  WD_246;
    input  WD_245;
    input  WD_244;
    input  WD_243;
    input  WD_242;
    input  WD_241;
    input  WD_240;
    input  WD_239;
    input  WD_238;
    input  WD_237;
    input  WD_236;
    input  WD_235;
    input  WD_234;
    input  WD_233;
    input  WD_232;
    input  WD_231;
    input  WD_230;
    input  WD_229;
    input  WD_228;
    input  WD_227;
    input  WD_226;
    input  WD_225;
    input  WD_224;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_287;
    output RD_286;
    output RD_285;
    output RD_284;
    output RD_283;
    output RD_282;
    output RD_281;
    output RD_280;
    output RD_279;
    output RD_278;
    output RD_277;
    output RD_276;
    output RD_275;
    output RD_274;
    output RD_273;
    output RD_272;
    output RD_271;
    output RD_270;
    output RD_269;
    output RD_268;
    output RD_267;
    output RD_266;
    output RD_265;
    output RD_264;
    output RD_263;
    output RD_262;
    output RD_261;
    output RD_260;
    output RD_259;
    output RD_258;
    output RD_257;
    output RD_256;
    output RD_255;
    output RD_254;
    output RD_253;
    output RD_252;
    output RD_251;
    output RD_250;
    output RD_249;
    output RD_248;
    output RD_247;
    output RD_246;
    output RD_245;
    output RD_244;
    output RD_243;
    output RD_242;
    output RD_241;
    output RD_240;
    output RD_239;
    output RD_238;
    output RD_237;
    output RD_236;
    output RD_235;
    output RD_234;
    output RD_233;
    output RD_232;
    output RD_231;
    output RD_230;
    output RD_229;
    output RD_228;
    output RD_227;
    output RD_226;
    output RD_225;
    output RD_224;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [287:0] rd_bus;
    assign {RD_287, RD_286, RD_285, RD_284, RD_283, RD_282, RD_281, RD_280, RD_279, RD_278, RD_277, RD_276, RD_275, RD_274, RD_273, RD_272, RD_271, RD_270, RD_269, RD_268, RD_267, RD_266, RD_265, RD_264, RD_263, RD_262, RD_261, RD_260, RD_259, RD_258, RD_257, RD_256, RD_255, RD_254, RD_253, RD_252, RD_251, RD_250, RD_249, RD_248, RD_247, RD_246, RD_245, RD_244, RD_243, RD_242, RD_241, RD_240, RD_239, RD_238, RD_237, RD_236, RD_235, RD_234, RD_233, RD_232, RD_231, RD_230, RD_229, RD_228, RD_227, RD_226, RD_225, RD_224, RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_288x32_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_287, WD_286, WD_285, WD_284, WD_283, WD_282, WD_281, WD_280, WD_279, WD_278, WD_277, WD_276, WD_275, WD_274, WD_273, WD_272, WD_271, WD_270, WD_269, WD_268, WD_267, WD_266, WD_265, WD_264, WD_263, WD_262, WD_261, WD_260, WD_259, WD_258, WD_257, WD_256, WD_255, WD_254, WD_253, WD_252, WD_251, WD_250, WD_249, WD_248, WD_247, WD_246, WD_245, WD_244, WD_243, WD_242, WD_241, WD_240, WD_239, WD_238, WD_237, WD_236, WD_235, WD_234, WD_233, WD_232, WD_231, WD_230, WD_229, WD_228, WD_227, WD_226, WD_225, WD_224, WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_32X288_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=512  width=40  addr=9b
module RAMPDP_512X40_GL_M4_D2 (
    CLK,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_8,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_8,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_8;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_8;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [39:0] rd_bus;
    assign {RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_40x512_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_8, RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_8, WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_512X40_GL_M4_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=512  width=64  addr=9b
module RAMPDP_512X64_GL_M4_D2 (
    CLK,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_8,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_8,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_8;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_8;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [63:0] rd_bus;
    assign {RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_64x512_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_8, RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_8, WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_512X64_GL_M4_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=512  width=72  addr=9b
module RAMPDP_512X72_GL_M4_D2 (
    CLK,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_8,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_8,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_8;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_8;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [71:0] rd_bus;
    assign {RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_72x512_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_8, RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_8, WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_512X72_GL_M4_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=512  width=8  addr=9b
module RAMPDP_512X8_GL_M4_D2 (
    CLK,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_8,
    RADR_7,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_8,
    WADR_7,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_8;
    input  RADR_7;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_8;
    input  WADR_7;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [7:0] rd_bus;
    assign {RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_8x512_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_8, RADR_7, RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_8, WADR_7, WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_512X8_GL_M4_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=60  width=168  addr=6b
module RAMPDP_60X168_GL_M1_D2 (
    CLK,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [167:0] rd_bus;
    assign {RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_168x60_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_60X168_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=64  width=116  addr=6b
module RAMPDP_64X116_GL_M1_D2 (
    CLK,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [115:0] rd_bus;
    assign {RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_116x64_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_64X116_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=64  width=160  addr=6b
module RAMPDP_64X160_GL_M1_D2 (
    CLK,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [159:0] rd_bus;
    assign {RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_160x64_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_64X160_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=64  width=224  addr=6b
module RAMPDP_64X224_GL_M1_D2 (
    CLK,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [223:0] rd_bus;
    assign {RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_224x64_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_64X224_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=64  width=226  addr=6b
module RAMPDP_64X226_GL_M1_D2 (
    CLK,
    WD_225,
    WD_224,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_225,
    RD_224,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_225;
    input  WD_224;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_225;
    output RD_224;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [225:0] rd_bus;
    assign {RD_225, RD_224, RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_226x64_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_225, WD_224, WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_64X226_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=64  width=288  addr=6b
module RAMPDP_64X288_GL_M1_D2 (
    CLK,
    WD_287,
    WD_286,
    WD_285,
    WD_284,
    WD_283,
    WD_282,
    WD_281,
    WD_280,
    WD_279,
    WD_278,
    WD_277,
    WD_276,
    WD_275,
    WD_274,
    WD_273,
    WD_272,
    WD_271,
    WD_270,
    WD_269,
    WD_268,
    WD_267,
    WD_266,
    WD_265,
    WD_264,
    WD_263,
    WD_262,
    WD_261,
    WD_260,
    WD_259,
    WD_258,
    WD_257,
    WD_256,
    WD_255,
    WD_254,
    WD_253,
    WD_252,
    WD_251,
    WD_250,
    WD_249,
    WD_248,
    WD_247,
    WD_246,
    WD_245,
    WD_244,
    WD_243,
    WD_242,
    WD_241,
    WD_240,
    WD_239,
    WD_238,
    WD_237,
    WD_236,
    WD_235,
    WD_234,
    WD_233,
    WD_232,
    WD_231,
    WD_230,
    WD_229,
    WD_228,
    WD_227,
    WD_226,
    WD_225,
    WD_224,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_287,
    RD_286,
    RD_285,
    RD_284,
    RD_283,
    RD_282,
    RD_281,
    RD_280,
    RD_279,
    RD_278,
    RD_277,
    RD_276,
    RD_275,
    RD_274,
    RD_273,
    RD_272,
    RD_271,
    RD_270,
    RD_269,
    RD_268,
    RD_267,
    RD_266,
    RD_265,
    RD_264,
    RD_263,
    RD_262,
    RD_261,
    RD_260,
    RD_259,
    RD_258,
    RD_257,
    RD_256,
    RD_255,
    RD_254,
    RD_253,
    RD_252,
    RD_251,
    RD_250,
    RD_249,
    RD_248,
    RD_247,
    RD_246,
    RD_245,
    RD_244,
    RD_243,
    RD_242,
    RD_241,
    RD_240,
    RD_239,
    RD_238,
    RD_237,
    RD_236,
    RD_235,
    RD_234,
    RD_233,
    RD_232,
    RD_231,
    RD_230,
    RD_229,
    RD_228,
    RD_227,
    RD_226,
    RD_225,
    RD_224,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_287;
    input  WD_286;
    input  WD_285;
    input  WD_284;
    input  WD_283;
    input  WD_282;
    input  WD_281;
    input  WD_280;
    input  WD_279;
    input  WD_278;
    input  WD_277;
    input  WD_276;
    input  WD_275;
    input  WD_274;
    input  WD_273;
    input  WD_272;
    input  WD_271;
    input  WD_270;
    input  WD_269;
    input  WD_268;
    input  WD_267;
    input  WD_266;
    input  WD_265;
    input  WD_264;
    input  WD_263;
    input  WD_262;
    input  WD_261;
    input  WD_260;
    input  WD_259;
    input  WD_258;
    input  WD_257;
    input  WD_256;
    input  WD_255;
    input  WD_254;
    input  WD_253;
    input  WD_252;
    input  WD_251;
    input  WD_250;
    input  WD_249;
    input  WD_248;
    input  WD_247;
    input  WD_246;
    input  WD_245;
    input  WD_244;
    input  WD_243;
    input  WD_242;
    input  WD_241;
    input  WD_240;
    input  WD_239;
    input  WD_238;
    input  WD_237;
    input  WD_236;
    input  WD_235;
    input  WD_234;
    input  WD_233;
    input  WD_232;
    input  WD_231;
    input  WD_230;
    input  WD_229;
    input  WD_228;
    input  WD_227;
    input  WD_226;
    input  WD_225;
    input  WD_224;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_287;
    output RD_286;
    output RD_285;
    output RD_284;
    output RD_283;
    output RD_282;
    output RD_281;
    output RD_280;
    output RD_279;
    output RD_278;
    output RD_277;
    output RD_276;
    output RD_275;
    output RD_274;
    output RD_273;
    output RD_272;
    output RD_271;
    output RD_270;
    output RD_269;
    output RD_268;
    output RD_267;
    output RD_266;
    output RD_265;
    output RD_264;
    output RD_263;
    output RD_262;
    output RD_261;
    output RD_260;
    output RD_259;
    output RD_258;
    output RD_257;
    output RD_256;
    output RD_255;
    output RD_254;
    output RD_253;
    output RD_252;
    output RD_251;
    output RD_250;
    output RD_249;
    output RD_248;
    output RD_247;
    output RD_246;
    output RD_245;
    output RD_244;
    output RD_243;
    output RD_242;
    output RD_241;
    output RD_240;
    output RD_239;
    output RD_238;
    output RD_237;
    output RD_236;
    output RD_235;
    output RD_234;
    output RD_233;
    output RD_232;
    output RD_231;
    output RD_230;
    output RD_229;
    output RD_228;
    output RD_227;
    output RD_226;
    output RD_225;
    output RD_224;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [287:0] rd_bus;
    assign {RD_287, RD_286, RD_285, RD_284, RD_283, RD_282, RD_281, RD_280, RD_279, RD_278, RD_277, RD_276, RD_275, RD_274, RD_273, RD_272, RD_271, RD_270, RD_269, RD_268, RD_267, RD_266, RD_265, RD_264, RD_263, RD_262, RD_261, RD_260, RD_259, RD_258, RD_257, RD_256, RD_255, RD_254, RD_253, RD_252, RD_251, RD_250, RD_249, RD_248, RD_247, RD_246, RD_245, RD_244, RD_243, RD_242, RD_241, RD_240, RD_239, RD_238, RD_237, RD_236, RD_235, RD_234, RD_233, RD_232, RD_231, RD_230, RD_229, RD_228, RD_227, RD_226, RD_225, RD_224, RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_288x64_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_287, WD_286, WD_285, WD_284, WD_283, WD_282, WD_281, WD_280, WD_279, WD_278, WD_277, WD_276, WD_275, WD_274, WD_273, WD_272, WD_271, WD_270, WD_269, WD_268, WD_267, WD_266, WD_265, WD_264, WD_263, WD_262, WD_261, WD_260, WD_259, WD_258, WD_257, WD_256, WD_255, WD_254, WD_253, WD_252, WD_251, WD_250, WD_249, WD_248, WD_247, WD_246, WD_245, WD_244, WD_243, WD_242, WD_241, WD_240, WD_239, WD_238, WD_237, WD_236, WD_235, WD_234, WD_233, WD_232, WD_231, WD_230, WD_229, WD_228, WD_227, WD_226, WD_225, WD_224, WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_64X288_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=64  width=64  addr=6b
module RAMPDP_64X64_GL_M1_D2 (
    CLK,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [63:0] rd_bus;
    assign {RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_64x64_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_64X64_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=64  width=66  addr=6b
module RAMPDP_64X66_GL_M1_D2 (
    CLK,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [65:0] rd_bus;
    assign {RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_66x64_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_64X66_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=80  width=16  addr=7b
module RAMPDP_80X16_GL_M2_D2 (
    CLK,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [15:0] rd_bus;
    assign {RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_16x80_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_80X16_GL_M2_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=80  width=226  addr=7b
module RAMPDP_80X226_GL_M1_D2 (
    CLK,
    WD_225,
    WD_224,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_225,
    RD_224,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_225;
    input  WD_224;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_225;
    output RD_224;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [225:0] rd_bus;
    assign {RD_225, RD_224, RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_226x80_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_225, WD_224, WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_80X226_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=80  width=256  addr=7b
module RAMPDP_80X256_GL_M1_D2 (
    CLK,
    WD_255,
    WD_254,
    WD_253,
    WD_252,
    WD_251,
    WD_250,
    WD_249,
    WD_248,
    WD_247,
    WD_246,
    WD_245,
    WD_244,
    WD_243,
    WD_242,
    WD_241,
    WD_240,
    WD_239,
    WD_238,
    WD_237,
    WD_236,
    WD_235,
    WD_234,
    WD_233,
    WD_232,
    WD_231,
    WD_230,
    WD_229,
    WD_228,
    WD_227,
    WD_226,
    WD_225,
    WD_224,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_255,
    RD_254,
    RD_253,
    RD_252,
    RD_251,
    RD_250,
    RD_249,
    RD_248,
    RD_247,
    RD_246,
    RD_245,
    RD_244,
    RD_243,
    RD_242,
    RD_241,
    RD_240,
    RD_239,
    RD_238,
    RD_237,
    RD_236,
    RD_235,
    RD_234,
    RD_233,
    RD_232,
    RD_231,
    RD_230,
    RD_229,
    RD_228,
    RD_227,
    RD_226,
    RD_225,
    RD_224,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_255;
    input  WD_254;
    input  WD_253;
    input  WD_252;
    input  WD_251;
    input  WD_250;
    input  WD_249;
    input  WD_248;
    input  WD_247;
    input  WD_246;
    input  WD_245;
    input  WD_244;
    input  WD_243;
    input  WD_242;
    input  WD_241;
    input  WD_240;
    input  WD_239;
    input  WD_238;
    input  WD_237;
    input  WD_236;
    input  WD_235;
    input  WD_234;
    input  WD_233;
    input  WD_232;
    input  WD_231;
    input  WD_230;
    input  WD_229;
    input  WD_228;
    input  WD_227;
    input  WD_226;
    input  WD_225;
    input  WD_224;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_255;
    output RD_254;
    output RD_253;
    output RD_252;
    output RD_251;
    output RD_250;
    output RD_249;
    output RD_248;
    output RD_247;
    output RD_246;
    output RD_245;
    output RD_244;
    output RD_243;
    output RD_242;
    output RD_241;
    output RD_240;
    output RD_239;
    output RD_238;
    output RD_237;
    output RD_236;
    output RD_235;
    output RD_234;
    output RD_233;
    output RD_232;
    output RD_231;
    output RD_230;
    output RD_229;
    output RD_228;
    output RD_227;
    output RD_226;
    output RD_225;
    output RD_224;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [255:0] rd_bus;
    assign {RD_255, RD_254, RD_253, RD_252, RD_251, RD_250, RD_249, RD_248, RD_247, RD_246, RD_245, RD_244, RD_243, RD_242, RD_241, RD_240, RD_239, RD_238, RD_237, RD_236, RD_235, RD_234, RD_233, RD_232, RD_231, RD_230, RD_229, RD_228, RD_227, RD_226, RD_225, RD_224, RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_256x80_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_255, WD_254, WD_253, WD_252, WD_251, WD_250, WD_249, WD_248, WD_247, WD_246, WD_245, WD_244, WD_243, WD_242, WD_241, WD_240, WD_239, WD_238, WD_237, WD_236, WD_235, WD_234, WD_233, WD_232, WD_231, WD_230, WD_229, WD_228, WD_227, WD_226, WD_225, WD_224, WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_80X256_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=80  width=288  addr=7b
module RAMPDP_80X288_GL_M1_D2 (
    CLK,
    WD_287,
    WD_286,
    WD_285,
    WD_284,
    WD_283,
    WD_282,
    WD_281,
    WD_280,
    WD_279,
    WD_278,
    WD_277,
    WD_276,
    WD_275,
    WD_274,
    WD_273,
    WD_272,
    WD_271,
    WD_270,
    WD_269,
    WD_268,
    WD_267,
    WD_266,
    WD_265,
    WD_264,
    WD_263,
    WD_262,
    WD_261,
    WD_260,
    WD_259,
    WD_258,
    WD_257,
    WD_256,
    WD_255,
    WD_254,
    WD_253,
    WD_252,
    WD_251,
    WD_250,
    WD_249,
    WD_248,
    WD_247,
    WD_246,
    WD_245,
    WD_244,
    WD_243,
    WD_242,
    WD_241,
    WD_240,
    WD_239,
    WD_238,
    WD_237,
    WD_236,
    WD_235,
    WD_234,
    WD_233,
    WD_232,
    WD_231,
    WD_230,
    WD_229,
    WD_228,
    WD_227,
    WD_226,
    WD_225,
    WD_224,
    WD_223,
    WD_222,
    WD_221,
    WD_220,
    WD_219,
    WD_218,
    WD_217,
    WD_216,
    WD_215,
    WD_214,
    WD_213,
    WD_212,
    WD_211,
    WD_210,
    WD_209,
    WD_208,
    WD_207,
    WD_206,
    WD_205,
    WD_204,
    WD_203,
    WD_202,
    WD_201,
    WD_200,
    WD_199,
    WD_198,
    WD_197,
    WD_196,
    WD_195,
    WD_194,
    WD_193,
    WD_192,
    WD_191,
    WD_190,
    WD_189,
    WD_188,
    WD_187,
    WD_186,
    WD_185,
    WD_184,
    WD_183,
    WD_182,
    WD_181,
    WD_180,
    WD_179,
    WD_178,
    WD_177,
    WD_176,
    WD_175,
    WD_174,
    WD_173,
    WD_172,
    WD_171,
    WD_170,
    WD_169,
    WD_168,
    WD_167,
    WD_166,
    WD_165,
    WD_164,
    WD_163,
    WD_162,
    WD_161,
    WD_160,
    WD_159,
    WD_158,
    WD_157,
    WD_156,
    WD_155,
    WD_154,
    WD_153,
    WD_152,
    WD_151,
    WD_150,
    WD_149,
    WD_148,
    WD_147,
    WD_146,
    WD_145,
    WD_144,
    WD_143,
    WD_142,
    WD_141,
    WD_140,
    WD_139,
    WD_138,
    WD_137,
    WD_136,
    WD_135,
    WD_134,
    WD_133,
    WD_132,
    WD_131,
    WD_130,
    WD_129,
    WD_128,
    WD_127,
    WD_126,
    WD_125,
    WD_124,
    WD_123,
    WD_122,
    WD_121,
    WD_120,
    WD_119,
    WD_118,
    WD_117,
    WD_116,
    WD_115,
    WD_114,
    WD_113,
    WD_112,
    WD_111,
    WD_110,
    WD_109,
    WD_108,
    WD_107,
    WD_106,
    WD_105,
    WD_104,
    WD_103,
    WD_102,
    WD_101,
    WD_100,
    WD_99,
    WD_98,
    WD_97,
    WD_96,
    WD_95,
    WD_94,
    WD_93,
    WD_92,
    WD_91,
    WD_90,
    WD_89,
    WD_88,
    WD_87,
    WD_86,
    WD_85,
    WD_84,
    WD_83,
    WD_82,
    WD_81,
    WD_80,
    WD_79,
    WD_78,
    WD_77,
    WD_76,
    WD_75,
    WD_74,
    WD_73,
    WD_72,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_287,
    RD_286,
    RD_285,
    RD_284,
    RD_283,
    RD_282,
    RD_281,
    RD_280,
    RD_279,
    RD_278,
    RD_277,
    RD_276,
    RD_275,
    RD_274,
    RD_273,
    RD_272,
    RD_271,
    RD_270,
    RD_269,
    RD_268,
    RD_267,
    RD_266,
    RD_265,
    RD_264,
    RD_263,
    RD_262,
    RD_261,
    RD_260,
    RD_259,
    RD_258,
    RD_257,
    RD_256,
    RD_255,
    RD_254,
    RD_253,
    RD_252,
    RD_251,
    RD_250,
    RD_249,
    RD_248,
    RD_247,
    RD_246,
    RD_245,
    RD_244,
    RD_243,
    RD_242,
    RD_241,
    RD_240,
    RD_239,
    RD_238,
    RD_237,
    RD_236,
    RD_235,
    RD_234,
    RD_233,
    RD_232,
    RD_231,
    RD_230,
    RD_229,
    RD_228,
    RD_227,
    RD_226,
    RD_225,
    RD_224,
    RD_223,
    RD_222,
    RD_221,
    RD_220,
    RD_219,
    RD_218,
    RD_217,
    RD_216,
    RD_215,
    RD_214,
    RD_213,
    RD_212,
    RD_211,
    RD_210,
    RD_209,
    RD_208,
    RD_207,
    RD_206,
    RD_205,
    RD_204,
    RD_203,
    RD_202,
    RD_201,
    RD_200,
    RD_199,
    RD_198,
    RD_197,
    RD_196,
    RD_195,
    RD_194,
    RD_193,
    RD_192,
    RD_191,
    RD_190,
    RD_189,
    RD_188,
    RD_187,
    RD_186,
    RD_185,
    RD_184,
    RD_183,
    RD_182,
    RD_181,
    RD_180,
    RD_179,
    RD_178,
    RD_177,
    RD_176,
    RD_175,
    RD_174,
    RD_173,
    RD_172,
    RD_171,
    RD_170,
    RD_169,
    RD_168,
    RD_167,
    RD_166,
    RD_165,
    RD_164,
    RD_163,
    RD_162,
    RD_161,
    RD_160,
    RD_159,
    RD_158,
    RD_157,
    RD_156,
    RD_155,
    RD_154,
    RD_153,
    RD_152,
    RD_151,
    RD_150,
    RD_149,
    RD_148,
    RD_147,
    RD_146,
    RD_145,
    RD_144,
    RD_143,
    RD_142,
    RD_141,
    RD_140,
    RD_139,
    RD_138,
    RD_137,
    RD_136,
    RD_135,
    RD_134,
    RD_133,
    RD_132,
    RD_131,
    RD_130,
    RD_129,
    RD_128,
    RD_127,
    RD_126,
    RD_125,
    RD_124,
    RD_123,
    RD_122,
    RD_121,
    RD_120,
    RD_119,
    RD_118,
    RD_117,
    RD_116,
    RD_115,
    RD_114,
    RD_113,
    RD_112,
    RD_111,
    RD_110,
    RD_109,
    RD_108,
    RD_107,
    RD_106,
    RD_105,
    RD_104,
    RD_103,
    RD_102,
    RD_101,
    RD_100,
    RD_99,
    RD_98,
    RD_97,
    RD_96,
    RD_95,
    RD_94,
    RD_93,
    RD_92,
    RD_91,
    RD_90,
    RD_89,
    RD_88,
    RD_87,
    RD_86,
    RD_85,
    RD_84,
    RD_83,
    RD_82,
    RD_81,
    RD_80,
    RD_79,
    RD_78,
    RD_77,
    RD_76,
    RD_75,
    RD_74,
    RD_73,
    RD_72,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_287;
    input  WD_286;
    input  WD_285;
    input  WD_284;
    input  WD_283;
    input  WD_282;
    input  WD_281;
    input  WD_280;
    input  WD_279;
    input  WD_278;
    input  WD_277;
    input  WD_276;
    input  WD_275;
    input  WD_274;
    input  WD_273;
    input  WD_272;
    input  WD_271;
    input  WD_270;
    input  WD_269;
    input  WD_268;
    input  WD_267;
    input  WD_266;
    input  WD_265;
    input  WD_264;
    input  WD_263;
    input  WD_262;
    input  WD_261;
    input  WD_260;
    input  WD_259;
    input  WD_258;
    input  WD_257;
    input  WD_256;
    input  WD_255;
    input  WD_254;
    input  WD_253;
    input  WD_252;
    input  WD_251;
    input  WD_250;
    input  WD_249;
    input  WD_248;
    input  WD_247;
    input  WD_246;
    input  WD_245;
    input  WD_244;
    input  WD_243;
    input  WD_242;
    input  WD_241;
    input  WD_240;
    input  WD_239;
    input  WD_238;
    input  WD_237;
    input  WD_236;
    input  WD_235;
    input  WD_234;
    input  WD_233;
    input  WD_232;
    input  WD_231;
    input  WD_230;
    input  WD_229;
    input  WD_228;
    input  WD_227;
    input  WD_226;
    input  WD_225;
    input  WD_224;
    input  WD_223;
    input  WD_222;
    input  WD_221;
    input  WD_220;
    input  WD_219;
    input  WD_218;
    input  WD_217;
    input  WD_216;
    input  WD_215;
    input  WD_214;
    input  WD_213;
    input  WD_212;
    input  WD_211;
    input  WD_210;
    input  WD_209;
    input  WD_208;
    input  WD_207;
    input  WD_206;
    input  WD_205;
    input  WD_204;
    input  WD_203;
    input  WD_202;
    input  WD_201;
    input  WD_200;
    input  WD_199;
    input  WD_198;
    input  WD_197;
    input  WD_196;
    input  WD_195;
    input  WD_194;
    input  WD_193;
    input  WD_192;
    input  WD_191;
    input  WD_190;
    input  WD_189;
    input  WD_188;
    input  WD_187;
    input  WD_186;
    input  WD_185;
    input  WD_184;
    input  WD_183;
    input  WD_182;
    input  WD_181;
    input  WD_180;
    input  WD_179;
    input  WD_178;
    input  WD_177;
    input  WD_176;
    input  WD_175;
    input  WD_174;
    input  WD_173;
    input  WD_172;
    input  WD_171;
    input  WD_170;
    input  WD_169;
    input  WD_168;
    input  WD_167;
    input  WD_166;
    input  WD_165;
    input  WD_164;
    input  WD_163;
    input  WD_162;
    input  WD_161;
    input  WD_160;
    input  WD_159;
    input  WD_158;
    input  WD_157;
    input  WD_156;
    input  WD_155;
    input  WD_154;
    input  WD_153;
    input  WD_152;
    input  WD_151;
    input  WD_150;
    input  WD_149;
    input  WD_148;
    input  WD_147;
    input  WD_146;
    input  WD_145;
    input  WD_144;
    input  WD_143;
    input  WD_142;
    input  WD_141;
    input  WD_140;
    input  WD_139;
    input  WD_138;
    input  WD_137;
    input  WD_136;
    input  WD_135;
    input  WD_134;
    input  WD_133;
    input  WD_132;
    input  WD_131;
    input  WD_130;
    input  WD_129;
    input  WD_128;
    input  WD_127;
    input  WD_126;
    input  WD_125;
    input  WD_124;
    input  WD_123;
    input  WD_122;
    input  WD_121;
    input  WD_120;
    input  WD_119;
    input  WD_118;
    input  WD_117;
    input  WD_116;
    input  WD_115;
    input  WD_114;
    input  WD_113;
    input  WD_112;
    input  WD_111;
    input  WD_110;
    input  WD_109;
    input  WD_108;
    input  WD_107;
    input  WD_106;
    input  WD_105;
    input  WD_104;
    input  WD_103;
    input  WD_102;
    input  WD_101;
    input  WD_100;
    input  WD_99;
    input  WD_98;
    input  WD_97;
    input  WD_96;
    input  WD_95;
    input  WD_94;
    input  WD_93;
    input  WD_92;
    input  WD_91;
    input  WD_90;
    input  WD_89;
    input  WD_88;
    input  WD_87;
    input  WD_86;
    input  WD_85;
    input  WD_84;
    input  WD_83;
    input  WD_82;
    input  WD_81;
    input  WD_80;
    input  WD_79;
    input  WD_78;
    input  WD_77;
    input  WD_76;
    input  WD_75;
    input  WD_74;
    input  WD_73;
    input  WD_72;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_287;
    output RD_286;
    output RD_285;
    output RD_284;
    output RD_283;
    output RD_282;
    output RD_281;
    output RD_280;
    output RD_279;
    output RD_278;
    output RD_277;
    output RD_276;
    output RD_275;
    output RD_274;
    output RD_273;
    output RD_272;
    output RD_271;
    output RD_270;
    output RD_269;
    output RD_268;
    output RD_267;
    output RD_266;
    output RD_265;
    output RD_264;
    output RD_263;
    output RD_262;
    output RD_261;
    output RD_260;
    output RD_259;
    output RD_258;
    output RD_257;
    output RD_256;
    output RD_255;
    output RD_254;
    output RD_253;
    output RD_252;
    output RD_251;
    output RD_250;
    output RD_249;
    output RD_248;
    output RD_247;
    output RD_246;
    output RD_245;
    output RD_244;
    output RD_243;
    output RD_242;
    output RD_241;
    output RD_240;
    output RD_239;
    output RD_238;
    output RD_237;
    output RD_236;
    output RD_235;
    output RD_234;
    output RD_233;
    output RD_232;
    output RD_231;
    output RD_230;
    output RD_229;
    output RD_228;
    output RD_227;
    output RD_226;
    output RD_225;
    output RD_224;
    output RD_223;
    output RD_222;
    output RD_221;
    output RD_220;
    output RD_219;
    output RD_218;
    output RD_217;
    output RD_216;
    output RD_215;
    output RD_214;
    output RD_213;
    output RD_212;
    output RD_211;
    output RD_210;
    output RD_209;
    output RD_208;
    output RD_207;
    output RD_206;
    output RD_205;
    output RD_204;
    output RD_203;
    output RD_202;
    output RD_201;
    output RD_200;
    output RD_199;
    output RD_198;
    output RD_197;
    output RD_196;
    output RD_195;
    output RD_194;
    output RD_193;
    output RD_192;
    output RD_191;
    output RD_190;
    output RD_189;
    output RD_188;
    output RD_187;
    output RD_186;
    output RD_185;
    output RD_184;
    output RD_183;
    output RD_182;
    output RD_181;
    output RD_180;
    output RD_179;
    output RD_178;
    output RD_177;
    output RD_176;
    output RD_175;
    output RD_174;
    output RD_173;
    output RD_172;
    output RD_171;
    output RD_170;
    output RD_169;
    output RD_168;
    output RD_167;
    output RD_166;
    output RD_165;
    output RD_164;
    output RD_163;
    output RD_162;
    output RD_161;
    output RD_160;
    output RD_159;
    output RD_158;
    output RD_157;
    output RD_156;
    output RD_155;
    output RD_154;
    output RD_153;
    output RD_152;
    output RD_151;
    output RD_150;
    output RD_149;
    output RD_148;
    output RD_147;
    output RD_146;
    output RD_145;
    output RD_144;
    output RD_143;
    output RD_142;
    output RD_141;
    output RD_140;
    output RD_139;
    output RD_138;
    output RD_137;
    output RD_136;
    output RD_135;
    output RD_134;
    output RD_133;
    output RD_132;
    output RD_131;
    output RD_130;
    output RD_129;
    output RD_128;
    output RD_127;
    output RD_126;
    output RD_125;
    output RD_124;
    output RD_123;
    output RD_122;
    output RD_121;
    output RD_120;
    output RD_119;
    output RD_118;
    output RD_117;
    output RD_116;
    output RD_115;
    output RD_114;
    output RD_113;
    output RD_112;
    output RD_111;
    output RD_110;
    output RD_109;
    output RD_108;
    output RD_107;
    output RD_106;
    output RD_105;
    output RD_104;
    output RD_103;
    output RD_102;
    output RD_101;
    output RD_100;
    output RD_99;
    output RD_98;
    output RD_97;
    output RD_96;
    output RD_95;
    output RD_94;
    output RD_93;
    output RD_92;
    output RD_91;
    output RD_90;
    output RD_89;
    output RD_88;
    output RD_87;
    output RD_86;
    output RD_85;
    output RD_84;
    output RD_83;
    output RD_82;
    output RD_81;
    output RD_80;
    output RD_79;
    output RD_78;
    output RD_77;
    output RD_76;
    output RD_75;
    output RD_74;
    output RD_73;
    output RD_72;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [287:0] rd_bus;
    assign {RD_287, RD_286, RD_285, RD_284, RD_283, RD_282, RD_281, RD_280, RD_279, RD_278, RD_277, RD_276, RD_275, RD_274, RD_273, RD_272, RD_271, RD_270, RD_269, RD_268, RD_267, RD_266, RD_265, RD_264, RD_263, RD_262, RD_261, RD_260, RD_259, RD_258, RD_257, RD_256, RD_255, RD_254, RD_253, RD_252, RD_251, RD_250, RD_249, RD_248, RD_247, RD_246, RD_245, RD_244, RD_243, RD_242, RD_241, RD_240, RD_239, RD_238, RD_237, RD_236, RD_235, RD_234, RD_233, RD_232, RD_231, RD_230, RD_229, RD_228, RD_227, RD_226, RD_225, RD_224, RD_223, RD_222, RD_221, RD_220, RD_219, RD_218, RD_217, RD_216, RD_215, RD_214, RD_213, RD_212, RD_211, RD_210, RD_209, RD_208, RD_207, RD_206, RD_205, RD_204, RD_203, RD_202, RD_201, RD_200, RD_199, RD_198, RD_197, RD_196, RD_195, RD_194, RD_193, RD_192, RD_191, RD_190, RD_189, RD_188, RD_187, RD_186, RD_185, RD_184, RD_183, RD_182, RD_181, RD_180, RD_179, RD_178, RD_177, RD_176, RD_175, RD_174, RD_173, RD_172, RD_171, RD_170, RD_169, RD_168, RD_167, RD_166, RD_165, RD_164, RD_163, RD_162, RD_161, RD_160, RD_159, RD_158, RD_157, RD_156, RD_155, RD_154, RD_153, RD_152, RD_151, RD_150, RD_149, RD_148, RD_147, RD_146, RD_145, RD_144, RD_143, RD_142, RD_141, RD_140, RD_139, RD_138, RD_137, RD_136, RD_135, RD_134, RD_133, RD_132, RD_131, RD_130, RD_129, RD_128, RD_127, RD_126, RD_125, RD_124, RD_123, RD_122, RD_121, RD_120, RD_119, RD_118, RD_117, RD_116, RD_115, RD_114, RD_113, RD_112, RD_111, RD_110, RD_109, RD_108, RD_107, RD_106, RD_105, RD_104, RD_103, RD_102, RD_101, RD_100, RD_99, RD_98, RD_97, RD_96, RD_95, RD_94, RD_93, RD_92, RD_91, RD_90, RD_89, RD_88, RD_87, RD_86, RD_85, RD_84, RD_83, RD_82, RD_81, RD_80, RD_79, RD_78, RD_77, RD_76, RD_75, RD_74, RD_73, RD_72, RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_288x80_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_287, WD_286, WD_285, WD_284, WD_283, WD_282, WD_281, WD_280, WD_279, WD_278, WD_277, WD_276, WD_275, WD_274, WD_273, WD_272, WD_271, WD_270, WD_269, WD_268, WD_267, WD_266, WD_265, WD_264, WD_263, WD_262, WD_261, WD_260, WD_259, WD_258, WD_257, WD_256, WD_255, WD_254, WD_253, WD_252, WD_251, WD_250, WD_249, WD_248, WD_247, WD_246, WD_245, WD_244, WD_243, WD_242, WD_241, WD_240, WD_239, WD_238, WD_237, WD_236, WD_235, WD_234, WD_233, WD_232, WD_231, WD_230, WD_229, WD_228, WD_227, WD_226, WD_225, WD_224, WD_223, WD_222, WD_221, WD_220, WD_219, WD_218, WD_217, WD_216, WD_215, WD_214, WD_213, WD_212, WD_211, WD_210, WD_209, WD_208, WD_207, WD_206, WD_205, WD_204, WD_203, WD_202, WD_201, WD_200, WD_199, WD_198, WD_197, WD_196, WD_195, WD_194, WD_193, WD_192, WD_191, WD_190, WD_189, WD_188, WD_187, WD_186, WD_185, WD_184, WD_183, WD_182, WD_181, WD_180, WD_179, WD_178, WD_177, WD_176, WD_175, WD_174, WD_173, WD_172, WD_171, WD_170, WD_169, WD_168, WD_167, WD_166, WD_165, WD_164, WD_163, WD_162, WD_161, WD_160, WD_159, WD_158, WD_157, WD_156, WD_155, WD_154, WD_153, WD_152, WD_151, WD_150, WD_149, WD_148, WD_147, WD_146, WD_145, WD_144, WD_143, WD_142, WD_141, WD_140, WD_139, WD_138, WD_137, WD_136, WD_135, WD_134, WD_133, WD_132, WD_131, WD_130, WD_129, WD_128, WD_127, WD_126, WD_125, WD_124, WD_123, WD_122, WD_121, WD_120, WD_119, WD_118, WD_117, WD_116, WD_115, WD_114, WD_113, WD_112, WD_111, WD_110, WD_109, WD_108, WD_107, WD_106, WD_105, WD_104, WD_103, WD_102, WD_101, WD_100, WD_99, WD_98, WD_97, WD_96, WD_95, WD_94, WD_93, WD_92, WD_91, WD_90, WD_89, WD_88, WD_87, WD_86, WD_85, WD_84, WD_83, WD_82, WD_81, WD_80, WD_79, WD_78, WD_77, WD_76, WD_75, WD_74, WD_73, WD_72, WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_80X288_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=80  width=66  addr=7b
module RAMPDP_80X66_GL_M1_D2 (
    CLK,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [65:0] rd_bus;
    assign {RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_66x80_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_80X66_GL_M1_D2

// RAMPDP single-clock pseudo-dual-port 1R1W (CLK)  |  depth=80  width=72  addr=7b
module RAMPDP_80X72_GL_M1_D2 (
    CLK,
    WD_71,
    WD_70,
    WD_69,
    WD_68,
    WD_67,
    WD_66,
    WD_65,
    WD_64,
    WD_63,
    WD_62,
    WD_61,
    WD_60,
    WD_59,
    WD_58,
    WD_57,
    WD_56,
    WD_55,
    WD_54,
    WD_53,
    WD_52,
    WD_51,
    WD_50,
    WD_49,
    WD_48,
    WD_47,
    WD_46,
    WD_45,
    WD_44,
    WD_43,
    WD_42,
    WD_41,
    WD_40,
    WD_39,
    WD_38,
    WD_37,
    WD_36,
    WD_35,
    WD_34,
    WD_33,
    WD_32,
    WD_31,
    WD_30,
    WD_29,
    WD_28,
    WD_27,
    WD_26,
    WD_25,
    WD_24,
    WD_23,
    WD_22,
    WD_21,
    WD_20,
    WD_19,
    WD_18,
    WD_17,
    WD_16,
    WD_15,
    WD_14,
    WD_13,
    WD_12,
    WD_11,
    WD_10,
    WD_9,
    WD_8,
    WD_7,
    WD_6,
    WD_5,
    WD_4,
    WD_3,
    WD_2,
    WD_1,
    WD_0,
    RE,
    WE,
    RADR_6,
    RADR_5,
    RADR_4,
    RADR_3,
    RADR_2,
    RADR_1,
    RADR_0,
    WADR_6,
    WADR_5,
    WADR_4,
    WADR_3,
    WADR_2,
    WADR_1,
    WADR_0,
    IDDQ,
    SVOP_0,
    SVOP_1,
    SVOP_2,
    SVOP_3,
    SVOP_4,
    SVOP_5,
    SVOP_6,
    SVOP_7,
    SLEEP_EN_0,
    SLEEP_EN_1,
    SLEEP_EN_2,
    SLEEP_EN_3,
    SLEEP_EN_4,
    SLEEP_EN_5,
    SLEEP_EN_6,
    SLEEP_EN_7,
    RET_EN,
    RD_71,
    RD_70,
    RD_69,
    RD_68,
    RD_67,
    RD_66,
    RD_65,
    RD_64,
    RD_63,
    RD_62,
    RD_61,
    RD_60,
    RD_59,
    RD_58,
    RD_57,
    RD_56,
    RD_55,
    RD_54,
    RD_53,
    RD_52,
    RD_51,
    RD_50,
    RD_49,
    RD_48,
    RD_47,
    RD_46,
    RD_45,
    RD_44,
    RD_43,
    RD_42,
    RD_41,
    RD_40,
    RD_39,
    RD_38,
    RD_37,
    RD_36,
    RD_35,
    RD_34,
    RD_33,
    RD_32,
    RD_31,
    RD_30,
    RD_29,
    RD_28,
    RD_27,
    RD_26,
    RD_25,
    RD_24,
    RD_23,
    RD_22,
    RD_21,
    RD_20,
    RD_19,
    RD_18,
    RD_17,
    RD_16,
    RD_15,
    RD_14,
    RD_13,
    RD_12,
    RD_11,
    RD_10,
    RD_9,
    RD_8,
    RD_7,
    RD_6,
    RD_5,
    RD_4,
    RD_3,
    RD_2,
    RD_1,
    RD_0
);
    input  CLK;
    input  WD_71;
    input  WD_70;
    input  WD_69;
    input  WD_68;
    input  WD_67;
    input  WD_66;
    input  WD_65;
    input  WD_64;
    input  WD_63;
    input  WD_62;
    input  WD_61;
    input  WD_60;
    input  WD_59;
    input  WD_58;
    input  WD_57;
    input  WD_56;
    input  WD_55;
    input  WD_54;
    input  WD_53;
    input  WD_52;
    input  WD_51;
    input  WD_50;
    input  WD_49;
    input  WD_48;
    input  WD_47;
    input  WD_46;
    input  WD_45;
    input  WD_44;
    input  WD_43;
    input  WD_42;
    input  WD_41;
    input  WD_40;
    input  WD_39;
    input  WD_38;
    input  WD_37;
    input  WD_36;
    input  WD_35;
    input  WD_34;
    input  WD_33;
    input  WD_32;
    input  WD_31;
    input  WD_30;
    input  WD_29;
    input  WD_28;
    input  WD_27;
    input  WD_26;
    input  WD_25;
    input  WD_24;
    input  WD_23;
    input  WD_22;
    input  WD_21;
    input  WD_20;
    input  WD_19;
    input  WD_18;
    input  WD_17;
    input  WD_16;
    input  WD_15;
    input  WD_14;
    input  WD_13;
    input  WD_12;
    input  WD_11;
    input  WD_10;
    input  WD_9;
    input  WD_8;
    input  WD_7;
    input  WD_6;
    input  WD_5;
    input  WD_4;
    input  WD_3;
    input  WD_2;
    input  WD_1;
    input  WD_0;
    input  RE;
    input  WE;
    input  RADR_6;
    input  RADR_5;
    input  RADR_4;
    input  RADR_3;
    input  RADR_2;
    input  RADR_1;
    input  RADR_0;
    input  WADR_6;
    input  WADR_5;
    input  WADR_4;
    input  WADR_3;
    input  WADR_2;
    input  WADR_1;
    input  WADR_0;
    input  IDDQ;
    input  SVOP_0;
    input  SVOP_1;
    input  SVOP_2;
    input  SVOP_3;
    input  SVOP_4;
    input  SVOP_5;
    input  SVOP_6;
    input  SVOP_7;
    input  SLEEP_EN_0;
    input  SLEEP_EN_1;
    input  SLEEP_EN_2;
    input  SLEEP_EN_3;
    input  SLEEP_EN_4;
    input  SLEEP_EN_5;
    input  SLEEP_EN_6;
    input  SLEEP_EN_7;
    input  RET_EN;
    output RD_71;
    output RD_70;
    output RD_69;
    output RD_68;
    output RD_67;
    output RD_66;
    output RD_65;
    output RD_64;
    output RD_63;
    output RD_62;
    output RD_61;
    output RD_60;
    output RD_59;
    output RD_58;
    output RD_57;
    output RD_56;
    output RD_55;
    output RD_54;
    output RD_53;
    output RD_52;
    output RD_51;
    output RD_50;
    output RD_49;
    output RD_48;
    output RD_47;
    output RD_46;
    output RD_45;
    output RD_44;
    output RD_43;
    output RD_42;
    output RD_41;
    output RD_40;
    output RD_39;
    output RD_38;
    output RD_37;
    output RD_36;
    output RD_35;
    output RD_34;
    output RD_33;
    output RD_32;
    output RD_31;
    output RD_30;
    output RD_29;
    output RD_28;
    output RD_27;
    output RD_26;
    output RD_25;
    output RD_24;
    output RD_23;
    output RD_22;
    output RD_21;
    output RD_20;
    output RD_19;
    output RD_18;
    output RD_17;
    output RD_16;
    output RD_15;
    output RD_14;
    output RD_13;
    output RD_12;
    output RD_11;
    output RD_10;
    output RD_9;
    output RD_8;
    output RD_7;
    output RD_6;
    output RD_5;
    output RD_4;
    output RD_3;
    output RD_2;
    output RD_1;
    output RD_0;

    // Internal read-data bus
    wire [71:0] rd_bus;
    assign {RD_71, RD_70, RD_69, RD_68, RD_67, RD_66, RD_65, RD_64, RD_63, RD_62, RD_61, RD_60, RD_59, RD_58, RD_57, RD_56, RD_55, RD_54, RD_53, RD_52, RD_51, RD_50, RD_49, RD_48, RD_47, RD_46, RD_45, RD_44, RD_43, RD_42, RD_41, RD_40, RD_39, RD_38, RD_37, RD_36, RD_35, RD_34, RD_33, RD_32, RD_31, RD_30, RD_29, RD_28, RD_27, RD_26, RD_25, RD_24, RD_23, RD_22, RD_21, RD_20, RD_19, RD_18, RD_17, RD_16, RD_15, RD_14, RD_13, RD_12, RD_11, RD_10, RD_9, RD_8, RD_7, RD_6, RD_5, RD_4, RD_3, RD_2, RD_1, RD_0} = rd_bus;

    // NC (no fakeram equivalent — declared for compatibility, tied off):
    // IDDQ, SVOP_0, SVOP_1, SVOP_2, SVOP_3, SVOP_4, SVOP_5, SVOP_6, SVOP_7, SLEEP_EN_0, SLEEP_EN_1, SLEEP_EN_2, SLEEP_EN_3, SLEEP_EN_4, SLEEP_EN_5, SLEEP_EN_6, SLEEP_EN_7, RET_EN

    fakeram_72x80_1r1w sram (
        .r0_clk     (CLK),
        .w0_clk     (CLK),
        .r0_ce_in   (RE),
        .w0_ce_in   (1'b1),
        .w0_we_in   (WE),
        .r0_addr_in ({RADR_6, RADR_5, RADR_4, RADR_3, RADR_2, RADR_1, RADR_0}),
        .w0_addr_in ({WADR_6, WADR_5, WADR_4, WADR_3, WADR_2, WADR_1, WADR_0}),
        .w0_wd_in   ({WD_71, WD_70, WD_69, WD_68, WD_67, WD_66, WD_65, WD_64, WD_63, WD_62, WD_61, WD_60, WD_59, WD_58, WD_57, WD_56, WD_55, WD_54, WD_53, WD_52, WD_51, WD_50, WD_49, WD_48, WD_47, WD_46, WD_45, WD_44, WD_43, WD_42, WD_41, WD_40, WD_39, WD_38, WD_37, WD_36, WD_35, WD_34, WD_33, WD_32, WD_31, WD_30, WD_29, WD_28, WD_27, WD_26, WD_25, WD_24, WD_23, WD_22, WD_21, WD_20, WD_19, WD_18, WD_17, WD_16, WD_15, WD_14, WD_13, WD_12, WD_11, WD_10, WD_9, WD_8, WD_7, WD_6, WD_5, WD_4, WD_3, WD_2, WD_1, WD_0}),
        .r0_rd_out  (rd_bus)
    );

endmodule // RAMPDP_80X72_GL_M1_D2