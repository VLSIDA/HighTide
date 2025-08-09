module BUFH
(
    input  I,
    output O
);

    CLKBUF_X1  clk_buf (.A(I), .Z(O));
    // CLKBUF_X2  clk_buf (.A(I), .Z(O));
    // CLKBUF_X3  clk_buf (.A(I), .Z(O));

endmodule
