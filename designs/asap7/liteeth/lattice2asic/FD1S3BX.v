module FD1S3BX (
    input CK,
    input D,
    input PD,
    output Q
);

always @(posedge CK) begin
    if (!PD) begin
        Q <= 1'b1;
    end else begin
        Q <= D;
    end
end

endmodule
