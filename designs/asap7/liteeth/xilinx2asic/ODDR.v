module ODDR #(
    parameter DDR_CLK_EDGE = "OPPOSITE_EDGE",
    parameter INIT = 1'b0,
    parameter SRTYPE = "SYNC"
)(
    input  wire C,
    input  wire CE,     
    input  wire D1,
    input  wire D2,
    input  wire R,
    input  wire S,
    output reg  Q       
);

    reg d1_reg;
    reg d2_reg;
    reg clk_toggle;

    initial begin
        d1_reg = INIT;
        d2_reg = INIT;
        Q = INIT;
        clk_toggle = 1'b0;
    end

    generate
        if (DDR_CLK_EDGE == "OPPOSITE_EDGE") begin
            
            if (SRTYPE == "ASYNC") begin
                always @(posedge C or posedge R) begin
                    if (R)
                        clk_toggle <= 1'b0;
                    else if (CE)
                        clk_toggle <= ~clk_toggle;
                end
                
                always @(posedge C or posedge S or posedge R) begin
                    if (R)
                        d1_reg <= 1'b0;
                    else if (S)
                        d1_reg <= 1'b1;
                    else if (CE)
                        d1_reg <= D1;
                end
                
                always @(posedge C or posedge S or posedge R) begin
                    if (R)
                        d2_reg <= 1'b0;
                    else if (S)
                        d2_reg <= 1'b1;
                    else if (CE && clk_toggle)
                        d2_reg <= D2;
                end
                
                always @(posedge C or posedge S or posedge R) begin
                    if (R)
                        Q <= 1'b0;
                    else if (S)
                        Q <= 1'b1;
                    else if (CE) begin
                        if (clk_toggle)
                            Q <= d2_reg;
                        else
                            Q <= d1_reg;
                    end
                end
                
            end else begin
                always @(posedge C) begin
                    if (R)
                        clk_toggle <= 1'b0;
                    else if (CE)
                        clk_toggle <= ~clk_toggle;
                end
                
                always @(posedge C) begin
                    if (R)
                        d1_reg <= 1'b0;
                    else if (S)
                        d1_reg <= 1'b1;
                    else if (CE)
                        d1_reg <= D1;
                end
                
                always @(posedge C) begin
                    if (R)
                        d2_reg <= 1'b0;
                    else if (S)
                        d2_reg <= 1'b1;
                    else if (CE && clk_toggle)
                        d2_reg <= D2;
                end
                
                always @(posedge C) begin
                    if (R)
                        Q <= 1'b0;
                    else if (S)
                        Q <= 1'b1;
                    else if (CE) begin
                        if (clk_toggle)
                            Q <= d2_reg;
                        else
                            Q <= d1_reg;
                    end
                end
            end
            
        end else begin      
            if (SRTYPE == "ASYNC") begin
                always @(posedge C or posedge S or posedge R) begin
                    if (R) begin
                        d1_reg <= 1'b0;
                        d2_reg <= 1'b0;
                        Q <= 1'b0;
                        clk_toggle <= 1'b0;
                    end else if (S) begin
                        d1_reg <= 1'b1;
                        d2_reg <= 1'b1;
                        Q <= 1'b1;
                    end else if (CE) begin
                        d1_reg <= D1;
                        d2_reg <= D2;
                        clk_toggle <= ~clk_toggle;
                        Q <= clk_toggle ? D2 : D1;
                    end
                end
                
            end else begin 
                always @(posedge C) begin
                    if (R) begin
                        d1_reg <= 1'b0;
                        d2_reg <= 1'b0;
                        Q <= 1'b0;
                        clk_toggle <= 1'b0;
                    end else if (S) begin
                        d1_reg <= 1'b1;
                        d2_reg <= 1'b1;
                        Q <= 1'b1;
                    end else if (CE) begin
                        d1_reg <= D1;
                        d2_reg <= D2;
                        clk_toggle <= ~clk_toggle;
                        Q <= clk_toggle ? D2 : D1;
                    end
                end
            end
        end
    endgenerate

endmodule
