# ternip-sky130hd manual floorplan (2026-11-24). RTLMP at util 65 packed
# the 9 fakeram_512x128 with 20 um gaps (sky130 fakeram pins sit on all four
# edges: N 67, S 128, W 37, E 36) and split the vector register banks
# across the die -> GRT-0116 on met1/met2. Here: banks 0-3 in a top row (R0)
# and 4-7 in a bottom row (MX) with their 128-pin S edges facing the
# middle band that holds the read mux; 200 um channels, 100 um outer
# margins for the N pins, export buffer 5th in the top row (same area as
# the util-65 die, made wider so no S edges face each other),
# A 30 um keep-out ring per macro comes from tapcell.tcl's halo (rows cut).
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[0\].sram} -location {87.860 2268.480} -orientation R0
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[1\].sram} -location {972.440 2268.480} -orientation R0
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[2\].sram} -location {1857.480 2268.480} -orientation R0
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[3\].sram} -location {2742.520 2268.480} -orientation R0
place_macro -macro_name {tmatmul.exportvector.gen_sram.sram} -location {3627.560 2268.480} -orientation R0
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[4\].sram} -location {87.860 100.640} -orientation MX
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[5\].sram} -location {972.440 100.640} -orientation MX
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[6\].sram} -location {1857.480 100.640} -orientation MX
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[7\].sram} -location {2742.520 100.640} -orientation MX

