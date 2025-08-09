module IBUF
(
    input  I,
    output O
);

    sky130_fd_sc_hd__buf_1  input_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__buf_2  input_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__buf_4  input_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__buf_6  input_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__buf_8  input_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__buf_12 input_buf (.A(I), .X(O));
    // sky130_fd_sc_hd__buf_16 input_buf (.A(I), .X(O));

endmodule
