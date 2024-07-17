`timescale 1ns / 1ps

module IR(
    input clk,
    input reset,
    input [31:0] in,
    output reg [5:0] op,
    output reg [4:0] rs,
    output reg [4:0] rt,
    output reg [4:0] rd,
    output reg [4:0] shamt,
    output reg [5:0] func,
    output reg [15:0] imm,
    output reg [25:0] target
    );

    reg [31:0] tmp_inst;
    
    always @(negedge clk or negedge reset) begin
        if (reset == 0) begin
            op <= 6'bz;
            rs <= 5'bz;
            rt <= 5'bz;
            rd <= 5'bz;
            shamt <= 5'bz;
            func <= 6'bz;
            imm <= 16'bz;
            target <= 26'bz;
        end else begin 
            case(in[31:26])
                `R_TYPE: begin
                    case(in[5:0])
                        `SLL, `SRL: tmp_inst = {in[31:26], 5'bz, in[20:0]};
                        default: tmp_inst = {in[31:11], 5'bz, in[5:0]};
                    endcase
                    {op, rs, rt, rd, shamt, func} <= tmp_inst[31:0];
                    imm <= 16'bz;
                    target <= 26'bz;
                end

                `J, `JAL: begin
                    {op, target} <= {in[31:26], in[25:0]};
                    rs <= 5'bz;
                    rt <= 5'bz;
                    rd <= 5'bz;
                    shamt <= 5'bz;
                    func <= 6'bz;
                    imm <= 16'bz;
                end

                `JR: begin
                    {op, rs} <= {in[31:26], in[25:21]};
                    rt <= 5'bz;
                    rd <= 5'bz;
                    shamt <= 5'bz;
                    func <= 6'bz;
                    imm <= 16'bz;
                    target <= 26'bz;
                end

                `HALT: begin
                    op <= in[31:26];
                    rs <= 5'bz;
                    rt <= 5'bz;
                    rd <= 5'bz;
                    shamt <= 5'bz;
                    func <= 6'bz;
                    imm <= 16'bz;
                    target <= 26'bz;
                end
                
                // I-type
                default: begin
                    {op, rs, rt, imm} <= in[31:0];
                    rd <= 5'bz;
                    shamt <= 5'bz;
                    func <= 6'bz;
                    target <= 26'bz;
                end
            endcase
        end
    end
    
endmodule
