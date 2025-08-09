module DELAYG #(
    parameter DEL_MODE = "",
    parameter DEL_VALUE = 1'b0
)(
    input A,
    output Z
);

    BUFx2_ASAP7_75t_R  clk_buf (.A(I), .Y(Z));
    // BUFx3_ASAP7_75t_R  clk_buf (.A(I), .Y(Z));
    // BUFx4_ASAP7_75t_R  clk_buf (.A(I), .Y(Z));


endmodule
