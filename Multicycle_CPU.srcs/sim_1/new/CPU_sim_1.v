`timescale 1ns / 1ps

module CPU_sim_1(  );

    // input
    reg clk;
    reg reset;

    // output
    // basic, FETCH
    wire [2:0] state;  // ״̬��״̬
    wire [31:0] PC, nextPC;  // ��ǰPC��ַ����һPC��ַ
    wire [31:0] instruction;    // ָ��
    wire [5:0] op;
    wire [5:0] func;
    // DECODE
    wire [4:0] rs, rt, rd;  // �Ĵ�����ַ��rt,rd��$31����RegWAddr
    wire [31:0] Reg_RData1, Reg_RData2;  // �Ĵ�������
    // EXE
    wire [4:0] sa;  // ��λ������ID_RegRData1����ALU_A
    wire [15:0] imm;  // ����������ID_RegRData2����ALU_B
    wire [25:0] target;
    wire [31:0] ALU_A, ALU_B;  // ALU����
    wire [31:0] ALU_result;  // ALU���
    // MEM
    wire [31:0] RAM_DataOut;  // �洢�������������EX_ALU_result��PC+4����RegWData
    // WB
    wire [4:0] Reg_WAddr;  // д�ؼĴ�����ַ
    wire [31:0] Reg_WData;  // д�ؼĴ�������

    // ʵ����CPU
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

    always #50 clk = ~clk;  // ʱ������100ns

    initial begin
        clk = 1;
        reset = 0;
        
        #25;
        reset = 1;  // ��ʼ����
        
        #52000;  // 52000ns��ϵ�
        $stop;
    end

endmodule

