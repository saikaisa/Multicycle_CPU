`timescale 1ns / 1ps

module RegisterFile(
    input clk,
    input reset,
    input WE,    // �Ĵ�����дʹ�ܣ�1Ϊ��Ч
    input [4:0] WAddr,
    input [31:0] WData,
    input [4:0] RAddr1,
    input [4:0] RAddr2,
    output [31:0] RData1,
    output [31:0] RData2
    );
    
    reg [31:0] registers [1:31]; // 31��32λ�Ĵ���,0�żĴ�������д,δ�ڴ˶���
    integer i;
    
    // �����ݣ�����߼���
    assign RData1 = (RAddr1 == 0) ? 0 : registers[RAddr1];
    assign RData2 = (RAddr2 == 0) ? 0 : registers[RAddr2];
    
    // д���ݣ�ʱ���߼���ʱ���½���д�룩
    always @(negedge clk or negedge reset) begin
        if(reset == 0) begin
            for(i = 1; i <= 31; i=i+1) begin
                registers[i] <= 0;
            end
        end
        else if(WE == 1 && WAddr != 0)
            registers[WAddr] <= WData;
    end
    
endmodule
