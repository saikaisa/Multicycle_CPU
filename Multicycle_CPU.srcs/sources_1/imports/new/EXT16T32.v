`timescale 1ns / 1ps

module EXT16T32(
    input ExtSel,    // 0: ����չ,  1: ������չ
    input [15:0] original,
    output reg [31:0] extended
    );
    
    always @(*) begin
        extended[15:0] <= original;    // ��16λ���ֲ���
        if(ExtSel == 0) extended[31:16] <= 16'b0;   // ����չ
        else begin    // ������չ
            if(original[15] == 0) extended[31:16] <= 16'b0;
            else extended[31:16] <= 16'hFFFF;
        end
    end
    
endmodule
