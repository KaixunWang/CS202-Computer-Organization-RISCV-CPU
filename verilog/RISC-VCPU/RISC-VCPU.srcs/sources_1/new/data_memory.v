`timescale 1ns / 1ps
`include "defines.v"

module data_memory(
    input clk,
    input rst,
    input MemRead,
    input MemWrite,
    input [1:0] Ecall,
    input [31:0] address_32,
    input [31:0] write_data_32,
    output [31:0] read_data_32,
    output [2:0] switch_control_3,
    output [2:0] led_control_3,
    output [2:0] seg_control_3
    );

    wire is_io_addr = 
    ((MemWrite && address_32[15:5] == `LED_MEM) || (MemWrite && address_32[15:5] == `SEG_MEM) || (MemRead && address_32[15:5] == `SWITCH_MEM));
    
    data_ram u_ram (
        .clka(clk),
        .wea(MemWrite && !is_io_addr),
        .addra(address_32[15:2]),
        .dina(write_data_32),
        .douta(read_data_32)
    );
    
    mem_or_io u_mem_or_io (
        .Ecall(Ecall),
        .mem_read(MemRead),
        .mem_write(MemWrite),
        .address_14(address_32[15:2]),
        .led_control_3(led_control_3),
        .switch_control_3(switch_control_3),
        .seg_control_3(seg_control_3)
    );
endmodule
