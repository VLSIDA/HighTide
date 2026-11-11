# OpenROAD floorplan with only the macros (FIXED), pins and rows: no standard cells, no nets.
#   INPUT_ODB  .odb to read     OUTPUT_DEF  .def to write
read_db $::env(INPUT_ODB)
set block [ord::get_db_block]
foreach inst [$block getInsts] {
  if {[$inst isBlock]} { $inst setPlacementStatus FIRM } else { odb::dbInst_destroy $inst }
}
foreach net [$block getNets] { if {[llength [$net getBTerms]] == 0} { odb::dbNet_destroy $net } }
write_def $::env(OUTPUT_DEF)
