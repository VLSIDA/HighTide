# The pinned CTS disconnects the input of the buffer forwarding the PCIe
# user clock to output clk. Restore the synthesized connection immediately
# after tree construction, before legalization and timing repair. No clock
# definition, period, or data I/O timing constraint is changed.
proc hightide_litepci_restore_forwarded_clock {} {
  set block [ord::get_db_block]
  set source [$block findITerm pcie_us/user_clk]
  set port [$block findBTerm clk]
  if {$source == "NULL" || $port == "NULL" || [$source getNet] == "NULL" || [$port getNet] == "NULL"} {
    error "LitePCI forwarded clock source/output is missing"
  }
  set source_net [$source getNet]
  set target_net [$port getNet]
  set drivers {}
  foreach pin [$target_net getITerms] {
    if {[$pin getIoType] eq "OUTPUT"} {lappend drivers $pin}
  }
  if {[llength $drivers] != 1} {error "LitePCI clk output must have exactly one driver"}
  set driver [lindex $drivers 0]
  set inst [$driver getInst]
  if {![regexp {^BUF.*ASAP7} [[$inst getMaster] getName]]} {
    error "Unexpected LitePCI forwarded-clock driver [[$inst getMaster] getName]"
  }
  set input [$block findITerm "[$inst getName]/A"]
  if {$input == "NULL"} {error "LitePCI forwarded-clock buffer has no A pin"}
  if {[$input getNet] == "NULL"} {
    if {$source_net == $target_net} {error "Refusing a forwarded-clock buffer loop"}
    $input connect $source_net
    puts "Restored LitePCI forwarded clock: [$inst getName]/A to [$source_net getName]"
  }
}

rename clock_tree_synthesis hightide_litepci_clock_tree_synthesis
proc clock_tree_synthesis {args} {
  set result [hightide_litepci_clock_tree_synthesis {*}$args]
  hightide_litepci_restore_forwarded_clock
  return $result
}
