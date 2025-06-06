`timescale 1ns / 1ps
`include "defines.v"

module debouncer (
    input clk,
    input k_in,
    output reg k_out
);
    reg k_reg;                // 上一拍的原始输入
    reg [31:0] delay_cnt;     // 延迟计数器
    reg k_state;              // 稳定状态缓存

    always @(posedge clk) begin
        k_reg <= k_in;
    end

    always @(posedge clk) begin
        if (k_in != k_reg) begin
            // 如果输入发生变化，重新开始计数
            delay_cnt <= `DEBOUNCER_DELAY;
        end else if (delay_cnt > 0) begin
            // 若输入稳定，则继续倒计数
            delay_cnt <= delay_cnt - 1;
        end
    end

    always @(posedge clk) begin
        // 如果倒计数完成，更新稳定状态
        if (delay_cnt == 0 && k_in != k_state) begin
            k_state <= k_in;
        end
        k_out <= k_state;
    end
endmodule
