module TRELLIS_IO #(
    parameter DIR = ""
)(
    inout B,
    input I,
    input T,
    output O
);

assign B = T ? 1'bz : I;

assign O = B;

endmodule
