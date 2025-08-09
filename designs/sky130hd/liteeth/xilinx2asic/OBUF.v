module OBUF
(
    input  I,
    output O
);

    sky130_fd_sc_hd__buf_1  output_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__buf_2  output_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__buf_4  output_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__buf_6  output_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__buf_8  output_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__buf_12 output_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__buf_16 output_buf (.A(I), .X(O));

endmodule
