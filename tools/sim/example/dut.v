// Example DUT for the tools/sim verification-testbench harness (self-test).
// A free-running counter with clock and enable inputs, used to validate that
// the cocotb runner builds + simulates a plain-Verilog design end to end.
module counter #(parameter WIDTH = 4) (
    input  logic            clk,
    input  logic            enable,
    output logic [WIDTH-1:0] count
);
    always_ff @(posedge clk) begin
        if (enable) count <= count + 1'b1;
    end
endmodule
