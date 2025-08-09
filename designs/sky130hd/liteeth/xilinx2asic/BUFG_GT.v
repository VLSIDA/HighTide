module BUFG_GT
(
    input        CE,
    input        CEMASK,
    input        CLR,
    input        CLRMASK,
    input [2:0]  DIV,
    input        I,
    output       O
);

    wire ce_active, clr_active;
    wire clk_enabled, clk_divided;
    reg [2:0] div_counter;
    reg clk_div_reg;
    
    assign ce_active = CEMASK ? ~CE : CE;
    assign clr_active = CLRMASK ? ~CLR : CLR;
    
    wire [2:0] div_value = DIV + 3'b001;
    
    always @(posedge I or posedge clr_active) begin
        if (clr_active) begin
            div_counter <= 3'b000;
            clk_div_reg <= 1'b0;
        end else begin
            if (div_value == 3'b001) begin
                clk_div_reg <= 1'b1;
            end else begin
                if (div_counter == (div_value - 1)) begin
                    div_counter <= 3'b000;
                    clk_div_reg <= ~clk_div_reg;
                end else begin
                    div_counter <= div_counter + 1'b1;
                end
            end
        end
    end
    assign clk_divided = (div_value == 3'b001) ? I : clk_div_reg;
    
    wire clk_gated;

    sky130_fd_sc_hd__and2_0 clk_and_gate (
        .A(clk_divided),
        .B(1'b1),
        .X(clk_gated)
    );
    
    wire clk_final;
    assign clk_final = clr_active ? 1'b0 : clk_gated;
    
    sky130_fd_sc_hd__clkbuf_1  clk_buf (.A(clk_final), .X(O));
    // sky130_fd_sc_hd__clkbuf_2  clk_buf (.A(clk_final), .X(O));
    // sky130_fd_sc_hd__clkbuf_4  clk_buf (.A(clk_final), .X(O));
    // sky130_fd_sc_hd__clkbuf_8  clk_buf (.A(clk_final), .X(O));
    // sky130_fd_sc_hd__clkbuf_16 clk_buf (.A(clk_final), .X(O));

endmodule
