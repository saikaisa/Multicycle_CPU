`timescale 1ns / 1ps

module EXE_MEM(
    input clk,
    input reset,
    input [31:0] ALU_result_in,
    output [31:0] ALU_result_out
    );

    DFF32 ALU_result_reg(
        .clk(clk), .reset(reset), 
        .in(ALU_result_in),
        .out(ALU_result_out)
    );

endmodule