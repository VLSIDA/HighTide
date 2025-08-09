module FDPE #(
    parameter INIT = 1'b1
)(
    input  wire C,  
    input  wire PRE,
    input  wire CE, 
    input  wire D,  
    output reg  Q       
);

    initial Q = INIT;

    always @(posedge C or posedge PRE) begin
        if (PRE)
            Q <= 1'b1;
        else if (CE)
            Q <= D;
    end

endmodule
