`timescale 1ns / 1ps

module InstructionROM(
    input [31:0] addr,
    output [31:0] instruction 
    );
    
    // 256个存储单元的ROM，每个存储单元1个字节，一条指令占4个存储单元，最多存储64条指令
    reg [7:0] ROM [0:255];
    
    // 读取二进制代码文件，每行一条指令（32位），每8位用一个空格隔开，因为每次只能读取一个ROM存储单元（8位）
    initial begin
        $readmemb("D:/CodeProjects/vivado project/Multicycle_CPU/machine_code.txt", ROM);
    end
    
    assign instruction[31:24] = ROM[addr+0];
    assign instruction[23:16] = ROM[addr+1];
    assign instruction[15:8]  = ROM[addr+2];
    assign instruction[7:0]   = ROM[addr+3];
    
endmodule
