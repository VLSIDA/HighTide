module IDDRX1F (
    input D,
    input SCLK,
    output reg Q0,
    output reg Q1
);

    always @(posedge SCLK or negedge SCLK) begin
        if (SCLK) begin
            Q0 <= D;
        end else begin
            Q1 <= D;
        end
    end

endmodule
