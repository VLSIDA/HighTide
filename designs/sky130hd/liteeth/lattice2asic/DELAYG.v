module DELAYG #(
    parameter DEL_MODE = "",
    parameter DEL_VALUE = 1'b0
)(
    input A,
    output Z
);

    sky130_fd_sc_hd__buf_1  output_buf (.A(A), .X(Z));
    // sky130_fd_sc_hd__buf_2  output_buf (.A(A), .X(Z));
    // sky130_fd_sc_hd__buf_4  output_buf (.A(A), .X(Z));
    // sky130_fd_sc_hd__buf_6  output_buf (.A(A), .X(Z));
    // sky130_fd_sc_hd__buf_8  output_buf (.A(A), .X(Z));
    // sky130_fd_sc_hd__buf_12 output_buf (.A(A), .X(Z));
    // sky130_fd_sc_hd__buf_16 output_buf (.A(A), .X(Z));


endmodule
