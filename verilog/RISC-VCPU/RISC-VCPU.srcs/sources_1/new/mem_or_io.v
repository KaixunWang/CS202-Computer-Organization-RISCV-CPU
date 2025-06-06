`timescale 1ns / 1ps
`include "defines.v"

module mem_or_io(
    input [1:0] Ecall,
    input mem_read,
    input mem_write,
    input  [13:0] address_14,
    output reg [2:0] led_control_3,
    output reg [2:0] switch_control_3,
    output reg [2:0] seg_control_3
    );

    always @(*) begin
        /*
        led
        FFFFFE 000x xx00
        led_control_3: 3'b000 → 不控制
        led_control_3: 3'b010                写左 8 位 LED
        
        switch
        FFFFFE 010x xx00
        switch_control_3: 3'b000 → 不控制
        switch_control_3: 3'b100 → load 8 bit
        switch_control_3: 3'b001 → load 3 bit testcase
        switch_control_3: 3'b101 → load enter

        seg
        FFFFFE 100x xx00
        seg_control_3: 3'b000 → 不控制
        seg_control_3: 3'b001 → load number and show as hex
        seg_control_3: 3'b010 → load number and show as decimal

        */
    if (Ecall == 2'b11)
            led_control_3 = 3'b010;  // ecall触发
        else if (mem_write && address_14[13:3] == `LED_MEM) begin
            led_control_3 = address_14[2:0]; // 控制LED
        end else begin
            led_control_3 = 3'b000;
        end

     if (mem_write && address_14[13:3] == `SEG_MEM) begin
            seg_control_3 = address_14[2:0]; // 控制数码管
        end else begin
            seg_control_3 = 3'b000;
        end

    if(Ecall == 2'b10)
            switch_control_3 = 3'b100; // ecall触发
        else if (mem_read && address_14[13:3] == `SWITCH_MEM) begin
            switch_control_3 = address_14[2:0]; // 控制开关
        end else begin
            switch_control_3 = 3'b000;
        end


end
endmodule
