"""Ordered SystemVerilog source list for Vortex GPGPU.

Order: packages → interfaces → libs → cache → fpu → mem → core → top.
Paths are relative to either `rtl/` (release mode) or `dev/gen/rtl/` (dev mode);
BUILD.bazel prefixes appropriately.

Exclusions follow the Vortex hw/rtl Makefile convention for synthesis:
  - libs/VX_{avs,axi}_adapter.sv, VX_axi_write_ack.sv — Avalon/AXI adapters
    only used by Vortex_axi / OPAE AFU wrappers (excluded tops).
  - libs/VX_mem_{bank,data}_adapter.sv — only instantiated by the excluded
    adapters above.
  - Vortex_axi.sv, afu/**, tcu/** — alternate tops / unused subsystems.
"""

VORTEX_FILES = [
    # 1) Packages
    "VX_gpu_pkg.sv",
    "VX_trace_pkg.sv",
    "fpu/VX_fpu_pkg.sv",

    # 2) Interfaces
    "interfaces/VX_branch_ctl_if.sv",
    "interfaces/VX_commit_csr_if.sv",
    "interfaces/VX_commit_if.sv",
    "interfaces/VX_commit_sched_if.sv",
    "interfaces/VX_dcr_bus_if.sv",
    "interfaces/VX_decode_if.sv",
    "interfaces/VX_decode_sched_if.sv",
    "interfaces/VX_dispatch_if.sv",
    "interfaces/VX_execute_if.sv",
    "interfaces/VX_fetch_if.sv",
    "interfaces/VX_ibuffer_if.sv",
    "interfaces/VX_issue_sched_if.sv",
    "interfaces/VX_operands_if.sv",
    "interfaces/VX_result_if.sv",
    "interfaces/VX_sched_csr_if.sv",
    "interfaces/VX_schedule_if.sv",
    "interfaces/VX_scoreboard_if.sv",
    "interfaces/VX_warp_ctl_if.sv",
    "interfaces/VX_writeback_if.sv",
    "fpu/VX_fpu_csr_if.sv",
    "mem/VX_gbar_bus_if.sv",
    "mem/VX_lsu_mem_if.sv",
    "mem/VX_mem_bus_if.sv",

    # 3) Libraries
    "libs/VX_allocator.sv",
    "libs/VX_async_ram_patch.sv",
    "libs/VX_bits_concat.sv",
    "libs/VX_bits_insert.sv",
    "libs/VX_bits_remove.sv",
    "libs/VX_bypass_buffer.sv",
    "libs/VX_cyclic_arbiter.sv",
    "libs/VX_demux.sv",
    "libs/VX_divider.sv",
    "libs/VX_dp_ram.sv",
    "libs/VX_edge_trigger.sv",
    "libs/VX_elastic_adapter.sv",
    "libs/VX_elastic_buffer.sv",
    "libs/VX_fifo_queue.sv",
    "libs/VX_find_first.sv",
    "libs/VX_generic_arbiter.sv",
    "libs/VX_index_buffer.sv",
    "libs/VX_index_queue.sv",
    "libs/VX_lzc.sv",
    "libs/VX_matrix_arbiter.sv",
    "libs/VX_mem_coalescer.sv",
    "libs/VX_mem_scheduler.sv",
    "libs/VX_multiplier.sv",
    "libs/VX_mux.sv",
    "libs/VX_nz_iterator.sv",
    "libs/VX_onehot_encoder.sv",
    "libs/VX_onehot_mux.sv",
    "libs/VX_onehot_shift.sv",
    "libs/VX_pe_serializer.sv",
    "libs/VX_pending_size.sv",
    "libs/VX_pipe_buffer.sv",
    "libs/VX_pipe_register.sv",
    "libs/VX_placeholder.sv",
    "libs/VX_popcount.sv",
    "libs/VX_priority_arbiter.sv",
    "libs/VX_priority_encoder.sv",
    "libs/VX_reduce_tree.sv",
    "libs/VX_reset_relay.sv",
    "libs/VX_rr_arbiter.sv",
    "libs/VX_scan.sv",
    "libs/VX_scope_switch.sv",
    "libs/VX_scope_tap.sv",
    "libs/VX_serial_div.sv",
    "libs/VX_serial_mul.sv",
    "libs/VX_shift_register.sv",
    "libs/VX_skid_buffer.sv",
    "libs/VX_sp_ram.sv",
    "libs/VX_stream_arb.sv",
    "libs/VX_stream_buffer.sv",
    "libs/VX_stream_omega.sv",
    "libs/VX_stream_pack.sv",
    "libs/VX_stream_switch.sv",
    "libs/VX_stream_unpack.sv",
    "libs/VX_stream_xbar.sv",
    "libs/VX_stream_xpoint.sv",
    "libs/VX_ticket_lock.sv",
    "libs/VX_toggle_buffer.sv",
    "libs/VX_transpose.sv",

    # 4) Cache
    "cache/VX_cache.sv",
    "cache/VX_cache_bank.sv",
    "cache/VX_cache_bypass.sv",
    "cache/VX_cache_cluster.sv",
    "cache/VX_cache_data.sv",
    "cache/VX_cache_flush.sv",
    "cache/VX_cache_init.sv",
    "cache/VX_cache_mshr.sv",
    "cache/VX_cache_repl.sv",
    "cache/VX_cache_tags.sv",
    "cache/VX_cache_top.sv",
    "cache/VX_cache_wrap.sv",

    # 5) FPU
    "fpu/VX_fcvt_unit.sv",
    "fpu/VX_fncp_unit.sv",
    "fpu/VX_fp_classifier.sv",
    "fpu/VX_fp_rounding.sv",
    "fpu/VX_fpu_cvt.sv",
    "fpu/VX_fpu_div.sv",
    "fpu/VX_fpu_dpi.sv",
    "fpu/VX_fpu_dsp.sv",
    "fpu/VX_fpu_fma.sv",
    "fpu/VX_fpu_fpnew.sv",
    "fpu/VX_fpu_ncp.sv",
    "fpu/VX_fpu_sqrt.sv",
    "fpu/VX_fpu_unit.sv",

    # 6) Memory subsystem
    "mem/VX_gbar_arb.sv",
    "mem/VX_gbar_unit.sv",
    "mem/VX_lmem_switch.sv",
    "mem/VX_local_mem.sv",
    "mem/VX_local_mem_top.sv",
    "mem/VX_lsu_adapter.sv",
    "mem/VX_lsu_mem_arb.sv",
    "mem/VX_mem_arb.sv",
    "mem/VX_mem_switch.sv",

    # 7) Core
    "core/VX_alu_int.sv",
    "core/VX_alu_muldiv.sv",
    "core/VX_alu_unit.sv",
    "core/VX_commit.sv",
    "core/VX_core.sv",
    "core/VX_core_top.sv",
    "core/VX_csr_data.sv",
    "core/VX_csr_unit.sv",
    "core/VX_dcr_data.sv",
    "core/VX_decode.sv",
    "core/VX_dispatch.sv",
    "core/VX_dispatch_unit.sv",
    "core/VX_execute.sv",
    "core/VX_fetch.sv",
    "core/VX_gather_unit.sv",
    "core/VX_ibuffer.sv",
    "core/VX_ipdom_stack.sv",
    "core/VX_issue.sv",
    "core/VX_issue_slice.sv",
    "core/VX_issue_top.sv",
    "core/VX_lsu_slice.sv",
    "core/VX_lsu_unit.sv",
    "core/VX_mem_unit.sv",
    "core/VX_mem_unit_top.sv",
    "core/VX_opc_unit.sv",
    "core/VX_operands.sv",
    "core/VX_pe_switch.sv",
    "core/VX_schedule.sv",
    "core/VX_scoreboard.sv",
    "core/VX_sfu_unit.sv",
    "core/VX_split_join.sv",
    "core/VX_uop_sequencer.sv",
    "core/VX_uuid_gen.sv",
    "core/VX_wctl_unit.sv",

    # 8) Top
    "VX_cluster.sv",
    "VX_socket.sv",
    "Vortex.sv",
]

# Include subdirectories (relative to the rtl root). yosys-slang needs these
# for `include-resolving VX_platform.vh, VX_config.vh, VX_cache_define.vh, etc.
VORTEX_INCLUDE_SUBDIRS = [
    "",
    "cache",
    "core",
    "fpu",
    "interfaces",
    "libs",
    "mem",
]

def _include_dirs_str(prefix):
    dirs = []
    for sd in VORTEX_INCLUDE_SUBDIRS:
        p = prefix if sd == "" else prefix + "/" + sd
        dirs.append(p)
    return " ".join(dirs)

# Include dirs point at the hermetically-fetched upstream tree (@vortex_src).
# hw/dpi is added for util_dpi.vh (included by VX_platform.vh under `SV_DPI).
VORTEX_INCLUDE_DIRS_RELEASE_STR = (
    _include_dirs_str("external/+http_archive+vortex_src/hw/rtl") +
    " external/+http_archive+vortex_src/hw/dpi"
)
VORTEX_INCLUDE_DIRS_DEV_STR = ""
