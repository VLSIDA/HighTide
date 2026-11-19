// tools/sim/example — Pattern-B demonstrator: a plain, self-checking
// SystemVerilog testbench for the counter DUT (dut.v, same DUT as the
// cocotb suite test_counter.py). A run that prints nothing and exits 0 is
// green; check failures print "TB ERROR: ..." and $fatal gives a non-zero
// exit status so the runner propagates them.
`timescale 1ns/1ps

module tb_counter;

    logic clk = 1'b0;
    logic enable;
    int   errors = 0;

    always #5 clk = ~clk;

    counter #(4) dut (
        .clk    (clk),
        .enable (enable),
        .count  ()
    );

    int exp;
    task check(input int exp, input int act, input string what);
        if (exp != act) begin
            $display("TB ERROR: %s expected %0d got %0d", what, exp, act);
            errors++;
        end
    endtask

    initial begin
        $display("TB: counter plain-TB self-test starting");
        enable = 1;
        exp = 0;
        repeat (5) begin
            @(posedge clk);
            exp++;
        end
        #1;
        check(exp, dut.count, "free-running count after 5 clocks");
        if (errors == 0) $display("TB PASSED");
        else $fatal(1, "TB FAILED: %0d error(s)", errors);
        $finish;
    end

endmodule
