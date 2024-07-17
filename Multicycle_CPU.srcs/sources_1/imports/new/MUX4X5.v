`timescale 1ns / 1ps

module MUX4X5(
    input [1:0] select,
    input [4:0] in0, in1, in2, in3,
    output reg [4:0] out
    );
    
    always @(*) begin
        case(select)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
            default: out = 5'b0;
        endcase
    end
    
endmodule
