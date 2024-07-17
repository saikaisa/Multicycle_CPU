`timescale 1ns / 1ps

module EXT16T32(
    input ExtSel,    // 0: 零扩展,  1: 符号扩展
    input [15:0] original,
    output reg [31:0] extended
    );
    
    always @(*) begin
        extended[15:0] <= original;    // 低16位保持不变
        if(ExtSel == 0) extended[31:16] <= 16'b0;   // 零扩展
        else begin    // 符号扩展
            if(original[15] == 0) extended[31:16] <= 16'b0;
            else extended[31:16] <= 16'hFFFF;
        end
    end
    
endmodule
