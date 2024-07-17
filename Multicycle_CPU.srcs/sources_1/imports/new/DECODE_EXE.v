`timescale 1ns / 1ps

module DECODE_EXE(
    input clk,
    input reset,
    input [31:0] RegRData1_in,
    input [31:0] RegRData2_in,
    output [31:0] RegRData1_out,
    output [31:0] RegRData2_out
    );

    DFF32 RegRData1_reg(
        .clk(clk), .reset(reset), 
        .in(RegRData1_in),
        .out(RegRData1_out)
    );

    DFF32 RegRData2_reg(
        .clk(clk), .reset(reset), 
        .in(RegRData2_in),
        .out(RegRData2_out)
    );

endmodule