
`timescale 1ns / 1ps

`include "defines.v"

module cpu(
    input fpga_rst, 
    input fpga_clk,               
    input [15:0] switch_16,

    output [15:0] led_16,
    output [7:0] seg_sel_8,
    output [7:0] seg_tube0_8,
    output [7:0] seg_tube1_8
    );
    // --- clock wires ---
    wire        clk;        // 6 MHz for CPU core
    wire        clk_mem;    // 48MHz for memory

    clk_divider u_clk_cpu (
        .clk_in1(fpga_clk),
        .clk_out1(clk),
        .clk_out2(clk_mem)
    );
    
    
    // --- debounce ---
    wire [15:0] switch_16_after_debounce;

    genvar i;
    generate
        for (i = 0; i < `SWITCH_NUMBER; i = i + 1) begin : debounce_switch
            debouncer u_debounce_switch (
                .clk(fpga_clk),
                .k_in(switch_16[i]),
                .k_out(switch_16_after_debounce[i])
            );
        end
    endgenerate

    // --- wire declaration ---
    wire [31:0] reg_out1_32;
    wire [31:0] reg_out2_32;
    wire [31:0] result_32;
    wire [31:0] instruction_32;
    wire [31:0] immediate_32;
    wire [31:0] pc_32;
    wire [31:0] pc_next_32;
    wire [31:0] pc_plus_4_32;
    wire branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write;
    wire [3:0] alu_op_4;
    wire [6:0] funct7_7;
    wire [2:0] funct3_3;
    wire zero, jump_and_link, jump_and_link_register;
    wire [2:0] switch_control_3;
    wire [2:0] led_control_3;
    wire [2:0] seg_control_3;
    wire [31:0] data_from_mem_32;
    wire [31:0] switch_data_32;
    wire execution_done;
    wire [1:0] ecall;

    // --- CPU core ---
    ins_fetch if_stage (
        .clk(clk),
        .rst(~fpga_rst),
        .Branch(branch),
        .zero(zero), 
        .jump_and_link(jump_and_link),
        .jump_and_link_register(jump_and_link_register),
        .rs1_32(reg_out1_32),
        .immediate_32(immediate_32),
        .instruction_32(instruction_32),
        .pc_32(pc_32),
        .execution_done(execution_done)
    );

    ins_decode id_stage (
        .clk(clk),
        .rst(~fpga_rst),
        .instruction_32(instruction_32),
        .switch_control_3(switch_control_3),
        .sw_data_32(switch_data_32),
        .data_from_ALU_32(result_32),
        .data_from_mem_32(data_from_mem_32),
        .Branch(branch),
        .MemRead(mem_read),
        .MemtoReg(mem_to_reg),
        .MemWrite(mem_write),
        .ALUSrc(alu_src),
        .RegWrite(reg_write),
        .Ecall(ecall),
        .ALUOp_4(alu_op_4),
        .funct7_7(funct7_7),
        .funct3_3(funct3_3),
        .reg_out1_32(reg_out1_32),
        .reg_out2_32(reg_out2_32),
        .immediate_32(immediate_32),
        .jump_and_link(jump_and_link),
        .jump_and_link_register(jump_and_link_register)
    );

    ins_execute ex_stage (
        .read_data1_32(reg_out1_32),
        .read_data2_32(reg_out2_32),
        .pc_32(pc_32),
        .imm_32(immediate_32),
        .alu_op_4(alu_op_4),
        .funct7_7(funct7_7),
        .funct3_3(funct3_3),
        .alu_src(alu_src),
        .alu_result_32(result_32),
        .zero(zero)
    );

    data_memory dmem (
        .clk(clk_mem),
        .rst(~fpga_rst),
        .MemRead(mem_read),
        .MemWrite(mem_write),
        .Ecall(ecall),
        .address_32(result_32),
        .write_data_32(reg_out2_32),
        .read_data_32(data_from_mem_32),
        .switch_control_3(switch_control_3),
        .led_control_3(led_control_3),
        .seg_control_3(seg_control_3)
    );
    
    led led_unit (
        .clk(clk),
        .rst(~fpga_rst),
        .led_control_3(led_control_3),
        .led_write_data_32(reg_out2_32),
        .led_out_16(led_16)
    );
    
    switch switch_unit (
        .rst(~fpga_rst),
        .switch_control_3(switch_control_3),
        .switch_read_16(switch_16_after_debounce),
        .switch_out_32(switch_data_32)
    );

    segment_display seg_unit (
        .clk(fpga_clk),
        .rst(~fpga_rst),
        .seg_input_32(reg_out2_32),
        .seg_control_3(seg_control_3),
        .seg_output_bank0_8(seg_tube0_8),
        .seg_output_bank1_8(seg_tube1_8),
        .seg_enable_8(seg_sel_8)
    );
endmodule