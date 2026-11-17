`timescale 1ns/1ps
module BUFx2_ASAP7_75t_R(input A, output Y); assign Y=A; endmodule
module AND2x2_ASAP7_75t_R(input A,B, output Y); assign Y=A&B; endmodule
module clock_models_tb;
  reg [6:0] refs=0;
  reg [2:0] refsel=7;
  reg [1:0] sys=0;
  reg q0=0,q1=0;
  wire rx,tx;
  GTHE4_CHANNEL_DUMMY gth (
    .CPLLREFCLKSEL(refsel), .GTREFCLK0(refs[0]), .GTREFCLK1(refs[1]),
    .GTNORTHREFCLK0(refs[2]), .GTNORTHREFCLK1(refs[3]),
    .GTSOUTHREFCLK0(refs[4]), .GTSOUTHREFCLK1(refs[5]), .GTGREFCLK(refs[6]),
    .RXSYSCLKSEL(sys), .TXSYSCLKSEL(sys), .QPLL0CLK(q0), .QPLL1CLK(q1),
    .RXOUTCLK(rx), .TXOUTCLK(tx)
  );
  reg clk=0,clr=1,ce=1,cemask=0,clrmask=0;
  always #5 clk=~clk;
  wire [7:0] divided;
  integer count[0:7];
  reg measuring=0;
  wire startup_clock;
  integer startup_count=0;
  BUFG_GT startup_buffer(.I(clk),.O(startup_clock),.DIV(3'd1),
    .CE(1'b1),.CEMASK(1'b0),.CLR(1'b0),.CLRMASK(1'b0));
  always @(posedge startup_clock) if(measuring)startup_count=startup_count+1;
  genvar n;
  generate for(n=0;n<8;n=n+1)begin: divisors
    BUFG_GT buffer(.I(clk),.O(divided[n]),.DIV(n[2:0]),
      .CE(ce),.CEMASK(cemask),.CLR(clr),.CLRMASK(clrmask));
    always @(posedge divided[n]) if(measuring) count[n]=count[n]+1;
  end endgenerate
  integer i,j;
  initial begin
    for(i=0;i<7;i=i+1) begin
      refs=1<<i;
      for(j=1;j<=7;j=j+1)begin
        refsel=j; #1;
        if(rx!==refs[j-1] || tx!==refs[j-1])$fatal(1,"CPLL reference selection failed");
      end
    end
    for(i=0;i<4;i=i+1)begin
      {q0,q1}=i;
      sys=2; #1;if(rx!==q0 || tx!==q0)$fatal(1,"QPLL0 selection failed");
      sys=3; #1;if(rx!==q1 || tx!==q1)$fatal(1,"QPLL1 selection failed");
    end
    if(startup_clock===1'bx)$fatal(1,"Reset-free clock startup failed");
    if(divided!==0)$fatal(1,"CLR did not clear buffers");
    @(negedge clk);clr=0;
    repeat(8)@(negedge clk);
    for(i=0;i<8;i=i+1)count[i]=0;
    measuring=1;
    repeat(840)@(negedge clk);
    measuring=0;
    for(i=0;i<8;i=i+1)
      if(count[i]!==840/(i+1))$fatal(1,"DIV=%0d got %0d expected %0d",i,count[i],840/(i+1));
    if(startup_count!==420)$fatal(1,"Reset-free divider frequency failed");
    ce=0; #1;if(divided!==0)$fatal(1,"CE did not disable buffers");
    cemask=1;@(posedge clk);#1;
    if(divided[0]!==1)$fatal(1,"CEMASK did not bypass CE");
    clr=1;#1;if(divided!==0)$fatal(1,"CLR did not clear buffers");
    clrmask=1;@(posedge clk);#1;
    if(divided[0]!==1)$fatal(1,"CLRMASK did not suppress CLR");
    $display("PASS: CPLL/QPLL clock selection, DIV0..7 frequency, enable and clear masks");
    $finish;
  end
endmodule
