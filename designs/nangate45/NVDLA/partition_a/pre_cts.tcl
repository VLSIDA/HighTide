# 2026-11 toolchain upgrade workaround (OpenROAD 687848dd): on this netlist
# `repair_clock_inverters` SEGVs when a clock inverter's output pin resolves
# to a hierarchical dbModNet: dbNetwork::deleteNet casts it with staToDb,
# which returns nullptr for a modnet, and dbNet::destroy(nullptr) crashes
# (root-caused on partition_p-asap7; the same netlist passed this step on
# the 2026-07 pin). Stripping the modnet association from the inverter
# output pins makes net(pin) resolve to the flat dbNet, and the real
# repair_clock_inverters then works. This replaces the earlier warning
# no-op shadow (QoR-safe here only by luck of small inverter fanout).
# See designs/src/NVDLA/DECISIONS.md (2026-11 section) and the CLAUDE.md
# workaround table. Remove once upstream guards deleteNet for modnets.
set _rci_block [ord::get_db_block]
set _rci_stripped 0
foreach _rci_inst [$_rci_block getInsts] {
  if {[string match "INV*" [[$_rci_inst getMaster] getName]]} {
    foreach _rci_it [$_rci_inst getITerms] {
      if {[$_rci_it getIoType] eq "OUTPUT"} {
        set _rci_net [$_rci_it getNet]
        if {$_rci_net ne "NULL" && $_rci_net ne "" \
            && [$_rci_net getSigType] eq "CLOCK"} {
          set _rci_mn [$_rci_it getModNet]
          if {$_rci_mn ne "NULL" && $_rci_mn ne ""} {
            $_rci_it disconnectDbModNet
            incr _rci_stripped
          }
        }
      }
    }
  }
}
utl::info FLW 9902 "stripped $_rci_stripped clock-inverter modnet associations (repair_clock_inverters SEGV workaround, DECISIONS.md 2026-11)"
