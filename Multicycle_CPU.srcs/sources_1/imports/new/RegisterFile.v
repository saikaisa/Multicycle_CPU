`timescale 1ns / 1ps

module RegisterFile(
    input clk,
    input reset,
    input WE,    // 寄存器堆写使能，1为有效
    input [4:0] WAddr,
    input [31:0] WData,
    input [4:0] RAddr1,
    input [4:0] RAddr2,
    output [31:0] RData1,
    output [31:0] RData2
    );
    
    reg [31:0] registers [1:31]; // 31个32位寄存器,0号寄存器不可写,未在此定义
    integer i;
    
    // 读数据（组合逻辑）
    assign RData1 = (RAddr1 == 0) ? 0 : registers[RAddr1];
    assign RData2 = (RAddr2 == 0) ? 0 : registers[RAddr2];
    
    // 写数据（时序逻辑，时钟下降沿写入）
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
