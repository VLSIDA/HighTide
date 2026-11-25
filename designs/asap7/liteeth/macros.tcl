# liteeth-asap7 manual floorplan (2026-11-24), adapted from the bt-study-fp
# sweep agent's layout: the two 64w1024d FIFOs stacked with a 70 um logic band
# between, each facing its north edge (clk/ce/we + 63 rd_out) into the band
# (bottom R0, top MX); the three 64w64d FIFOs in a row at the left of the band.
# Side margins widened 6.5 -> 10 um: the address pins (where the asap7
# critical path ends) are on the W/E edges. Die 254.988 x 376.92 um.
place_macro -macro_name u_storage_64w1024d_5 -location {9.990 6.480} -orientation R0
place_macro -macro_name u_storage_64w1024d_6 -location {9.990 223.560} -orientation MX
place_macro -macro_name u_storage_64w64d_0 -location {16.470 170.100} -orientation R0
place_macro -macro_name u_storage_64w64d_1 -location {81.216 170.100} -orientation R0
place_macro -macro_name u_storage_64w64d_3 -location {145.962 170.100} -orientation R0
