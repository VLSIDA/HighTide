# liteeth-sky130hd manual floorplan (2026-11-24). RTLMP at util 45 left 54% of
# the core empty, stacked the CDC FIFOs down one edge and squeezed the logic
# into a strip. Here: the two 64w1024d buffers along the bottom (MX, 96-pin S
# edges facing up), the three 64w64d FIFOs centered along the top (R0, S edges
# facing down), logic in the band between; 150 um channels, 100 um outer
# margins, 30 um row-cut halo via tapcell.tcl. Die 2678.52 x 2935.94 um at util 0.65.
place_macro -macro_name {u_storage_64w1024d_5} -location {99.820 100.640} -orientation MX
place_macro -macro_name {u_storage_64w1024d_6} -location {1414.040 100.640} -orientation MX
place_macro -macro_name {u_storage_64w64d_1} -location {752.560 2360.960} -orientation R0
place_macro -macro_name {u_storage_64w64d_3} -location {1193.700 2360.960} -orientation R0
place_macro -macro_name {u_storage_64w64d_0} -location {1634.840 2360.960} -orientation R0
