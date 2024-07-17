`timescale 1ns / 1ps

module MEM_WB(
    input clk,
    input reset,
    input [31:0] WBData_in,
    output [31:0] WBData_out
    );

    DFF32 WBData_reg(
        .clk(clk), .reset(reset), 
        .in(WBData_in),
        .out(WBData_out)
    );

endmodule