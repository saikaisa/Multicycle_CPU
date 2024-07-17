`timescale 1ns / 1ps

`include "defines.v"

module ControlUnit(
    input clk,
    input zero, sign,
    input [2:0] state,
    input [5:0] op, func,
    output reg PCWE, mWR, RegWE,
    output reg ALUSrcA, ALUSrcB, WBDataSrc, RegWDataSrc, mRD, ExtSel,
    output reg [1:0] PCSrc,
    output reg [1:0] RegWAddrSrc,
    output reg [3:0] ALUControl
    );
    
    reg [13:0] control; // {ALUSrcA, ALUSrcB, WBDataSrc, RegWDataSrc, mRD, ExtSel, PCSrc[1:0], RegWAddrSrc[1:0], ALUControl[3:0]}
    reg [2:0] wr_control; // {PCWE, mWR, RegWE}
        
    /* ���������źţ�ʵ����ÿ��ʱ�������ض��ᴥ�� */
    always @(negedge clk or state or op or func or zero or sign) begin
        
        /* ��״̬�޹صĿ����ź� */
        // R-type
        if(op == `R_TYPE) begin
            case(func)
                `ADD,`ADDU: control = 14'b000100_00_10_0000;
                `SUB,`SUBU: control = 14'b000100_00_10_0001;
                `AND:   control = 14'b000100_00_10_0101;
                `OR:    control = 14'b000100_00_10_0100;
                `XOR:   control = 14'b000100_00_10_1000;
                `NOR:   control = 14'b000100_00_10_1001;
                `SLT:   control = 14'b000100_00_10_0111;
                `SLL:   control = 14'b100100_00_10_0010;
                `SRL:   control = 14'b100100_00_10_0011;
            endcase
        end
        // I-type, J-type and halt
        else begin
            case(op)
                `ADDIU: control = 14'b010101_00_01_0000;
                `ANDI:  control = 14'b010100_00_01_0101;
                `ORI:   control = 14'b010100_00_01_0100;
                `XORI:  control = 14'b010100_00_01_1000;
                `SLTI:  control = 14'b010101_00_01_0111;
                `SW:    control = 14'b010101_00_01_0000;
                `LW:    control = 14'b011111_00_01_0000;
                `BEQ:   control = (zero == 1) ? 14'b000101_01_11_0001 : 14'b000101_00_11_0001;
                `BNE:   control = (zero == 0) ? 14'b000101_01_11_0001 : 14'b000101_00_11_0001;
                `BLTZ:  control = (sign == 1) ? 14'b000101_01_11_0000 : 14'b000101_00_11_0000;
                `J:     control = 14'b000100_11_11_1111;
                `JR:    control = 14'b000100_10_11_1111;
                `JAL:   control = 14'b000000_11_00_1111;
                `HALT:  control = 14'b000100_00_11_1111;
            endcase
        end

        {ALUSrcA, ALUSrcB, WBDataSrc, RegWDataSrc, mRD, ExtSel, PCSrc[1:0], RegWAddrSrc[1:0], ALUControl[3:0]} <= control[13:0];

        /* ��״̬�йصĿ����ź� */
        case(state)
            // ע��PCWE��Ҫ���½��ص�ʱ��ı䣬��Ϊ��������PC�ı��ʱ����PCWEͬʱ�ı���ܲ�̫�ȶ�
            `DECODE:   wr_control = {   (clk==0) ? ((op==`J||op==`JR||op==`JAL) ? 1'b1 : 1'b0) : PCWE, 
                                        1'b0, 
                                        (op==`JAL) ? 1'b1 : 1'b0
                                    };
            `MEM:      wr_control = {   (clk==0) ? ((op==`SW) ? 1'b1 : 1'b0) : PCWE, 
                                        (op==`SW) ? 1'b1 : 1'b0, 
                                        1'b0
                                    };
            `EXE2:     wr_control = {   (clk==0) ? 1'b1 : PCWE, 
                                        1'b0, 
                                        1'b0
                                    };
            `WB1,`WB2: wr_control = {   (clk==0) ? 1'b1 : PCWE, 
                                        1'b0, 
                                        1'b1
                                    };
            default:   wr_control = {   (clk==0) ? 1'b0 : PCWE, 
                                        1'b0, 
                                        1'b0
                                    };
        endcase

        {PCWE, mWR, RegWE} <= wr_control[2:0];
        
    end

endmodule