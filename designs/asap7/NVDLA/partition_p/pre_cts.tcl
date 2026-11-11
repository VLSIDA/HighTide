# 2026-11 toolchain upgrade workaround (OpenROAD 687848dd): this netlist
# carries three synthesized clock inverters (gated-clock nets with 1.5k-2.4k
# register loads each, e.g. u_NV_NVDLA_sdp.u_rdma.u_brdma/nvdla_gated_clk).
# `repair_clock_inverters` must clone them per load or CTS leaves one INVx1
# driving thousands of clock sinks (skew -> ~2.4k hold endpoints -> RSZ-0060
# max-buffer abort in repair_timing). But on this pin it SEGVs when an
# inverter's output pin resolves to a hierarchical dbModNet:
# dbNetwork::deleteNet casts it with staToDb, which returns nullptr for a
# modnet, and dbNet::destroy(nullptr) crashes (verified by disassembly: the
# fault is the first field read in destroy). Stripping the modnet
# association from the inverter output pins makes net(pin) resolve to the
# flat dbNet, and the real repair_clock_inverters then works (verified on a
# standalone repro: 3_place.odb + read_sdc + repair_clock_inverters).
# Remove once upstream guards deleteNet for modnets.
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
