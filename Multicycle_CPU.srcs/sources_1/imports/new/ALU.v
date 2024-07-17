`timescale 1ns / 1ps

`include "defines.v"

module ALU(
    input [3:0] ALUControl,
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] result,
    output zero,   // ����Ƿ�Ϊ0����Ϊ1����Ϊ0
    output sign    // ����Ƿ�Ϊ������Ϊ1����Ϊ0
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
            `ALU_SLTU:  result = (A < B) ? 1 : 0; // �޷��űȽ�
            `ALU_SLT:   result = ($signed(A) < $signed(B)) ? 1 : 0; // �����űȽ�
            `ALU_XOR:   result = A ^ B;
            `ALU_NOR:   result = ~(A | B); // ���
            `ALU_MUL:   result = A * B;    // �˷�
            `ALU_MOD:   result = A % B;    // ȡģ
            `ALU_A:     result = A;          // A
            `ALU_B:     result = B;          // B
            default:    result = 32'bz;      // Ĭ��������迹
        endcase
    end
endmodule

