`timescale 1ns / 1ps
`include "defines.v"

module ins_split(
    input [31:0] instruction_32,
    output [6:0] opcode_7,
    output reg [4:0] rd_5,
    output reg [2:0] funct3_3,
    output reg [6:0] funct7_7,
    output reg [4:0] rs1_5,
    output reg [4:0] rs2_5,
    output reg [31:0] immediate_32
    );

    assign opcode_7 = instruction_32[6:0];
    always @* begin
        case (opcode_7)
            `R_TYPE: begin
                rd_5 = instruction_32[11:7];
                funct3_3 = instruction_32[14:12];
                rs1_5 = instruction_32[19:15];
                rs2_5 = instruction_32[24:20];
                funct7_7 = instruction_32[31:25];
            end
            `I_TYPE_1, `I_TYPE_2: begin
                rd_5 = instruction_32[11:7];
                funct3_3 = instruction_32[14:12];
                rs1_5 = instruction_32[19:15];
                immediate_32 = {{20{instruction_32[31]}}, instruction_32[31:20]};
            end
            `S_TYPE: begin
                funct3_3 = instruction_32[14:12];
                rs1_5 = instruction_32[19:15];
                rs2_5 = instruction_32[24:20];
                immediate_32 = {{20{instruction_32[31]}}, instruction_32[31:25], instruction_32[11:7]};
            end
            `B_TYPE: begin
                funct3_3 = instruction_32[14:12];
                rs1_5 = instruction_32[19:15];
                rs2_5 = instruction_32[24:20];//imm[12|10:5] rs2 rs1 funct3 imm[4:1|11] opcode 
                immediate_32 = {{20{instruction_32[31]}}, instruction_32[7], instruction_32[30:25], instruction_32[11:8], 1'b0};
            end
            `JAL_TYPE: begin
                rd_5 = instruction_32[11:7];
                immediate_32 = {{12{instruction_32[31]}}, instruction_32[19:12], instruction_32[20], instruction_32[30:21], 1'b0};
            end
            `JALR_TYPE: begin
                rd_5 = instruction_32[11:7];
                funct3_3 = instruction_32[14:12];
                rs1_5 = instruction_32[19:15];
                immediate_32 = {{20{instruction_32[31]}}, instruction_32[31:20]};
            end
            `U_TYPE_1,`U_TYPE_2: begin
                rd_5 = instruction_32[11:7];
                immediate_32 = {instruction_32[31:12], 12'b0};
            end
           `ECALL: begin
                immediate_32 = 32'b0;
            end
            default: begin
                rd_5 = 5'b0;
                funct3_3 = 3'b0;
                funct7_7 = 7'b0;
                rs1_5 = 5'b0;
                rs2_5 = 5'b0;
                immediate_32 = 32'b0;
            end
        endcase
    end


endmodule
