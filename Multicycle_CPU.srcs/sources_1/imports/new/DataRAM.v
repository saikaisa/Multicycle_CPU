`timescale 1ns / 1ps

module DataRAM(
    input clk,
    input RD,    // �����ƣ�1��Ч
    input WR,    // д���ƣ�1��Ч
    input [31:0] addr,
    input [31:0] DataIn,
    output [31:0] DataOut    // ����32λ����
    );
    
    reg [7:0] RAM [0:63];    // 64���洢��Ԫ��ÿ���洢��ԪΪһ���ֽ�
    
    /* ��������߼� */
    assign DataOut[7:0]   = (RD==1) ? RAM[addr+3] : 8'bz;
    assign DataOut[15:8]  = (RD==1) ? RAM[addr+2] : 8'bz;
    assign DataOut[23:16] = (RD==1) ? RAM[addr+1] : 8'bz;
    assign DataOut[31:24] = (RD==1) ? RAM[addr+0] : 8'bz;
    
    /* д��ʱ���߼���ʱ���½���д�� */
    always @(negedge clk) begin
        if(WR == 1) begin
            RAM[addr+0] <= DataIn[31:24];
            RAM[addr+1] <= DataIn[23:16];
            RAM[addr+2] <= DataIn[15:8];
            RAM[addr+3] <= DataIn[7:0];
        end
    end
endmodule
