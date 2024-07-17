`ifndef DEFINES_V
`define DEFINES_V

/* ALU control signals */
`define ALU_ADD      4'b0000
`define ALU_SUB      4'b0001
`define ALU_SLL      4'b0010
`define ALU_SRL      4'b0011
`define ALU_OR       4'b0100
`define ALU_AND      4'b0101
`define ALU_SLTU     4'b0110
`define ALU_SLT      4'b0111
`define ALU_XOR      4'b1000
`define ALU_NOR      4'b1001
`define ALU_MUL      4'b1010
`define ALU_MOD      4'b1011
`define ALU_A        4'b1100
`define ALU_B        4'b1101

/* FSM state code */
`define FETCH   3'b000
`define DECODE  3'b001
`define EXE1    3'b010
`define EXE2    3'b101
`define EXE3    3'b110
`define MEM     3'b011
`define WB1     3'b100
`define WB2     3'b111

/* Instruction OP and FUNC code */
`define R_TYPE  6'b000000
`define ADD     6'b100000
`define ADDU    6'b100001
`define SUB     6'b100010
`define SUBU    6'b100011
`define AND     6'b001000
`define OR      6'b001001
`define XOR     6'b001010
`define NOR     6'b001011
`define SLT     6'b000010
`define SLL     6'b000100
`define SRL     6'b000101
`define ADDIU   6'b100001
`define ANDI    6'b001000
`define ORI     6'b001001
`define XORI    6'b001010
`define SLTI    6'b000010
`define SW      6'b010000
`define LW      6'b010001
`define BEQ     6'b011000
`define BNE     6'b011001
`define BLTZ    6'b011010
`define J       6'b011100
`define JR      6'b011101
`define JAL     6'b011110
`define HALT    6'b111111

`endif