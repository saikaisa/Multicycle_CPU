`timescale 1ns / 1ps

module DataRAM(
    input clk,
    input RD,    // 读控制，1有效
    input WR,    // 写控制，1有效
    input [31:0] addr,
    input [31:0] DataIn,
    output [31:0] DataOut    // 读出32位数据
    );
    
    reg [7:0] RAM [0:63];    // 64个存储单元，每个存储单元为一个字节
    
    /* 读，组合逻辑 */
    assign DataOut[7:0]   = (RD==1) ? RAM[addr+3] : 8'bz;
    assign DataOut[15:8]  = (RD==1) ? RAM[addr+2] : 8'bz;
    assign DataOut[23:16] = (RD==1) ? RAM[addr+1] : 8'bz;
    assign DataOut[31:24] = (RD==1) ? RAM[addr+0] : 8'bz;
    
    /* 写，时序逻辑，时钟下降沿写入 */
    always @(negedge clk) begin
        if(WR == 1) begin
            RAM[addr+0] <= DataIn[31:24];
            RAM[addr+1] <= DataIn[23:16];
            RAM[addr+2] <= DataIn[15:8];
            RAM[addr+3] <= DataIn[7:0];
        end
    end
endmodule
