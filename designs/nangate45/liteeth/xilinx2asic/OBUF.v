module OBUF
(
    input  I,
    output O
);

    BUF_X1  output_buf (.A(I), .Z(O));
    // BUF_X2  output_buf (.A(I), .Z(O));
    // BUF_X4  output_buf (.A(I), .Z(O));
    // BUF_X6  output_buf (.A(I), .Z(O));
    // BUF_X8  output_buf (.A(I), .Z(O));
    // BUF_X16 output_buf (.A(I), .Z(O));
    // BUF_X32 output_buf (.A(I), .Z(O));

endmodule
