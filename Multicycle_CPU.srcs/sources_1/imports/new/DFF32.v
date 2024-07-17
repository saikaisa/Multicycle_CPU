`timescale 1ns / 1ps

module DFF32(
    input clk,
    input reset,
    input [31:0] in,
    output reg [31:0] out
    );
    
    always @(posedge clk or negedge reset) begin
        if(reset == 0) out <= 32'b0;
        else out <= in;
    end
    
endmodule
