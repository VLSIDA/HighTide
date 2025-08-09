module ODDRX1F (
    input D0,
    input D1,
    input SCLK, 
    output reg Q
);

reg q_pos, q_neg;
always @(posedge SCLK) q_pos <= D0;
always @(negedge SCLK) q_neg <= D1;
assign Q = SCLK ? q_pos : q_neg;

endmodule
