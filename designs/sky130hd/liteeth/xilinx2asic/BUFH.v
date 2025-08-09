module BUFH
(
    input  I,
    output O
);

    sky130_fd_sc_hd__clkbuf_1  clk_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__clkbuf_2  clk_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__clkbuf_4  clk_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__clkbuf_8  clk_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__clkbuf_16 clk_buf (.A(I), .X(O));

endmodule
