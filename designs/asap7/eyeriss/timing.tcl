# Eyeriss has structural mux cycles whose inactive arcs are disabled by the
# fixed controller. Static loop breaking can also cut active path segments.
# Dynamic analysis preserves those segments and stops paths that revisit a
# vertex. No timing exception, clock period or I/O budget is changed.
# Stage PRE hooks run after the platform's normal setup. PLATFORM_TCL cannot
# be overridden here: asap7/config.mk assigns it after design defaults.
set ::sta_dynamic_loop_breaking 1
puts "Eyeriss timing policy: sta_dynamic_loop_breaking=$::sta_dynamic_loop_breaking"
