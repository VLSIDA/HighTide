# Manual macro placement for liteeth-gt2n (5 macros).
# RTLMP MPL-0045s on this netlist at any tree depth: ~2k um2 of 2nm std cells
# against 54k um2 of macro leaves no balanced clustering. Two 199.5x124.7
# 64w1024d macros across the bottom, three 49.9x31.2 64w64d above them,
# std cells keep the top of the core. 15-20 um channels between macros.
place_macro -macro_name u_storage_64w1024d_5 -location {15 15} -orientation R0
place_macro -macro_name u_storage_64w1024d_6 -location {235 15} -orientation R0
place_macro -macro_name u_storage_64w64d_0 -location {15 160} -orientation R0
place_macro -macro_name u_storage_64w64d_1 -location {85 160} -orientation R0
place_macro -macro_name u_storage_64w64d_3 -location {155 160} -orientation R0
