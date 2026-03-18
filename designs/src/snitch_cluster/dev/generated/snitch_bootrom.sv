// Synthesizable bootrom replacement: combinational logic instead of ROM array.
// The original generated bootrom allocates a large memory array (64KB) that is
// mostly zeros. This replaces it with simple logic to avoid synthesizing 32K+
// bits of ROM storage.

module snitch_bootrom #(
    parameter int unsigned AddrWidth = 32,
    parameter int unsigned DataWidth = 32,
    parameter int unsigned BootromSize = 65536
)(
    input  logic                 clk_i,
    input  logic                 rst_ni,
    input  logic [AddrWidth-1:0] addr_i,
    output logic [DataWidth-1:0] data_o
);

    // Word index from address
    localparam int unsigned WordBytes = DataWidth / 8;
    localparam int unsigned IdxWidth = $clog2(BootromSize / WordBytes);
    logic [IdxWidth-1:0] word_idx;
    assign word_idx = addr_i[$clog2(BootromSize)-1:$clog2(WordBytes)];

    // Only 32-bit word 0 is non-zero: 32'h0000006f (RISC-V: j 0)
    // Map to the DataWidth-wide beat containing that word.
    localparam int unsigned WordsPerBeat = DataWidth / 32;
    localparam int unsigned BeatIdx = 0 / WordsPerBeat;
    localparam int unsigned SubIdx  = 0 % WordsPerBeat;

    always_comb begin
        data_o = '0;
        if (word_idx == IdxWidth'(BeatIdx))
            data_o[SubIdx*32 +: 32] = 32'h0000006f;
    end

endmodule
