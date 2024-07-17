`timescale 1ns / 1ps

`include "defines.v"

module ALU(
    input [3:0] ALUControl,
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] result,
    output zero,   // 结果是否为0？是为1，否为0
    output sign    // 结果是否为负？是为1，否为0
);

    assign zero = (result == 0) ? 1 : 0;
    assign sign = result[31];
    
    always @(ALUControl or A or B) begin
        case(ALUControl)
            `ALU_ADD:   result = A + B;
            `ALU_SUB:   result = A - B;
            `ALU_SLL:   result = B << A;
            `ALU_SRL:   result = B >> A;
            `ALU_OR:    result = A | B;
            `ALU_AND:   result = A & B;
            `ALU_SLTU:  result = (A < B) ? 1 : 0; // 无符号比较
            `ALU_SLT:   result = ($signed(A) < $signed(B)) ? 1 : 0; // 带符号比较
            `ALU_XOR:   result = A ^ B;
            `ALU_NOR:   result = ~(A | B); // 或非
            `ALU_MUL:   result = A * B;    // 乘法
            `ALU_MOD:   result = A % B;    // 取模
            `ALU_A:     result = A;          // A
            `ALU_B:     result = B;          // B
            default:    result = 32'bz;      // 默认输出高阻抗
        endcase
    end
endmodule

