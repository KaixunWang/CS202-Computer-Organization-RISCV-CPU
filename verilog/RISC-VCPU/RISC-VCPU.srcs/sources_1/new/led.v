`timescale 1ns / 1ps
`include "defines.v"

module led(
    input clk,
    input rst,
    input [2:0] led_control_3,
    input [31:0] led_write_data_32,
    output reg [15:0] led_out_16
    );

    always @(posedge clk or posedge rst) begin 
        if(rst) begin
           led_out_16 <= 16'b0;
        end else begin
            case(led_control_3)
               3'b010: begin
                   led_out_16[15:8] <= led_write_data_32[7:0];
                     led_out_16[7:0] <= led_out_16[7:0];
               end //control LED left 8 bits
                default: begin
                     led_out_16 <= led_out_16;
                end //default
            endcase
        end
    end
endmodule
