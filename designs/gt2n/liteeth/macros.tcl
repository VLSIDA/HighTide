# Manual macro placement for liteeth-gt2n (5 macros).
# RTLMP MPL-0045s on this netlist at any tree depth: ~2k um2 of 2nm std cells
# against 54k um2 of macro leaves no balanced clustering. Two 199.5x124.7
# 64w1024d macros across the bottom, three 49.9x31.2 64w64d in the top band
# with the std cells to their right. 10 um die margins, 15 um channels.
# Die 434x210 (shrunk from the first-close 450x310; see BUILD.bazel).
place_macro -macro_name u_storage_64w1024d_5 -location {10 10} -orientation R0
place_macro -macro_name u_storage_64w1024d_6 -location {224.5 10} -orientation R0
place_macro -macro_name u_storage_64w64d_0 -location {10 150} -orientation R0
place_macro -macro_name u_storage_64w64d_1 -location {75 150} -orientation R0
place_macro -macro_name u_storage_64w64d_3 -location {140 150} -orientation R0
