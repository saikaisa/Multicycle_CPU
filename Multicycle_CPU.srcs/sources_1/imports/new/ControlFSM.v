`timescale 1ns / 1ps

`include "defines.v"

module ControlFSM(
    input clk, reset,
    input [5:0] op,
    input [5:0] func,
    output reg PCWE,
    output reg [2:0] state
    );

    /* 时钟上升沿改变状态 */
    always @(posedge clk or negedge reset) begin
        if(reset == 0) begin
            state <= `FETCH;
            PCWE <= 1;
        end
        else begin
            /*
                ======= FSM state transition =======
                FETCH->DECODE:  ALL
                DECODE->FETCH:  j,jr,jal,halt
                DECODE->EXE1:   sw,lw
                DECODE->EXE2:   beq,bne,bltz
                DECODE->EXE3:   add,addu,addiu,sub,subu,and,andi,or,ori,xor,xori,nor,sll,srl,slt,slti
                EXE1->MEM:      sw,lw
                EXE2->FETCH:    beq,bne,bltz
                EXE3->WB2:      add,addu,addiu,sub,subu,and,andi,or,ori,xor,xori,nor,sll,srl,slt,slti
                MEM->FETCH:     sw
                MEM->WB1:       lw
                WB1->FETCH:     lw
                WB2->FETCH:     add,addu,addiu,sub,subu,and,andi,or,ori,xor,xori,nor,sll,srl,slt,slti
            */
            case(state)
                `FETCH: state <= `DECODE;
                `DECODE: begin
                        if(op==`J || op==`JR || op==`JAL || op==`HALT) state <= `FETCH;
                        else if(op==`SW || op==`LW) state <= `EXE1;
                        else if(op==`BEQ || op==`BNE || op==`BLTZ) state <= `EXE2;
                        else state <= `EXE3;    // R-type and I-type operational instructions
                    end
                `EXE1: state <= `MEM;
                `EXE2: state <= `FETCH;
                `EXE3: state <= `WB2;
                `MEM: begin
                        if(op==`LW) state <= `WB1;
                        else state <= `FETCH;   // sw
                    end
                `WB1: state <= `FETCH;
                `WB2: state <= `FETCH;
            endcase
        end
    end

endmodule