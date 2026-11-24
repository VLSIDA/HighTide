# floonoc-gt2n mesh-tiled floorplan: 4x4 tiles in mesh order (gen_x = column
# from west, gen_y = row from south), each cluster memory centered in its own
# tile beside its router, as on asap7/nangate45. R0 only. Die = util-40 size
# of the restored netlist (2.28 mm2 cell area): 2388.246 x 2388.24 um.
place_macro -macro_name {gen_x\[0\].gen_y\[0\].i_cluster.u_cluster_mem} -location {63.756 151.920} -orientation R0
place_macro -macro_name {gen_x\[0\].gen_y\[1\].i_cluster.u_cluster_mem} -location {63.756 748.944} -orientation R0
place_macro -macro_name {gen_x\[0\].gen_y\[2\].i_cluster.u_cluster_mem} -location {63.756 1345.968} -orientation R0
place_macro -macro_name {gen_x\[0\].gen_y\[3\].i_cluster.u_cluster_mem} -location {63.756 1942.992} -orientation R0
place_macro -macro_name {gen_x\[1\].gen_y\[0\].i_cluster.u_cluster_mem} -location {660.828 151.920} -orientation R0
place_macro -macro_name {gen_x\[1\].gen_y\[1\].i_cluster.u_cluster_mem} -location {660.828 748.944} -orientation R0
place_macro -macro_name {gen_x\[1\].gen_y\[2\].i_cluster.u_cluster_mem} -location {660.828 1345.968} -orientation R0
place_macro -macro_name {gen_x\[1\].gen_y\[3\].i_cluster.u_cluster_mem} -location {660.828 1942.992} -orientation R0
place_macro -macro_name {gen_x\[2\].gen_y\[0\].i_cluster.u_cluster_mem} -location {1257.900 151.920} -orientation R0
place_macro -macro_name {gen_x\[2\].gen_y\[1\].i_cluster.u_cluster_mem} -location {1257.900 748.944} -orientation R0
place_macro -macro_name {gen_x\[2\].gen_y\[2\].i_cluster.u_cluster_mem} -location {1257.900 1345.968} -orientation R0
place_macro -macro_name {gen_x\[2\].gen_y\[3\].i_cluster.u_cluster_mem} -location {1257.900 1942.992} -orientation R0
place_macro -macro_name {gen_x\[3\].gen_y\[0\].i_cluster.u_cluster_mem} -location {1854.972 151.920} -orientation R0
place_macro -macro_name {gen_x\[3\].gen_y\[1\].i_cluster.u_cluster_mem} -location {1854.972 748.944} -orientation R0
place_macro -macro_name {gen_x\[3\].gen_y\[2\].i_cluster.u_cluster_mem} -location {1854.972 1345.968} -orientation R0
place_macro -macro_name {gen_x\[3\].gen_y\[3\].i_cluster.u_cluster_mem} -location {1854.972 1942.992} -orientation R0
