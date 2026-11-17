set block [ord::get_db_block]
set out $::env(SCORE_OUT)
set f [open $out/connectivity.tsv w]
foreach net [$block getNets] {
 if {[$net getSigType] in {POWER GROUND}} {continue}
 set pins {}
 foreach p [$net getITerms] {lappend pins "I:[[$p getInst] getName]:[[$p getMTerm] getName]"}
 foreach p [$net getBTerms] {lappend pins "B:[$p getName]"}
 if {[llength $pins]>1} {puts $f [join [lsort $pins] "\t"]}
}
close $f
set f [open $out/terminals.tsv w]
foreach p [$block getBTerms] {
 if {[$p getSigType] in {POWER GROUND}} {continue}
 lassign [$p getFirstPinLocation] ok x y
 puts $f [join [list [$p getName] [$p getIoType] $x $y] "\t"]
}
close $f
