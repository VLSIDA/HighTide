# floonoc-asap7 mesh-tiled floorplan: 4x4 tiles of 715.8 um in mesh order
# (gen_x = column from west, gen_y = row from south); each cluster's
# memory centered in its own tile so router/NI logic sits beside it.
# R0 only (R90 strands asap7 fakeram pins). Die kept at the RTLMP
# util-driven size for a clean comparison.
place_macro -macro_name {gen_x\[0\].gen_y\[0\].i_cluster.u_cluster_mem} -location {81.3780 184.9500} -orientation R0
place_macro -macro_name {gen_x\[0\].gen_y\[1\].i_cluster.u_cluster_mem} -location {81.3780 900.9900} -orientation R0
place_macro -macro_name {gen_x\[0\].gen_y\[2\].i_cluster.u_cluster_mem} -location {81.3780 1616.7600} -orientation R0
place_macro -macro_name {gen_x\[0\].gen_y\[3\].i_cluster.u_cluster_mem} -location {81.3780 2332.5300} -orientation R0
place_macro -macro_name {gen_x\[1\].gen_y\[0\].i_cluster.u_cluster_mem} -location {797.2020 184.9500} -orientation R0
place_macro -macro_name {gen_x\[1\].gen_y\[1\].i_cluster.u_cluster_mem} -location {797.2020 900.9900} -orientation R0
place_macro -macro_name {gen_x\[1\].gen_y\[2\].i_cluster.u_cluster_mem} -location {797.2020 1616.7600} -orientation R0
place_macro -macro_name {gen_x\[1\].gen_y\[3\].i_cluster.u_cluster_mem} -location {797.2020 2332.5300} -orientation R0
place_macro -macro_name {gen_x\[2\].gen_y\[0\].i_cluster.u_cluster_mem} -location {1513.0260 184.9500} -orientation R0
place_macro -macro_name {gen_x\[2\].gen_y\[1\].i_cluster.u_cluster_mem} -location {1513.0260 900.9900} -orientation R0
place_macro -macro_name {gen_x\[2\].gen_y\[2\].i_cluster.u_cluster_mem} -location {1513.0260 1616.7600} -orientation R0
place_macro -macro_name {gen_x\[2\].gen_y\[3\].i_cluster.u_cluster_mem} -location {1513.0260 2332.5300} -orientation R0
place_macro -macro_name {gen_x\[3\].gen_y\[0\].i_cluster.u_cluster_mem} -location {2228.9040 184.9500} -orientation R0
place_macro -macro_name {gen_x\[3\].gen_y\[1\].i_cluster.u_cluster_mem} -location {2228.9040 900.9900} -orientation R0
place_macro -macro_name {gen_x\[3\].gen_y\[2\].i_cluster.u_cluster_mem} -location {2228.9040 1616.7600} -orientation R0
place_macro -macro_name {gen_x\[3\].gen_y\[3\].i_cluster.u_cluster_mem} -location {2228.9040 2332.5300} -orientation R0
