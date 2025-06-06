`timescale 1ns / 1ps
`include "defines.v"

module register (
    input [4:0] rs1_id_5,
    input [4:0] rs2_id_5,
    input [4:0] rd_id_5,
    input RegWrite,
    input clk,
    input rst,
    input [2:0]switch_control_3,
    input mem_to_reg,
    input [31:0]mem_write_addr,
    input [31:0]tmp_data,
    input [31:0]sw_data,
    input [6:0] opcode_7,
    input [2:0] funct3_3,
    output  [31:0] rs1_data_32,
    output  [31:0] rs2_data_32,
    output a7
);
    reg [31:0] Reg[0:31];
    integer i;

    reg [31:0] w_data_32;
    
    always @(*)begin
        if(switch_control_3!=3'b000)begin
            w_data_32 =sw_data;
        end else if (mem_to_reg) begin
            w_data_32= tmp_data;
        end else begin
            w_data_32= mem_write_addr;
        end
    end  
    
    assign rs1_data_32 = Reg[rs1_id_5];
    assign rs2_data_32 = Reg[rs2_id_5];
    assign a7 = Reg[17][0];

    always@ (posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                if(i == 2) begin
                    Reg[i] <= `SP_INITIAL;
                end else begin
                    Reg[i] <= 32'b0;
                end
            end
        end else if (RegWrite && rd_id_5 != 5'b0) begin
            if(opcode_7 == `I_TYPE_2) begin
                if(funct3_3 == `LB_FUNCT3) begin //lb
                    Reg[rd_id_5] <= {{24{w_data_32[7]}}, w_data_32[7:0]};
                end else if(funct3_3 == `LBU_FUNCT3) begin //lbu
                    Reg[rd_id_5] <= {{24'b0}, w_data_32[7:0]};
                end else begin //lw
                    Reg[rd_id_5] <= w_data_32;
                end
            end else begin
                Reg[rd_id_5] <= w_data_32;
            end
        end
    end
endmodule