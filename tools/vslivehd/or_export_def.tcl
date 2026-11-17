# Export an OpenROAD database to DEF unchanged (resize study, shared-input exchange).
#   INPUT_ODB   .odb to read
#   OUTPUT_DEF  .def to write
read_db $::env(INPUT_ODB)
write_def $::env(OUTPUT_DEF)
