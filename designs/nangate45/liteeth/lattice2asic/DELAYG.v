module DELAYG #(
    parameter DEL_MODE = "",
    parameter DEL_VALUE = 1'b0
)(
    input A,
    output Z
);

    BUF_X1  output_buf (.A(A), .Z(Z));
    // BUF_X2  output_buf (.A(A), .Z(Z));
    // BUF_X4  output_buf (.A(A), .Z(Z));
    // BUF_X6  output_buf (.A(A), .Z(Z));
    // BUF_X8  output_buf (.A(A), .Z(Z));
    // BUF_X16 output_buf (.A(A), .Z(Z));
    // BUF_X32 output_buf (.A(A), .Z(Z));


endmodule
