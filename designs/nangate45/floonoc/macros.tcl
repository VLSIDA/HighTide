# floonoc-nangate45 mesh-tiled floorplan: 4x4 tiles of 1654.6 um in mesh order
# (gen_x = column from west, gen_y = row from south); each cluster's
# memory centered in its own tile so router/NI logic sits beside it.
# R0 only (R90 strands asap7 fakeram pins). Die kept at the RTLMP
# util-driven size for a clean comparison.
place_macro -macro_name {gen_x\[0\].gen_y\[0\].i_cluster.u_cluster_mem} -location {96.5200 508.2000} -orientation R0
place_macro -macro_name {gen_x\[0\].gen_y\[1\].i_cluster.u_cluster_mem} -location {96.5200 2163.0000} -orientation R0
place_macro -macro_name {gen_x\[0\].gen_y\[2\].i_cluster.u_cluster_mem} -location {96.5200 3817.8000} -orientation R0
place_macro -macro_name {gen_x\[0\].gen_y\[3\].i_cluster.u_cluster_mem} -location {96.5200 5472.6000} -orientation R0
place_macro -macro_name {gen_x\[1\].gen_y\[0\].i_cluster.u_cluster_mem} -location {1751.2300 508.2000} -orientation R0
place_macro -macro_name {gen_x\[1\].gen_y\[1\].i_cluster.u_cluster_mem} -location {1751.2300 2163.0000} -orientation R0
place_macro -macro_name {gen_x\[1\].gen_y\[2\].i_cluster.u_cluster_mem} -location {1751.2300 3817.8000} -orientation R0
place_macro -macro_name {gen_x\[1\].gen_y\[3\].i_cluster.u_cluster_mem} -location {1751.2300 5472.6000} -orientation R0
place_macro -macro_name {gen_x\[2\].gen_y\[0\].i_cluster.u_cluster_mem} -location {3405.7500 508.2000} -orientation R0
place_macro -macro_name {gen_x\[2\].gen_y\[1\].i_cluster.u_cluster_mem} -location {3405.7500 2163.0000} -orientation R0
place_macro -macro_name {gen_x\[2\].gen_y\[2\].i_cluster.u_cluster_mem} -location {3405.7500 3817.8000} -orientation R0
place_macro -macro_name {gen_x\[2\].gen_y\[3\].i_cluster.u_cluster_mem} -location {3405.7500 5472.6000} -orientation R0
place_macro -macro_name {gen_x\[3\].gen_y\[0\].i_cluster.u_cluster_mem} -location {5060.4600 508.2000} -orientation R0
place_macro -macro_name {gen_x\[3\].gen_y\[1\].i_cluster.u_cluster_mem} -location {5060.4600 2163.0000} -orientation R0
place_macro -macro_name {gen_x\[3\].gen_y\[2\].i_cluster.u_cluster_mem} -location {5060.4600 3817.8000} -orientation R0
place_macro -macro_name {gen_x\[3\].gen_y\[3\].i_cluster.u_cluster_mem} -location {5060.4600 5472.6000} -orientation R0
