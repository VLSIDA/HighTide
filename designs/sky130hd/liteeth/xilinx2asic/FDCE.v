module FDCE (
    input wire D,
    input wire CE,
    input wire C,
    input wire CLR,
    output reg Q
);

always @(posedge C or posedge CLR) begin
    if (CLR) begin
        Q <= 1'b0;           // Asynchronous clear
    end else if (CE) begin
        Q <= D;              // Clock enable active, load D
    end
    // When CE=0 and CLR=0: Q retains previous value (no else clause)
end

endmodule
