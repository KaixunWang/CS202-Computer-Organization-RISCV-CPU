`timescale 1ns / 1ps
`include "defines.v"

module ins_control(
    input rst,
    input [6:0] opcode_7,
    input [2:0] funct3_3,
    input [6:0] funct7_7,
    input a7,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    output reg Ecall,
    output reg [3:0] ALUOp_4,
    output reg jump_and_link,
    output reg jump_and_link_register,
    output reg [4:0] rs1_5,
    output reg [4:0] rs2_5,
    output reg [4:0] rd_5
    );

always @(*) begin
        if (!rst) begin
            case (opcode_7)
                `R_TYPE: begin
                    Branch = 1'b0;
                    MemRead = 1'b0;
                    MemtoReg = 1'b0;
                    MemWrite = 1'b0;
                    ALUSrc = 1'b0;
                    RegWrite = 1'b1;
                    Ecall = 1'b0;
                    ALUOp_4 = `ALUOP_RTYPE;
                    jump_and_link = 1'b0;
                    jump_and_link_register = 1'b0;
                    Ecall = 1'b0;
                    rs1_5 = 5'b0;
                    rs2_5 = 5'b0;
                    rd_5 = 5'b0;
                end
                `I_TYPE_1: begin
                    Branch = 1'b0;
                    MemRead = 1'b0;
                    MemtoReg = 1'b0;
                    MemWrite = 1'b0;
                    ALUSrc = 1'b1;
                    RegWrite = 1'b1;
                    Ecall = 1'b0;
                    ALUOp_4 = `ALUOP_ITYPE;
                    jump_and_link = 1'b0;
                    jump_and_link_register = 1'b0;
                    Ecall = 1'b0;
                    rs1_5 = 5'b0;
                    rs2_5 = 5'b0;
                    rd_5 = 5'b0;
                end
                `I_TYPE_2: begin
                    Branch = 1'b0;
                    MemRead = 1'b1;
                    MemtoReg = 1'b1;
                    MemWrite = 1'b0;
                    ALUSrc = 1'b1;
                    RegWrite = 1'b1;
                    Ecall = 1'b0;
                    ALUOp_4 = `ALUOP_LS;
                    jump_and_link = 1'b0;
                    jump_and_link_register = 1'b0;
                    Ecall = 1'b0;
                    rs1_5 = 5'b0;
                    rs2_5 = 5'b0;
                    rd_5 = 5'b0;
                end
                `S_TYPE: begin
                    Branch = 1'b0;
                    MemRead = 1'b0;
                    MemtoReg = 1'b0;
                    MemWrite = 1'b1;
                    ALUSrc = 1'b1;
                    RegWrite = 1'b0;
                    Ecall = 1'b0;
                    ALUOp_4 = `ALUOP_LS;
                    jump_and_link = 1'b0;
                    jump_and_link_register = 1'b0;
                    Ecall = 1'b0;
                    rs1_5 = 5'b0;
                    rs2_5 = 5'b0;
                    rd_5 = 5'b0;
                end
                `B_TYPE: begin
                    Branch = 1'b1;
                    MemRead = 1'b0;
                    MemtoReg = 1'b0;
                    MemWrite = 1'b0;
                    ALUSrc = 1'b0;
                    RegWrite = 1'b0;
                    Ecall = 1'b0;
                    ALUOp_4 = `ALUOP_BTYPE;
                    jump_and_link = 1'b0;
                    jump_and_link_register = 1'b0;
                    Ecall = 1'b0;
                    rs1_5 = 5'b0;
                    rs2_5 = 5'b0;
                    rd_5 = 5'b0;
                end
                `JAL_TYPE: begin 
                    Branch = 1'b0;
                    MemRead = 1'b0;
                    MemtoReg = 1'b0;
                    MemWrite = 1'b0;
                    ALUSrc = 1'b1;
                    RegWrite = 1'b1;
                    Ecall = 1'b0;
                    ALUOp_4 = `ALUOP_JALTYPE;
                    jump_and_link = 1'b1;
                    jump_and_link_register = 1'b0;
                    Ecall = 1'b0;
                    rs1_5 = 5'b0;
                    rs2_5 = 5'b0;
                    rd_5 = 5'b0;
                end
                `JALR_TYPE: begin
                    Branch = 1'b0;
                    MemRead = 1'b0;
                    MemtoReg = 1'b0;
                    MemWrite = 1'b0;
                    ALUSrc = 1'b1;
                    RegWrite = 1'b1;
                    Ecall = 1'b0;
                    ALUOp_4 = `ALUOP_JALRTYPE;
                    jump_and_link = 1'b0;
                    jump_and_link_register = 1'b1;
                    Ecall = 1'b0;
                    rs1_5 = 5'b0;
                    rs2_5 = 5'b0;
                    rd_5 = 5'b0;
                end
                `U_TYPE_1: begin //lui
                    Branch = 1'b0;
                    MemRead = 1'b0;
                    MemtoReg = 1'b0;
                    MemWrite = 1'b0;
                    ALUSrc = 1'b1;
                    RegWrite = 1'b1;
                    Ecall = 1'b0;
                    ALUOp_4 = `ALUOP_LUI;
                    jump_and_link = 1'b0;
                    jump_and_link_register = 1'b0;
                    Ecall = 1'b0;
                    rs1_5 = 5'b0;
                    rs2_5 = 5'b0;
                    rd_5 = 5'b0;
                end
                `U_TYPE_2: begin //auipc
                    Branch = 1'b0;
                    MemRead = 1'b0;
                    MemtoReg = 1'b0;
                    MemWrite = 1'b0;
                    ALUSrc = 1'b1;
                    RegWrite = 1'b1;
                    Ecall = 1'b0;
                    ALUOp_4 = `ALUOP_AUIPC;
                    jump_and_link = 1'b0;
                    jump_and_link_register = 1'b0;
                    Ecall = 1'b0;
                    rs1_5 = 5'b0;
                    rs2_5 = 5'b0;
                    rd_5 = 5'b0;
                end
                `ECALL: begin
                    Branch = 1'b0;
                    ALUSrc = 1'b0;
                    Ecall = 1'b1;
                    ALUOp_4 = `ALUOP_ECALL;
                    jump_and_link = 1'b0;
                    jump_and_link_register = 1'b0;
                    Ecall = 1'b1;
                    if(a7==1'b0) begin//read
                        RegWrite = 1'b1;
                        MemRead = 1'b1;
                        MemtoReg = 1'b1;
                        MemWrite = 1'b0;
                        rs1_5 = 5'b0;
                        rs2_5 = 5'b0;
                        rd_5 = 5'b01010;//10 a0 reg
                    end else begin//write
                        RegWrite = 1'b0;
                        MemRead = 1'b0;
                        MemtoReg = 1'b0;
                        MemWrite = 1'b1;
                        rs1_5 = 5'b0;
                        rs2_5 = 5'b01010;//10 a0 reg
                        rd_5 = 5'b0;
                    end
                end
            endcase
        end else begin
           Branch = 1'b0;
           MemRead = 1'b0;
           MemtoReg = 1'b0;
           MemWrite = 1'b0;
           ALUSrc = 1'b0;
           RegWrite = 1'b0;
           Ecall = 1'b0;
           ALUOp_4 = 4'b0;
           jump_and_link = 1'b0;
           jump_and_link_register = 1'b0;
           Ecall = 1'b0;
           rs1_5 = 5'b0;
           rs2_5 = 5'b0;
           rd_5 = 5'b0;
        end
    end

endmodule
