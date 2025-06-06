`timescale 1ns / 1ps
`include "defines.v"


module ins_fetch(
    input clk,
    input rst,
    input Branch,
    input zero, 
    input jump_and_link,
    input jump_and_link_register,
    input [31:0] rs1_32,
    input [31:0] immediate_32,
    output [31:0] instruction_32,
    output reg [31:0] pc_32,
    output reg execution_done
    );
    reg [31:0] pc_next_32;
    wire [31:0] pc_plus_4_32;
    assign pc_plus_4_32 = pc_32 + 4;
    reg [2:0] cnt;

    prgrom urom (
        .clka(~clk),
        .addra(pc_32[15:2]),
        .douta(instruction_32),
        .ena(!rst)
    );

    //PC next address calculation
    always @(*) begin
        if (jump_and_link_register) begin
            pc_next_32 = rs1_32 + immediate_32;
        end 
        else if ((Branch && zero) || jump_and_link) begin
            pc_next_32 = pc_32 + immediate_32;
        end else begin
            pc_next_32 = pc_plus_4_32;
        end
    end

    //PC update
always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_32 <= 32'b0;
            execution_done <= 1'b0;
            cnt <= 3'b0;
        end else if (execution_done) begin
            pc_32 <= pc_32;
            execution_done <= execution_done;
            cnt <= cnt;
        end else begin
            if (instruction_32 == 32'b0) begin
                if (cnt == 3'd3) begin
                    execution_done <= 1'b1;
                end else begin
                    cnt <= cnt + 1;
                    pc_32 <= pc_next_32;
                end
            end else begin
                cnt <= 3'b0;
                pc_32 <= pc_next_32;
            end
        end
    end
    
endmodule
