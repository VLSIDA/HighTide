# Manual macro grid: 8 columns x 8 rows populated (64 SRAM bank macros +
# 1 aside FIFO). Nominal columns (3-6) occupy rows 1-4,7-10; shifted
# columns (1,2,7,8) occupy rows 2-9 -- this leaves an open rectangular
# gap spanning the middle 4 columns x rows 5-6.
#
# Column gaps: 1,3,4,5,7 = 10um; 2,6 = 28um. Row gaps: 1,3,4,5,6,7,9 =
# 10um; 2,8 = 28um. Die/core area sized to match (CORE_AREA/DIE_AREA in
# BUILD.bazel).
#
# CDMA_IMG FIFO aside macro sits inside column gap 2, centered
# vertically in the empty rows5-6 gap of the nominal columns.
#
# Orientation alternates MX/R0 by row (top-down).
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank0_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {11.008 582.048} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank0_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {111.98 582.048} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank1_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {230.952 648.928} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank1_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {331.924 648.928} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank2_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {432.896 648.928} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank2_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {533.868 648.928} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank3_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {652.84 582.048} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank3_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {753.812 582.048} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank4_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {11.008 497.168} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank4_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {111.98 497.168} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank5_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {230.952 582.048} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank5_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {331.924 582.048} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank6_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {432.896 582.048} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank6_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {533.868 582.048} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank7_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {652.84 497.168} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank7_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {753.812 497.168} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank8_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {11.008 430.288} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank8_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {111.98 430.288} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank9_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {230.952 497.168} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank9_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {331.924 497.168} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank10_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {432.896 497.168} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank10_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {533.868 497.168} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank11_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {652.84 430.288} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank11_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {753.812 430.288} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank12_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {11.008 363.408} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank12_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {111.98 363.408} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank13_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {230.952 430.288} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank13_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {331.924 430.288} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank14_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {432.896 430.288} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank14_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {533.868 430.288} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank15_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {652.84 363.408} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank15_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {753.812 363.408} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank16_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {11.008 296.528} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank16_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {111.98 296.528} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank17_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {230.952 229.648} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank17_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {331.924 229.648} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank18_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {432.896 229.648} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank18_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {533.868 229.648} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank19_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {652.84 296.528} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank19_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {753.812 296.528} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank20_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {11.008 229.648} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank20_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {111.98 229.648} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank21_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {230.952 162.768} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank21_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {331.924 162.768} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank22_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {432.896 162.768} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank22_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {533.868 162.768} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank23_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {652.84 229.648} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank23_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {753.812 229.648} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank24_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {11.008 162.768} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank24_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {111.98 162.768} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank25_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {230.952 77.888} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank25_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {331.924 77.888} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank26_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {432.896 77.888} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank26_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {533.868 77.888} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank27_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {652.84 162.768} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank27_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {753.812 162.768} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank28_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {11.008 77.888} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank28_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {111.98 77.888} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank29_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {230.952 11.008} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank29_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {331.924 11.008} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank30_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {432.896 11.008} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank30_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {533.868 11.008} -orientation R0
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank31_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {652.84 77.888} -orientation MX
place_macro -macro_name {u_NV_NVDLA_cbuf/u_cbuf_ram_bank31_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram} -location {753.812 77.888} -orientation MX

# CDMA_IMG FIFO macro (15.666 x 28.512): see header comment -- centered
# in column gap 2 (6.167um clearance each side), centered vertically in
# the nominal-column middle gap.
place_macro -macro_name {u_NV_NVDLA_cdma/u_img.u_sg/u_NV_NVDLA_CDMA_IMG_fifo.ram.r_nv_ram_rwsp_128x11.ram_Inst_128X11.sram} -location {209.119 344.152} -orientation R0

set _blk [ord::get_db_block]
foreach _m {
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank0_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank0_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank10_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank10_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank11_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank11_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank12_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank12_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank13_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank13_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank14_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank14_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank15_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank15_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank16_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank16_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank17_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank17_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank18_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank18_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank19_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank19_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank1_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank1_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank20_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank20_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank21_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank21_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank22_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank22_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank23_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank23_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank24_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank24_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank25_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank25_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank26_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank26_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank27_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank27_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank28_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank28_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank29_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank29_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank2_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank2_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank30_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank30_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank31_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank31_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank3_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank3_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank4_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank4_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank5_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank5_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank6_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank6_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank7_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank7_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank8_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank8_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank9_ram0.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cbuf/u_cbuf_ram_bank9_ram1.r_nv_ram_rws_256x64.ram_Inst_256X64.sram}
  {u_NV_NVDLA_cdma/u_img.u_sg/u_NV_NVDLA_CDMA_IMG_fifo.ram.r_nv_ram_rwsp_128x11.ram_Inst_128X11.sram}
} {
  set _i [$_blk findInst $_m]
  if {$_i ne "NULL" && $_i ne ""} { $_i setPlacementStatus FIRM }
}
