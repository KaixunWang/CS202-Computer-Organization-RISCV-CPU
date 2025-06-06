`timescale 1ns / 1ps
`include "defines.v"


module alu_control(
    input [3:0] aluop_4,
    input [6:0] funct7_7,
    input [2:0] funct3_3,
    input [31:0] immediate_32,
    input [1:0] Ecall,
    output reg [4:0] alu_ctrl_5
    );

    always @(*) begin
        case (aluop_4)
           `ALUOP_RTYPE: begin
                if(funct7_7==7'b0000000 && funct3_3==3'b000) begin
                    alu_ctrl_5 = `ALU_CTRL_ADD;
                end
                else if(funct7_7==7'b0100000 && funct3_3==3'b000) begin
                    alu_ctrl_5 = `ALU_CTRL_SUB;
                end
                else if(funct7_7==7'b0000000 && funct3_3==3'b111) begin
                    alu_ctrl_5 = `ALU_CTRL_AND;
                end
                else if(funct7_7==7'b0000000 && funct3_3==3'b110) begin
                    alu_ctrl_5 = `ALU_CTRL_OR;
                end
                else if(funct7_7==7'b0000000 && funct3_3==3'b100) begin
                    alu_ctrl_5 = `ALU_CTRL_XOR;
                end
                else if(funct7_7==7'b0000000 && funct3_3==3'b010) begin
                    alu_ctrl_5 = `ALU_CTRL_SLT;
                end
                else if(funct7_7==7'b0000000 && funct3_3==3'b001) begin
                    alu_ctrl_5 = `ALU_CTRL_SLL;
                end
                else if(funct7_7==7'b0000000 && funct3_3==3'b101) begin
                    alu_ctrl_5 = `ALU_CTRL_SRL;
                end
                else if (funct7_7 == 7'b0000001 && funct3_3 == 3'b000) begin
                    alu_ctrl_5 = `ALU_CTRL_MUL;
                end
                else if (funct7_7 == 7'b0000001 && funct3_3 == 3'b100) begin
                    alu_ctrl_5 = `ALU_CTRL_DIV;
                end
                
                else if(funct7_7==7'b0000000 && funct3_3==3'b010) begin
                    alu_ctrl_5 = `ALU_CTRL_SLT;
                end
                else if(funct7_7==7'b0000000 && funct3_3==3'b011) begin
                    alu_ctrl_5 = `ALU_CTRL_SLTU;
                end
            end
            `ALUOP_ITYPE: begin
                if(funct3_3 == 3'b000) begin
                    alu_ctrl_5 = `ALU_CTRL_ADD;
                end
                else if(funct3_3 == 3'b100) begin
                    alu_ctrl_5 = `ALU_CTRL_XOR;
                end
                else if(funct3_3 == 3'b110) begin
                    alu_ctrl_5 = `ALU_CTRL_OR;
                end
                else if(funct3_3 == 3'b111) begin
                    alu_ctrl_5 = `ALU_CTRL_AND;
                end
                else if(funct3_3 == 001) begin
                    alu_ctrl_5 = `ALU_CTRL_SLL;
                end
                else if(funct3_3 == 3'b101 && immediate_32[11:5]==7'b0000000) begin
                    alu_ctrl_5 = `ALU_CTRL_SRL;
                end
                else if(funct3_3 == 3'b010) begin
                    alu_ctrl_5 = `ALU_CTRL_SLT;
                end
                
            end
            `ALUOP_LS: alu_ctrl_5 = `ALU_CTRL_ADD;
            `ALUOP_BTYPE: alu_ctrl_5 = `ALU_CTRL_SUB;
            `ALUOP_JALTYPE: alu_ctrl_5 = `ALU_CTRL_JAL;
            `ALUOP_JALRTYPE: alu_ctrl_5 = `ALU_CTRL_JALR;
            `ALUOP_LUI: alu_ctrl_5 = `ALU_CTRL_LUI;
            `ALUOP_AUIPC: alu_ctrl_5 = `ALU_CTRL_AUIPC;
            `ALUOP_ECALL: begin
                if (Ecall[1] == 1'b1) begin
                    if (Ecall[0] == 1'b1) begin
                        alu_ctrl_5 = `ALU_CTRL_ECALL_READ;
                    end else begin
                        alu_ctrl_5 = `ALU_CTRL_ECALL_WRITE;
                    end
                end
            end
            default: alu_ctrl_5 = `ALU_CTRL_NOP;
        endcase
    end
endmodule
