module FDCE (
    input wire D,
    input wire CE,
    input wire C,
    input wire CLR,
    output reg Q
);

always @(posedge C or posedge CLR) begin
    if (CLR) begin
        Q <= 1'b0;
    end else if (CE) begin
        Q <= D;
    end
end

endmodule
