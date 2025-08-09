module IDDR #(
    parameter DDR_CLK_EDGE = "OPPOSITE_EDGE",
    parameter INIT_Q1 = 1'b0,
    parameter INIT_Q2 = 1'b0,
    parameter [0:0] IS_C_INVERTED = 1'b0,
    parameter [0:0] IS_D_INVERTED = 1'b0,
    parameter SRTYPE = "SYNC"
)(
    input  wire C,
    input  wire CE,
    input  wire D,
    input  wire R,
    input  wire S,
    output reg  Q1,
    output reg  Q2
);

    wire c_in, d_in;
    reg q1_int, q2_int;
    reg q1_pipelined, q2_same_edge;
    
    assign c_in = IS_C_INVERTED ? ~C : C;
    assign d_in = IS_D_INVERTED ? ~D : D;
    
    initial begin
        Q1 = INIT_Q1;
        Q2 = INIT_Q2;
        q1_int = INIT_Q1;
        q2_int = INIT_Q2;
        q1_pipelined = INIT_Q1;
        q2_same_edge = INIT_Q2;
    end
    
    generate
        if (DDR_CLK_EDGE == "OPPOSITE_EDGE") begin : opposite_edge_mode
            
            if (SRTYPE == "ASYNC") begin : async_reset
                always @(posedge c_in or posedge R or posedge S) begin
                    if (R)
                        q1_int <= 1'b0;
                    else if (S)
                        q1_int <= 1'b1;
                    else if (CE)
                        q1_int <= d_in;
                end
                
                always @(negedge c_in or posedge R or posedge S) begin
                    if (R)
                        q2_int <= 1'b0;
                    else if (S)
                        q2_int <= 1'b1;
                    else if (CE)
                        q2_int <= d_in;
                end
                
            end else begin : sync_reset
                always @(posedge c_in) begin
                    if (R)
                        q1_int <= 1'b0;
                    else if (S)
                        q1_int <= 1'b1;
                    else if (CE)
                        q1_int <= d_in;
                end
                
                always @(negedge c_in) begin
                    if (R)
                        q2_int <= 1'b0;
                    else if (S)
                        q2_int <= 1'b1;
                    else if (CE)
                        q2_int <= d_in;
                end
            end
            
            always @(*) begin
                Q1 = q1_int;
                Q2 = q2_int;
            end
            
        end else if (DDR_CLK_EDGE == "SAME_EDGE") begin : same_edge_mode
            
            if (SRTYPE == "ASYNC") begin : async_reset
                always @(posedge c_in or posedge R or posedge S) begin
                    if (R) begin
                        q1_int <= 1'b0;
                        q2_same_edge <= 1'b0;
                    end else if (S) begin
                        q1_int <= 1'b1;
                        q2_same_edge <= 1'b1;
                    end else if (CE) begin
                        q1_int <= d_in;
                        q2_same_edge <= q1_int;
                    end
                end
                
            end else begin : sync_reset
                always @(posedge c_in) begin
                    if (R) begin
                        q1_int <= 1'b0;
                        q2_same_edge <= 1'b0;
                    end else if (S) begin
                        q1_int <= 1'b1;
                        q2_same_edge <= 1'b1;
                    end else if (CE) begin
                        q1_int <= d_in;
                        q2_same_edge <= q1_int;
                    end
                end
            end
            
            always @(*) begin
                Q1 = q1_int;
                Q2 = q2_same_edge;
            end
            
        end else if (DDR_CLK_EDGE == "SAME_EDGE_PIPELINED") begin : same_edge_pipelined_mode
            
            if (SRTYPE == "ASYNC") begin : async_reset
                always @(posedge c_in or posedge R or posedge S) begin
                    if (R) begin
                        q1_int <= 1'b0;
                        q1_pipelined <= 1'b0;
                        q2_same_edge <= 1'b0;
                    end else if (S) begin
                        q1_int <= 1'b1;
                        q1_pipelined <= 1'b1;
                        q2_same_edge <= 1'b1;
                    end else if (CE) begin
                        q1_int <= d_in;
                        q1_pipelined <= q1_int;
                        q2_same_edge <= q1_int;
                    end
                end
                
            end else begin : sync_reset
                always @(posedge c_in) begin
                    if (R) begin
                        q1_int <= 1'b0;
                        q1_pipelined <= 1'b0;
                        q2_same_edge <= 1'b0;
                    end else if (S) begin
                        q1_int <= 1'b1;
                        q1_pipelined <= 1'b1;
                        q2_same_edge <= 1'b1;
                    end else if (CE) begin
                        q1_int <= d_in;
                        q1_pipelined <= q1_int;
                        q2_same_edge <= q1_int;
                    end
                end
            end
            
            always @(*) begin
                Q1 = q1_pipelined;
                Q2 = q2_same_edge;
            end
            
        end else begin : invalid_mode
            initial begin
                $display("Error: Invalid DDR_CLK_EDGE parameter: %s", DDR_CLK_EDGE);
                $display("Valid options: OPPOSITE_EDGE, SAME_EDGE, SAME_EDGE_PIPELINED");
                $finish;
            end
        end
    endgenerate

endmodule
