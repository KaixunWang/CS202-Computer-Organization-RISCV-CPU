`timescale 1ns / 1ps
`include "defines.v"

module switch(
    input rst,
    input [2:0] switch_control_3,
    input [15:0] switch_read_16,
    output reg [31:0] switch_out_32
    );

    //100 load byte (read 8 bit from switch)
    //001 load testcase (read 3 bits from switch)
    //1111 1111 1111 1111 1111 1110 010x xx00
    always @(*) begin
        if (rst) begin
            switch_out_32 = 0;
        end else begin
            case(switch_control_3)
                3'b100: begin
                    switch_out_32 = {{24{switch_read_16[7]}},switch_read_16[7:0]};
                end //load 
                3'b001: begin
                    switch_out_32 = {29'b0, switch_read_16[15:13]};
                end //load testcase
                3'b101: begin
                    switch_out_32 = {31'b0, switch_read_16[8]};
                end //load enter
                default: begin
                    switch_out_32 = 0;
                end //default
            endcase
        end
    end
endmodule
