`timescale 1ns / 1ps

`include "defines.v"

module MulticycleCPU(
    input clk,
    input reset,
    
    output [2:0] state,  // 状态机状态
    output [31:0] currentPCAddr, nextPCAddr,  // 当前PC地址，下一PC地址
    output [31:0] IF_instrution,    // 指令
    output [5:0] op,
    output [5:0] func,
    output [4:0] rs, rt, rd,  // 寄存器地址，rt,rd和$31竞争RegWAddr
    output [4:0] shamt,  // 移位量，与ID_RegRData1竞争ALU_A
    output [15:0] imm,  // 立即数，与ID_RegRData2竞争ALU_B
    output [25:0] target,
    output [31:0] ID_RegRData1, ID_RegRData2,  // 寄存器数据
    output [31:0] ALU_A, ALU_B,  // ALU输入
    output [31:0] EX_ALU_result,  // ALU结果

    output [31:0] MEM_RAMDataOut,  // 存储器数据输出，与EX_ALU_result和PC+4竞争RegWData

    output [4:0] RegWAddr,  // 写回寄存器地址
    output [31:0] RegWData  // 写回寄存器数据
    );

    /* 部分数据通路 - 锁存 */
    wire [31:0] ID_instrution;  // ID_instrution(下降沿)比IF_instrution(上升沿)晚半个时钟周期产生
    wire [31:0] EX_RegRData1, EX_RegRData2;
    wire [31:0] MEM_ALU_result, MEM_WBData;
    wire [31:0] WB_WBData;
    /* 部分数据通路 - 其他 */
    wire ALU_zero, ALU_sign;    // ALU标志位
    wire [31:0] extended_shamt, extended_imm;
    wire [25:0] target;

    /* 控制信号 */
    wire PCWE, ALUSrcA, ALUSrcB, WBDataSrc, RegWE, RegWDataSrc, mRD, mWR, ExtSel;
    wire [1:0] PCSrc;
    wire [1:0] RegWAddrSrc;
    wire [3:0] ALUControl;

    /* 分支指令和跳转指令形成的目标地址 */
    wire [31:0] branchTarget;
    wire [31:0] jumpTarget;
    assign branchTarget = currentPCAddr + 4 + (extended_imm<<2);
    assign jumpTarget = {currentPCAddr[31:28], target, 2'b00};
    
    /* CPU的关键部件 */
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
        .PCWE(PCWE), .mWR(mWR), .RegWE(RegWE), // 受状态机控制
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
    
    /* 阶段隔离 */
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

    /* 移位器 */
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

    /* 多路选择器 */
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
        .in1(WB_WBData),  // 其他所有指令
        .out(RegWData)
    );

    MUX2X32 Mux_ALU_A(
        .select(ALUSrcA), 
        .in0(EX_RegRData1),  // 其他所有指令
        .in1(extended_shamt),  // sll,srl
        .out(ALU_A)
    );

    MUX2X32 Mux_ALU_B(
        .select(ALUSrcB), 
        .in0(EX_RegRData2),  // 其他所有指令
        .in1(extended_imm),  // 除分支指令外的I型指令
        .out(ALU_B)
    );

    MUX2X32 Mux_WBData(
        .select(WBDataSrc), 
        .in0(EX_ALU_result),  // 其他所有指令
        .in1(MEM_RAMDataOut),  // lw
        .out(MEM_WBData)
    );

endmodule
