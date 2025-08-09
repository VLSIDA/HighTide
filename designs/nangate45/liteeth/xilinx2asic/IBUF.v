module IBUF
(
    input  I,
    output O
);

    BUF_X1  input_buf (.A(I), .Z(O));
    // BUF_X2  input_buf (.A(I), .Z(O));
    // BUF_X4  input_buf (.A(I), .Z(O));
    // BUF_X6  input_buf (.A(I), .Z(O));
    // BUF_X8  input_buf (.A(I), .Z(O));
    // BUF_X16 input_buf (.A(I), .Z(O));
    // BUF_X32 input_buf (.A(I), .Z(O));

endmodule
