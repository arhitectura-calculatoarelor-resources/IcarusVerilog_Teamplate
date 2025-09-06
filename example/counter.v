`timescale 1ns/1ps
module counter #(parameter WIDTH=4) (
  input  wire clk,
  input  wire rst_n,
  output reg  [WIDTH-1:0] q
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= '0;
    else        q <= q + 1'b1;
  end
endmodule
