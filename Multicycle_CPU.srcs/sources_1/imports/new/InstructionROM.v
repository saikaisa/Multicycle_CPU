`timescale 1ns / 1ps

module InstructionROM(
    input [31:0] addr,
    output [31:0] instruction 
    );
    
    // 256���洢��Ԫ��ROM��ÿ���洢��Ԫ1���ֽڣ�һ��ָ��ռ4���洢��Ԫ�����洢64��ָ��
    reg [7:0] ROM [0:255];
    
    // ��ȡ�����ƴ����ļ���ÿ��һ��ָ�32λ����ÿ8λ��һ���ո��������Ϊÿ��ֻ�ܶ�ȡһ��ROM�洢��Ԫ��8λ��
    initial begin
        $readmemb("D:/CodeProjects/vivado project/Multicycle_CPU/machine_code.txt", ROM);
    end
    
    assign instruction[31:24] = ROM[addr+0];
    assign instruction[23:16] = ROM[addr+1];
    assign instruction[15:8]  = ROM[addr+2];
    assign instruction[7:0]   = ROM[addr+3];
    
endmodule
