`timescale 1ns / 1ps

module CPU_sim_1(  );

    // input
    reg clk;
    reg reset;

    // output
    // basic, FETCH
    wire [2:0] state;  // 状态机状态
    wire [31:0] PC, nextPC;  // 当前PC地址，下一PC地址
    wire [31:0] instruction;    // 指令
    wire [5:0] op;
    wire [5:0] func;
    // DECODE
    wire [4:0] rs, rt, rd;  // 寄存器地址，rt,rd和$31竞争RegWAddr
    wire [31:0] Reg_RData1, Reg_RData2;  // 寄存器数据
    // EXE
    wire [4:0] sa;  // 移位量，与ID_RegRData1竞争ALU_A
    wire [15:0] imm;  // 立即数，与ID_RegRData2竞争ALU_B
    wire [25:0] target;
    wire [31:0] ALU_A, ALU_B;  // ALU输入
    wire [31:0] ALU_result;  // ALU结果
    // MEM
    wire [31:0] RAM_DataOut;  // 存储器数据输出，与EX_ALU_result和PC+4竞争RegWData
    // WB
    wire [4:0] Reg_WAddr;  // 写回寄存器地址
    wire [31:0] Reg_WData;  // 写回寄存器数据

    // 实例化CPU
    MulticycleCPU uut (
        .clk(clk),
        .reset(reset),
        .state(state),
        .currentPCAddr(PC),
        .nextPCAddr(nextPC),
        .IF_instrution(instruction),
        .op(op),
        .func(func),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .shamt(sa),
        .imm(imm),
        .target(target),
        .ID_RegRData1(Reg_RData1),
        .ID_RegRData2(Reg_RData2),
        .ALU_A(ALU_A),
        .ALU_B(ALU_B),
        .EX_ALU_result(ALU_result),
        .MEM_RAMDataOut(RAM_DataOut),
        .RegWAddr(Reg_WAddr),
        .RegWData(Reg_WData)
    );

    always #50 clk = ~clk;  // 时钟周期100ns

    initial begin
        clk = 1;
        reset = 0;
        
        #25;
        reset = 1;  // 开始仿真
        
        #52000;  // 52000ns后断点
        $stop;
    end

endmodule

