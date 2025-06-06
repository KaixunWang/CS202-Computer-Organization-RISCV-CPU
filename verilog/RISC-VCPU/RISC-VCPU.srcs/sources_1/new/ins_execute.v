`timescale 1ns / 1ps
`include "defines.v"

module ins_execute(
        input [31:0] read_data1_32,
        input [31:0] read_data2_32,
        input [31:0] pc_32,
        input [31:0] imm_32,
        input [3:0] alu_op_4,
        input [6:0] funct7_7,
        input [2:0] funct3_3,
        input alu_src,
        output reg [31:0] alu_result_32,
        output reg zero
    );

    wire [4:0] alu_ctrl_5;
    wire [31:0] operand_32;
    reg [63:0] mul_result_64;

    assign operand_32 = (alu_src == 1'b0) ? read_data2_32 : imm_32;

    alu_control control (
        .aluop_4(alu_op_4),
        .funct7_7(funct7_7),
        .funct3_3(funct3_3),
        .immediate_32(imm_32),
        .alu_ctrl_5(alu_ctrl_5)
    );

    always @(*) begin
        case (alu_ctrl_5)
            `ALU_CTRL_ADD: begin
                alu_result_32 = read_data1_32 + operand_32;
            end
            `ALU_CTRL_SUB: begin
                alu_result_32 = read_data1_32 - operand_32;
            end
            `ALU_CTRL_AND: begin
                alu_result_32 = read_data1_32 & operand_32;
            end
            `ALU_CTRL_OR: begin
                alu_result_32 = read_data1_32 | operand_32;
            end
            `ALU_CTRL_XOR: begin
                alu_result_32 = read_data1_32 ^ operand_32;
            end
            `ALU_CTRL_SLT: begin
                alu_result_32 = ($signed(read_data1_32) < $signed(operand_32)) ? 1 : 0;
            end
            `ALU_CTRL_SLTU: begin
                alu_result_32 = ($unsigned(read_data1_32) < $unsigned(operand_32)) ? 1 : 0;
            end
            `ALU_CTRL_SLL: begin
                alu_result_32 = read_data1_32 << operand_32[4:0];
            end
            `ALU_CTRL_SRL: begin
                alu_result_32 = read_data1_32 >> operand_32[4:0];
            end
            `ALU_CTRL_MUL: begin
                mul_result_64 = read_data1_32 * operand_32;
                alu_result_32 = mul_result_64[31:0];
            end
            `ALU_CTRL_DIV: begin
                if (operand_32 == 0) begin
                    alu_result_32 = -1; // Handle division by zero
                end else begin
                    alu_result_32 = read_data1_32 / operand_32;
                end
            end
            `ALU_CTRL_JALR: begin
                alu_result_32 = pc_32+4;
            end
            `ALU_CTRL_JAL: begin
                alu_result_32 = pc_32 + 4;
            end
            `ALU_CTRL_LUI: begin
                alu_result_32 = imm_32<<12;
            end
            `ALU_CTRL_AUIPC: begin
                alu_result_32 = pc_32 + (imm_32<<12);
            end
            `ALU_CTRL_ECALL_READ: begin
                alu_result_32 = `SWITCH_TOTAL_MEM;
            end
            `ALU_CTRL_ECALL_WRITE: begin
                alu_result_32 = `LED_TOTAL_MEM;
            end
            default: begin
                alu_result_32 = 32'b0;
            end
        endcase

        if (alu_op_4 == `ALUOP_BTYPE) begin
    case (funct3_3)
        3'b000: zero = (alu_result_32 == 32'b0);  // BEQ
        3'b001: zero = (alu_result_32 != 32'b0);  // BNE
        3'b100: zero = ($signed(read_data1_32) < $signed(operand_32));  // BLT (signed)
        3'b101: zero = ($signed(read_data1_32) >= $signed(operand_32)); // BGE (signed)
        3'b110: zero = ($unsigned(read_data1_32) < $unsigned(operand_32));  // BLTU
        3'b111: zero = ($unsigned(read_data1_32) >= $unsigned(operand_32)); // BGEU
        default: zero = 1'b0;
    endcase
end
        else begin
            zero = 1'b0;
        end
    end
endmodule
