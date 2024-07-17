`timescale 1ns / 1ps

`include "defines.v"

module MulticycleCPU(
    input clk,
    input reset,
    
    output [2:0] state,  // ״̬��״̬
    output [31:0] currentPCAddr, nextPCAddr,  // ��ǰPC��ַ����һPC��ַ
    output [31:0] IF_instrution,    // ָ��
    output [5:0] op,
    output [5:0] func,
    output [4:0] rs, rt, rd,  // �Ĵ�����ַ��rt,rd��$31����RegWAddr
    output [4:0] shamt,  // ��λ������ID_RegRData1����ALU_A
    output [15:0] imm,  // ����������ID_RegRData2����ALU_B
    output [25:0] target,
    output [31:0] ID_RegRData1, ID_RegRData2,  // �Ĵ�������
    output [31:0] ALU_A, ALU_B,  // ALU����
    output [31:0] EX_ALU_result,  // ALU���

    output [31:0] MEM_RAMDataOut,  // �洢�������������EX_ALU_result��PC+4����RegWData

    output [4:0] RegWAddr,  // д�ؼĴ�����ַ
    output [31:0] RegWData  // д�ؼĴ�������
    );

    /* ��������ͨ· - ���� */
    wire [31:0] ID_instrution;  // ID_instrution(�½���)��IF_instrution(������)����ʱ�����ڲ���
    wire [31:0] EX_RegRData1, EX_RegRData2;
    wire [31:0] MEM_ALU_result, MEM_WBData;
    wire [31:0] WB_WBData;
    /* ��������ͨ· - ���� */
    wire ALU_zero, ALU_sign;    // ALU��־λ
    wire [31:0] extended_shamt, extended_imm;
    wire [25:0] target;

    /* �����ź� */
    wire PCWE, ALUSrcA, ALUSrcB, WBDataSrc, RegWE, RegWDataSrc, mRD, mWR, ExtSel;
    wire [1:0] PCSrc;
    wire [1:0] RegWAddrSrc;
    wire [3:0] ALUControl;

    /* ��ָ֧�����תָ���γɵ�Ŀ���ַ */
    wire [31:0] branchTarget;
    wire [31:0] jumpTarget;
    assign branchTarget = currentPCAddr + 4 + (extended_imm<<2);
    assign jumpTarget = {currentPCAddr[31:28], target, 2'b00};
    
    /* CPU�Ĺؼ����� */
    ControlFSM ControlFSM(
        .clk(clk), .reset(reset),
        .op(op), .func(func),
        .PCWE(PCWE), .state(state)
    );
    
    ControlUnit ControlUnit(
        // input
        .clk(clk),
        .zero(ALU_zero), .sign(ALU_sign),
        .state(state),
        .op(op), .func(func),
        // output
        .PCWE(PCWE), .mWR(mWR), .RegWE(RegWE), // ��״̬������
        .ALUSrcA(ALUSrcA), 
        .ALUSrcB(ALUSrcB), 
        .WBDataSrc(WBDataSrc), 
        .RegWDataSrc(RegWDataSrc), 
        .mRD(mRD), 
        .ExtSel(ExtSel),
        .PCSrc(PCSrc),
        .RegWAddrSrc(RegWAddrSrc),
        .ALUControl(ALUControl)
    );

    PC PC(
        .clk(clk), .reset(reset), .WE(PCWE), 
        .nextPCAddr(nextPCAddr),
        .currentPCAddr(currentPCAddr)
    );

    InstructionROM InstructionROM(
        .addr(currentPCAddr),
        .instruction(IF_instrution)
    );

    RegisterFile RegisterFile(
        .clk(clk), .reset(reset), .WE(RegWE),
        .WAddr(RegWAddr), .WData(RegWData),
        .RAddr1(rs), .RAddr2(rt), 
        .RData1(ID_RegRData1), .RData2(ID_RegRData2)
    );

    ALU ALU(
        .ALUControl(ALUControl), .A(ALU_A), .B(ALU_B),
        .result(EX_ALU_result), .zero(ALU_zero), .sign(ALU_sign)
    );

    DataRAM DataRAM(
        .clk(clk), .RD(mRD), .WR(mWR),
        .addr(EX_ALU_result), .DataIn(ID_RegRData2), 
        .DataOut(MEM_RAMDataOut)
    );
    
    /* �׶θ��� */
    IR FETCH_DECODE(
        .clk(clk), .reset(reset),
        .in(IF_instrution),
        .op(op), .rs(rs), .rt(rt), .rd(rd), .shamt(shamt), .func(func), .imm(imm), .target(target)
    );

    DECODE_EXE DECODE_EXE(
        .clk(clk), .reset(reset),
        .RegRData1_in(ID_RegRData1), .RegRData2_in(ID_RegRData2),
        .RegRData1_out(EX_RegRData1), .RegRData2_out(EX_RegRData2)
    );

    EXE_MEM EXE_MEM(
        .clk(clk), .reset(reset),
        .ALU_result_in(EX_ALU_result),
        .ALU_result_out(MEM_ALU_result)
    );

    MEM_WB MEM_WB(
        .clk(clk), .reset(reset), 
        .WBData_in(MEM_WBData),
        .WBData_out(WB_WBData)
    );

    /* ��λ�� */
    EXT5T32 EXT5T32(
        .ExtSel(ExtSel),
        .original(shamt),
        .extended(extended_shamt)
    );

    EXT16T32 EXT16T32(
        .ExtSel(ExtSel),
        .original(imm),
        .extended(extended_imm)
    );

    /* ��·ѡ���� */
    MUX4X32 Mux_nextPCAddr(
        .select(PCSrc), 
        .in0(currentPCAddr + 4),  // PC+4
        .in1(branchTarget),  // beq,bne,bltz
        .in2(ID_RegRData1),  // jr
        .in3(jumpTarget),  // j,jal
        .out(nextPCAddr)
    );

    MUX4X5 Mux_RegWAddr(
        .select(RegWAddrSrc), 
        .in0(5'd31),  // jal
        .in1(rt),  // I-type
        .in2(rd),  // R-type
        .in3(5'bzzzzz),
        .out(RegWAddr)
    );

    MUX2X32 Mux_RegWData(
        .select(RegWDataSrc), 
        .in0(currentPCAddr + 4),  // jal
        .in1(WB_WBData),  // ��������ָ��
        .out(RegWData)
    );

    MUX2X32 Mux_ALU_A(
        .select(ALUSrcA), 
        .in0(EX_RegRData1),  // ��������ָ��
        .in1(extended_shamt),  // sll,srl
        .out(ALU_A)
    );

    MUX2X32 Mux_ALU_B(
        .select(ALUSrcB), 
        .in0(EX_RegRData2),  // ��������ָ��
        .in1(extended_imm),  // ����ָ֧�����I��ָ��
        .out(ALU_B)
    );

    MUX2X32 Mux_WBData(
        .select(WBDataSrc), 
        .in0(EX_ALU_result),  // ��������ָ��
        .in1(MEM_RAMDataOut),  // lw
        .out(MEM_WBData)
    );

endmodule
