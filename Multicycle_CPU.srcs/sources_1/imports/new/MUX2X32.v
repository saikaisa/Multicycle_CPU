`timescale 1ns / 1ps

module MUX2X32(
    input select,
    input [31:0] in0,
    input [31:0] in1,
    output [31:0] out
    );
    
    assign out = (select == 0) ? in0 : in1;
    
endmodule
