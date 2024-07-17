`timescale 1ns / 1ps

module EXT5T32(
    input ExtSel,    // 0: ����չ,  1: ������չ
    input [4:0] original,
    output reg [31:0] extended
    );
    
    always @(*) begin
        extended[4:0] <= original;    // ��5λ���ֲ���
        if(ExtSel == 0) extended[31:5] <= 27'b0;   // ����չ
        else begin    // ������չ
            if(original[4] == 0) extended[31:5] <= 27'b0;
            else extended[31:5] <= 27'h7FFFFFF;
        end
    end
    
endmodule
