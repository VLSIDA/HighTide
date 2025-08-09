module IBUF
(
    input  I,
    output O
);

    BUFx2_ASAP7_75t_R  clk_buf (.A(I), .Y(O));
    // BUFx3_ASAP7_75t_R  clk_buf (.A(I), .Y(O));
    // BUFx4_ASAP7_75t_R  clk_buf (.A(I), .Y(O));


endmodule
