current_design litedram_asic

# nangate45 lib units are ns. Match asap7's 6 ns target scaled up by
# the ~6x nangate45/asap7 stdcell delay ratio observed on similar
# liteeth variants — start at 12 ns (~83 MHz) and tighten later.
set clk_name    clk
set clk_port    [get_ports clk]
set clk_period  1.98
set clk_io_pct  0.2

create_clock -name $clk_name -period $clk_period $clk_port

# user_clk is a buffered copy of sys_clk on the same domain — treat it as
# a generated clock so the launch/capture edges line up.
set user_clk_port [get_ports user_clk]
create_generated_clock -name user_clk -source $clk_port \
    -divide_by 1 $user_clk_port

set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]

set_input_delay  [expr $clk_period * $clk_io_pct] -clock $clk_name $non_clock_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_outputs]
