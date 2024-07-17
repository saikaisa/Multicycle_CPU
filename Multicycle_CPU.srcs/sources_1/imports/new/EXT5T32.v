`timescale 1ns / 1ps

module EXT5T32(
    input ExtSel,    // 0: 零扩展,  1: 符号扩展
    input [4:0] original,
    output reg [31:0] extended
    );
    
    always @(*) begin
        extended[4:0] <= original;    // 低5位保持不变
        if(ExtSel == 0) extended[31:5] <= 27'b0;   // 零扩展
        else begin    // 符号扩展
            if(original[4] == 0) extended[31:5] <= 27'b0;
            else extended[31:5] <= 27'h7FFFFFF;
        end
    end
    
endmodule
