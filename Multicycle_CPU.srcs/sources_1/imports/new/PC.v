`timescale 1ns / 1ps

module PC(
    input clk,
    input reset,
    input WE,
    input [31:0] nextPCAddr,
    output reg [31:0] currentPCAddr
    );
    
    initial currentPCAddr <= 0;
    
    always @(posedge clk or negedge reset) begin
        if(reset == 0) currentPCAddr <= 0;
        else begin
            if(WE == 1) currentPCAddr <= nextPCAddr;
            else currentPCAddr <= currentPCAddr;
        end
    end
    
endmodule
