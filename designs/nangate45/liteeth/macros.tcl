# liteeth-nangate45 manual floorplan (2026-11-24): the two 64w1024d buffers along
# the bottom (MX, 95/96-pin S edges facing up), the three 64w64d FIFOs centered
# along the top (R0, S edges down), logic in the band between, as on sky130hd.
# 40 um channels, 20 um outer margins. Die 624.920 x 757.248 um at util 0.70.
place_macro -macro_name {u_storage_64w1024d_5} -location {19.950 19.600} -orientation MX
place_macro -macro_name {u_storage_64w1024d_6} -location {332.500 19.600} -orientation MX
place_macro -macro_name {u_storage_64w64d_1} -location {157.890 582.400} -orientation R0
place_macro -macro_name {u_storage_64w64d_3} -location {274.360 582.400} -orientation R0
place_macro -macro_name {u_storage_64w64d_0} -location {390.640 582.400} -orientation R0
