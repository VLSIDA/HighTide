# ternip-gt2n manual floorplan (2026-11-24). At util 80 the 9 fakeram_512x128
# are 63% of the core and RTLMP fails MPL-0003; at util 60 it scatters the
# vector-register banks. Here: banks 0-3 + export buffer in a top row (R0),
# banks 4-7 in a bottom row (MX), all 128-pin S edges facing the middle band
# that holds the bank read mux. Die = the util-80 area (124118 um2), 630.95 x
# 196.717 um; 8 um channels, 5 um outer margins.
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[0\].sram} -location {6.006 118.224} -orientation R0
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[1\].sram} -location {131.376 118.224} -orientation R0
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[2\].sram} -location {256.788 118.224} -orientation R0
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[3\].sram} -location {382.158 118.224} -orientation R0
place_macro -macro_name {tmatmul.exportvector.gen_sram.sram} -location {507.570 118.224} -orientation R0
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[4\].sram} -location {6.006 5.040} -orientation MX
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[5\].sram} -location {131.376 5.040} -orientation MX
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[6\].sram} -location {256.788 5.040} -orientation MX
place_macro -macro_name {vector_registers.pipelined_mem.gen_sram.gen_bank\[7\].sram} -location {382.158 5.040} -orientation MX
