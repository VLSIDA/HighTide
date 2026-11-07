// Lattice ECP5 generic IO buffer (BIDIR/INPUT/OUTPUT) — ASIC-boundary
// variant for the SDR DQ bus. The real primitive is a pad cell with a
// bidirectional pin B; ASIC standard-cell libraries carry no tristate
// cells, so the `assign B = T ? 1'bz : I` form is unmappable (yosys 0.68
// `check -assert` correctly rejects the leftover $_TBUF_ cells). Instead
// the pad pin is split into the standard core-side triple:
//   B_i  — pad input  (value seen at the pin)
//   B_o  — pad output (value to drive onto the pin)
//   B_oe — pad output enable (1 = drive B_o onto the pin)
// The top-level `litedram_asic` port split (sdram_dq_i/_o/_oe) routes
// these straight to ports; a pad ring or board-level model reconstructs
// the bidirectional bus as `dq = oe ? dq_o : 1'bz; dq_i = dq`.
// O keeps the primitive's readback semantics: when driving, the pin
// carries I, so the core samples its own driven value.
module TRELLIS_IO #(
    parameter DIR = ""
)(
    input  B_i,
    output B_o,
    output B_oe,
    input  I,
    input  T,
    output O
);
    assign B_o  = I;
    assign B_oe = ~T;
    assign O    = T ? B_i : I;
endmodule
