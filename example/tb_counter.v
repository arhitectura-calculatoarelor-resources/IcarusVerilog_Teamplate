`timescale 1ns/1ps
module tb_counter;
  reg clk = 0;
  reg rst_n = 0;
  wire [3:0] q;

  // Device Under Test
  counter #(.WIDTH(4)) dut (
    .clk(clk),
    .rst_n(rst_n),
    .q(q)
  );

  // 10ns clock period
  always #5 clk = ~clk;

  initial begin
    $dumpfile("waves.vcd");   // waveform file
    $dumpvars(0, tb_counter); // dump all signals

    // reset for 2 cycles
    rst_n = 0;
    repeat(2) @(posedge clk);
    rst_n = 1;

    // run 20 cycles
    repeat(20) @(posedge clk);

    $finish;
  end
endmodule
