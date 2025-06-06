`timescale 1ns / 1ps
`include "defines.v"

module ins_decode(
    input clk,
    input rst,
    input [31:0] instruction_32,
    input [2:0] switch_control_3,
    input [31:0] data_from_ALU_32,
    input [31:0] data_from_mem_32,
    input [31:0] sw_data_32,
    output Branch,
    output MemRead,
    output MemtoReg,
    output MemWrite,
    output ALUSrc,
    output RegWrite,
    output [1:0] Ecall,
    output [3:0] ALUOp_4,
    output [6:0] funct7_7,
    output [2:0] funct3_3,
    output [31:0] reg_out1_32,
    output [31:0] reg_out2_32,
    output [31:0] immediate_32,
    output jump_and_link,
    output jump_and_link_register
    );


    wire [4:0] reg_index1_5;
    wire [4:0] reg_index2_5;
    wire [4:0] reg_rd_5;

    wire [4:0] index1_5;
    wire [4:0] index2_5;
    wire [4:0] indexrd_5;
    wire [6:0] opcode_7;

    ins_split IS(
        .instruction_32(instruction_32),
        .opcode_7(opcode_7),
        .rd_5(reg_rd_5),
        .funct3_3(funct3_3),
        .funct7_7(funct7_7),
        .rs1_5(reg_index1_5),
        .rs2_5(reg_index2_5),
        .immediate_32(immediate_32)
    );

    ins_control IC(
        .rst(rst),
        .opcode_7(opcode_7),
        .funct3_3(funct3_3),
        .funct7_7(funct7_7),
        .a7(Ecall[0]),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Ecall(Ecall[1]),
        .ALUOp_4(ALUOp_4),
        .jump_and_link(jump_and_link),
        .jump_and_link_register(jump_and_link_register),
        .rs1_5(index1_5),
        .rs2_5(index2_5),
        .rd_5(indexrd_5)
    );

    register REG(
        .rs1_id_5(Ecall[1] ? index1_5:reg_index1_5),
        .rs2_id_5(Ecall[1] ? index2_5:reg_index2_5),
        .rd_id_5(Ecall[1] ? indexrd_5:reg_rd_5),
        .RegWrite(RegWrite),
        .clk(clk),
        .rst(rst),
        .switch_control_3(switch_control_3),
        .opcode_7(opcode_7),
        .funct3_3(funct3_3),
        .mem_to_reg(MemtoReg),
        .mem_write_addr(data_from_ALU_32),
        .tmp_data(data_from_mem_32),
        .sw_data(sw_data_32),
        .rs1_data_32(reg_out1_32),
        .rs2_data_32(reg_out2_32),
        .a7(Ecall[0])
    );

endmodule
