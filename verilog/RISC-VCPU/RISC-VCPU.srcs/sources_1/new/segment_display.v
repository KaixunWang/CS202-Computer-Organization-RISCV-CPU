// `timescale 1ns / 1ps
// `include "defines.v"

// module segment_display(
//     input clk,
//     input rst,
//     input [31:0] seg_input_32,
//     input [2:0] seg_control_3,
//     output reg [7:0] seg_output_bank0_8,
//     output reg [7:0] seg_output_bank1_8,
//     output reg [7:0] seg_enable_8
//     );

//     reg [3:0] seg_digits[7:0]; // 8位拆解后的数据
//     reg [3:0] cur_nibble;
//     reg [31:0] cnt;
//     reg [2:0] divider;
//     reg clk_500hz;
//     reg [3:0] decimal_digits[7:0];

//     parameter cycle_time = `SEG_CYCLE_TIME;

//     // 分频器：生成500Hz时钟
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             clk_500hz <= 0;
//             cnt <= 0;
//         end else begin
//             if (cnt == cycle_time - 1) begin
//                 clk_500hz <= ~clk_500hz;
//                 cnt <= 0;
//             end else begin
//                 cnt <= cnt + 1;
//             end
//         end
//     end

//     // 刷新位选择
//     always @(posedge clk_500hz or posedge rst) begin
//         if (rst) begin
//             divider <= 0;
//         end else begin
//             if (divider == 3'd7)
//                 divider <= 0;
//             else
//                 divider <= divider + 1;
//         end
//     end

//     // 根据显示控制信号拆分输入数据
//     integer i;
//     reg [31:0] tmp_decimal0;
//     reg [31:0] tmp_decimal1;
//     reg [31:0] tmp_decimal2;
//     reg [31:0] tmp_decimal3;
//     reg [31:0] tmp_decimal4;
//     reg [31:0] tmp_decimal5;
//     reg [31:0] tmp_decimal6;
//     reg [31:0] tmp_decimal7;
    
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             for (i = 0; i < 8; i = i + 1)
//                 seg_digits[i] <= 4'd0;
//         end else begin
//             case (seg_control_3)
//                 3'b001: begin
//                 // HEX
//                 seg_digits[0] <= seg_input_32[3:0];
//                 seg_digits[1] <= seg_input_32[7:4];
//                 seg_digits[2] <= seg_input_32[11:8];
//                 seg_digits[3] <= seg_input_32[15:12];
//                 seg_digits[4] <= seg_input_32[19:16];
//                 seg_digits[5] <= seg_input_32[23:20];
//                 seg_digits[6] <= seg_input_32[27:24];
//                 seg_digits[7] <= seg_input_32[31:28];
//             end
//             3'b010: begin
//                 tmp_decimal0 = seg_input_32;
//                 tmp_decimal1 = tmp_decimal0 / 10;
//                 tmp_decimal2 = tmp_decimal1 / 10;
//                 tmp_decimal3 = tmp_decimal2 / 10;
//                 tmp_decimal4 = tmp_decimal3 / 10;
//                 tmp_decimal5 = tmp_decimal4 / 10;
//                 tmp_decimal6 = tmp_decimal5 / 10;
//                 tmp_decimal7 = tmp_decimal6 / 10;
//                 seg_digits[0] <= tmp_decimal0 % 10;
//                 seg_digits[1] <= tmp_decimal1 % 10;
//                 seg_digits[2] <= tmp_decimal2 % 10;
//                 seg_digits[3] <= tmp_decimal3 % 10;
//                 seg_digits[4] <= tmp_decimal4 % 10;
//                 seg_digits[5] <= tmp_decimal5 % 10;
//                 seg_digits[6] <= tmp_decimal6 % 10;
//                 seg_digits[7] <= tmp_decimal7 % 10;
//             end
//                 default: begin //remains the same 
//                 seg_digits[0] <= seg_digits[0];
//                 seg_digits[1] <= seg_digits[1];
//                 seg_digits[2] <= seg_digits[2];
//                 seg_digits[3] <= seg_digits[3];
//                 seg_digits[4] <= seg_digits[4];
//                 seg_digits[5] <= seg_digits[5];
//                 seg_digits[6] <= seg_digits[6];
//                 seg_digits[7] <= seg_digits[7];
//                 end
//             endcase
//         end
//     end

//     // 分别赋值给 seg0 ~ seg7
//     wire [3:0] seg0 = seg_digits[0];
//     wire [3:0] seg1 = seg_digits[1];
//     wire [3:0] seg2 = seg_digits[2];
//     wire [3:0] seg3 = seg_digits[3];
//     wire [3:0] seg4 = seg_digits[4];
//     wire [3:0] seg5 = seg_digits[5];
//     wire [3:0] seg6 = seg_digits[6];
//     wire [3:0] seg7 = seg_digits[7];

//     // 显示逻辑：根据轮询刷新显示
//     always @(*) begin
//         cur_nibble = 4'b0000;
//         seg_enable_8 = 8'b0000_0000;
//         seg_output_bank0_8 = 8'b0000_0000;
//         seg_output_bank1_8 = 8'b0000_0000;

//         case (divider)
//             3'd0: begin cur_nibble = seg0; seg_enable_8 = 8'b0000_0001; end
//             3'd1: begin cur_nibble = seg1; seg_enable_8 = 8'b0000_0010; end
//             3'd2: begin cur_nibble = seg2; seg_enable_8 = 8'b0000_0100; end
//             3'd3: begin cur_nibble = seg3; seg_enable_8 = 8'b0000_1000; end
//             3'd4: begin cur_nibble = seg4; seg_enable_8 = 8'b0001_0000; end
//             3'd5: begin cur_nibble = seg5; seg_enable_8 = 8'b0010_0000; end
//             3'd6: begin cur_nibble = seg6; seg_enable_8 = 8'b0100_0000; end
//             3'd7: begin cur_nibble = seg7; seg_enable_8 = 8'b1000_0000; end
//             default: begin
//                 seg_enable_8 = 8'b0000_0000;
//             end
//         endcase

//         if (divider < 4)
//             seg_output_bank0_8 = decode(cur_nibble);
//         else
//             seg_output_bank1_8 = decode(cur_nibble);
//     end

//     // 数码管编码函数
//     function [7:0] decode(input [3:0] nib);
//         case (nib)
//             `SEG_0 : decode = `SEG_0_VAL;
//             `SEG_1 : decode = `SEG_1_VAL;
//             `SEG_2 : decode = `SEG_2_VAL;
//             `SEG_3 : decode = `SEG_3_VAL;
//             `SEG_4 : decode = `SEG_4_VAL;
//             `SEG_5 : decode = `SEG_5_VAL;
//             `SEG_6 : decode = `SEG_6_VAL;
//             `SEG_7 : decode = `SEG_7_VAL;
//             `SEG_8 : decode = `SEG_8_VAL;
//             `SEG_9 : decode = `SEG_9_VAL;
//             `SEG_A : decode = `SEG_A_VAL;
//             `SEG_B : decode = `SEG_B_VAL;
//             `SEG_C : decode = `SEG_C_VAL;
//             `SEG_D : decode = `SEG_D_VAL;
//             `SEG_E : decode = `SEG_E_VAL;
//             `SEG_F : decode = `SEG_F_VAL;
//             default: decode = 8'b00000000;
//         endcase
//     endfunction

// endmodule


// `timescale 1ns / 1ps
// `include "defines.v"

// module segment_display(
//     input clk,
//     input rst,
//     input [31:0] seg_input_32,
//     input [2:0] seg_control_3,
//     output reg [7:0] seg_output_bank0_8,
//     output reg [7:0] seg_output_bank1_8,
//     output reg [7:0] seg_enable_8
//     );

//     reg [3:0] seg_digits[7:0];
//     reg [3:0] seg_digits_buffer[7:0];
//     reg [3:0] cur_nibble;
//     reg [31:0] cnt;
//     reg [2:0] divider;
//     reg clk_500hz;

//     parameter cycle_time = `SEG_CYCLE_TIME;

//     // 分频器：生成500Hz时钟
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             clk_500hz <= 0;
//             cnt <= 0;
//         end else begin
//             if (cnt == cycle_time - 1) begin
//                 clk_500hz <= ~clk_500hz;
//                 cnt <= 0;
//             end else begin
//                 cnt <= cnt + 1;
//             end
//         end
//     end

//     // 刷新位选择
//     always @(posedge clk_500hz or posedge rst) begin
//         if (rst) begin
//             divider <= 0;
//         end else begin
//             if (divider == 3'd7)
//                 divider <= 0;
//             else
//                 divider <= divider + 1;
//         end
//     end

//     // 组合逻辑：根据显示控制信号拆分输入数据到 buffer
//     integer i;
//     reg [31:0] tmp;

//     always @(*) begin
//         for (i = 0; i < 8; i = i + 1)
//             seg_digits_buffer[i] = 4'd0;

//         case (seg_control_3)
//             3'b001: begin // HEX
//                 for (i = 0; i < 8; i = i + 1)
//                     seg_digits_buffer[i] = seg_input_32[i*4 +: 4];
//             end
//             3'b010: begin // DEC
//                 tmp = seg_input_32;
//                 for (i = 0; i < 8; i = i + 1) begin
//                     seg_digits_buffer[i] = tmp % 10;
//                     tmp = tmp / 10;
//                 end
//             end
//             default: begin
//                 // 保持原值
//                 for (i = 0; i < 8; i = i + 1)
//                     seg_digits_buffer[i] = seg_digits[i];
//             end
//         endcase
//     end

//     // 时序逻辑：同步 buffer 内容到 seg_digits
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             for (i = 0; i < 8; i = i + 1)
//                 seg_digits[i] <= 4'd0;
//         end else begin
//             for (i = 0; i < 8; i = i + 1)
//                 seg_digits[i] <= seg_digits_buffer[i];
//         end
//     end

//     // 取出当前 nibble
//     wire [3:0] seg0 = seg_digits[0];
//     wire [3:0] seg1 = seg_digits[1];
//     wire [3:0] seg2 = seg_digits[2];
//     wire [3:0] seg3 = seg_digits[3];
//     wire [3:0] seg4 = seg_digits[4];
//     wire [3:0] seg5 = seg_digits[5];
//     wire [3:0] seg6 = seg_digits[6];
//     wire [3:0] seg7 = seg_digits[7];

//     // 显示逻辑：轮询刷新
//     always @(*) begin
        
//         cur_nibble = 4'b0000;
//         seg_enable_8 = 8'b00000000;
//         seg_output_bank0_8 = 8'b00000000;
//         seg_output_bank1_8 = 8'b00000000;

//         case (divider)
//             3'd0: begin cur_nibble = seg0; seg_enable_8 = 8'b00000001; end
//             3'd1: begin cur_nibble = seg1; seg_enable_8 = 8'b00000010; end
//             3'd2: begin cur_nibble = seg2; seg_enable_8 = 8'b00000100; end
//             3'd3: begin cur_nibble = seg3; seg_enable_8 = 8'b00001000; end
//             3'd4: begin cur_nibble = seg4; seg_enable_8 = 8'b00010000; end
//             3'd5: begin cur_nibble = seg5; seg_enable_8 = 8'b00100000; end
//             3'd6: begin cur_nibble = seg6; seg_enable_8 = 8'b01000000; end
//             3'd7: begin cur_nibble = seg7; seg_enable_8 = 8'b10000000; end
//         endcase

//         if (divider < 4)
//             seg_output_bank0_8 = decode(cur_nibble);
//         else
//             seg_output_bank1_8 = decode(cur_nibble);
//     end

//     // 数码管编码函数
//     function [7:0] decode(input [3:0] nib);
//         case (nib)
//             `SEG_0 : decode = `SEG_0_VAL;
//             `SEG_1 : decode = `SEG_1_VAL;
//             `SEG_2 : decode = `SEG_2_VAL;
//             `SEG_3 : decode = `SEG_3_VAL;
//             `SEG_4 : decode = `SEG_4_VAL;
//             `SEG_5 : decode = `SEG_5_VAL;
//             `SEG_6 : decode = `SEG_6_VAL;
//             `SEG_7 : decode = `SEG_7_VAL;
//             `SEG_8 : decode = `SEG_8_VAL;
//             `SEG_9 : decode = `SEG_9_VAL;
//             `SEG_A : decode = `SEG_A_VAL;
//             `SEG_B : decode = `SEG_B_VAL;
//             `SEG_C : decode = `SEG_C_VAL;
//             `SEG_D : decode = `SEG_D_VAL;
//             `SEG_E : decode = `SEG_E_VAL;
//             `SEG_F : decode = `SEG_F_VAL;
//             default: decode = 8'b00000000;
//         endcase
//     endfunction

// endmodule


`timescale 1ns / 1ps
`include "defines.v"

module segment_display(
    input clk,
    input rst,
    input [31:0] seg_input_32,
    input [2:0] seg_control_3,
    output reg [7:0] seg_output_bank0_8,
    output reg [7:0] seg_output_bank1_8,
    output reg [7:0] seg_enable_8
    );

    reg [3:0] seg_digits[7:0];
    reg [3:0] seg_digits_buffer[7:0];
    reg [3:0] cur_nibble;
    reg [31:0] cnt;
    reg [2:0] divider;
    reg clk_500hz;
    reg [7:0] seg_output;

    parameter cycle_time = `SEG_CYCLE_TIME;
    wire [31:0] bcd;

    bin32_to_bcd8 BCD(
        .bin(seg_input_32),
        .bcd(bcd)
    );

    // 分频器：生成500Hz时钟
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_500hz <= 0;
            cnt <= 0;
        end else begin
            if (cnt == cycle_time - 1) begin
                clk_500hz <= ~clk_500hz;
                cnt <= 0;
            end else begin
                cnt <= cnt + 1;
            end
        end
    end

    // 刷新位选择
    always @(posedge clk_500hz or posedge rst) begin
        if (rst) begin
            divider <= 0;
        end else begin
            if (divider == 3'd7)
                divider <= 0;
            else
                divider <= divider + 1;
        end
    end

    // 组合逻辑：根据显示控制信号拆分输入数据到 buffer
    reg [31:0] tmp;
    always @(*) begin
        seg_digits_buffer[0] = 4'd0;
        seg_digits_buffer[1] = 4'd0;
        seg_digits_buffer[2] = 4'd0;
        seg_digits_buffer[3] = 4'd0;
        seg_digits_buffer[4] = 4'd0;
        seg_digits_buffer[5] = 4'd0;
        seg_digits_buffer[6] = 4'd0;
        seg_digits_buffer[7] = 4'd0;

        case (seg_control_3)
            3'b001: begin // HEX
                seg_digits_buffer[0] = seg_input_32[3:0];
                seg_digits_buffer[1] = seg_input_32[7:4];
                seg_digits_buffer[2] = seg_input_32[11:8];
                seg_digits_buffer[3] = seg_input_32[15:12];
                seg_digits_buffer[4] = seg_input_32[19:16];
                seg_digits_buffer[5] = seg_input_32[23:20];
                seg_digits_buffer[6] = seg_input_32[27:24];
                seg_digits_buffer[7] = seg_input_32[31:28];
            end
            3'b010: begin // DEC
                seg_digits_buffer[0] = bcd[3:0];
                seg_digits_buffer[1] = bcd[7:4];
                seg_digits_buffer[2] = bcd[11:8];
                seg_digits_buffer[3] = bcd[15:12];
                seg_digits_buffer[4] = bcd[19:16];
                seg_digits_buffer[5] = bcd[23:20];
                seg_digits_buffer[6] = bcd[27:24];
                seg_digits_buffer[7] = bcd[31:28];
            end
            default: begin
                seg_digits_buffer[0] = seg_digits[0];
                seg_digits_buffer[1] = seg_digits[1];
                seg_digits_buffer[2] = seg_digits[2];
                seg_digits_buffer[3] = seg_digits[3];
                seg_digits_buffer[4] = seg_digits[4];
                seg_digits_buffer[5] = seg_digits[5];
                seg_digits_buffer[6] = seg_digits[6];
                seg_digits_buffer[7] = seg_digits[7];
            end
        endcase
    end

    // 时序逻辑：同步 buffer 内容到 seg_digits
    always @(posedge clk or posedge rst) begin
    if (rst) begin
        seg_digits[0] <= 4'd0;
        seg_digits[1] <= 4'd0;
        seg_digits[2] <= 4'd0;
        seg_digits[3] <= 4'd0;
        seg_digits[4] <= 4'd0;
        seg_digits[5] <= 4'd0;
        seg_digits[6] <= 4'd0;
        seg_digits[7] <= 4'd0;
    end else begin
        seg_digits[0] <= seg_digits_buffer[0];
        seg_digits[1] <= seg_digits_buffer[1];
        seg_digits[2] <= seg_digits_buffer[2];
        seg_digits[3] <= seg_digits_buffer[3];
        seg_digits[4] <= seg_digits_buffer[4];
        seg_digits[5] <= seg_digits_buffer[5];
        seg_digits[6] <= seg_digits_buffer[6];
        seg_digits[7] <= seg_digits_buffer[7];
    end
end

    // 取出当前 nibble
    wire [3:0] seg0 = seg_digits[0];
    wire [3:0] seg1 = seg_digits[1];
    wire [3:0] seg2 = seg_digits[2];
    wire [3:0] seg3 = seg_digits[3];
    wire [3:0] seg4 = seg_digits[4];
    wire [3:0] seg5 = seg_digits[5];
    wire [3:0] seg6 = seg_digits[6];
    wire [3:0] seg7 = seg_digits[7];

    // 显示逻辑：轮询刷新
    always @(*) begin
        cur_nibble = 4'b0000;
        seg_enable_8 = 8'b00000000;
        seg_output_bank0_8 = 8'b00000000;
        seg_output_bank1_8 = 8'b00000000;

        case (divider)
            3'd0: begin cur_nibble = seg0; seg_enable_8 = 8'b00000001; end
            3'd1: begin cur_nibble = seg1; seg_enable_8 = 8'b00000010; end
            3'd2: begin cur_nibble = seg2; seg_enable_8 = 8'b00000100; end
            3'd3: begin cur_nibble = seg3; seg_enable_8 = 8'b00001000; end
            3'd4: begin cur_nibble = seg4; seg_enable_8 = 8'b00010000; end
            3'd5: begin cur_nibble = seg5; seg_enable_8 = 8'b00100000; end
            3'd6: begin cur_nibble = seg6; seg_enable_8 = 8'b01000000; end
            3'd7: begin cur_nibble = seg7; seg_enable_8 = 8'b10000000; end
        endcase

        case (cur_nibble)
            `SEG_0 : seg_output = `SEG_0_VAL;
            `SEG_1 : seg_output = `SEG_1_VAL;
            `SEG_2 : seg_output = `SEG_2_VAL;
            `SEG_3 : seg_output = `SEG_3_VAL;
            `SEG_4 : seg_output = `SEG_4_VAL;
            `SEG_5 : seg_output = `SEG_5_VAL;
            `SEG_6 : seg_output = `SEG_6_VAL;
            `SEG_7 : seg_output = `SEG_7_VAL;
            `SEG_8 : seg_output = `SEG_8_VAL;
            `SEG_9 : seg_output = `SEG_9_VAL;
            `SEG_A : seg_output = `SEG_A_VAL;
            `SEG_B : seg_output = `SEG_B_VAL;
            `SEG_C : seg_output = `SEG_C_VAL;
            `SEG_D : seg_output = `SEG_D_VAL;
            `SEG_E : seg_output = `SEG_E_VAL;
            `SEG_F : seg_output = `SEG_F_VAL;
            default: seg_output = 8'b00000000;
        endcase

        if (divider < 4)
            seg_output_bank0_8 = seg_output;
        else
            seg_output_bank1_8 = seg_output;
    end

endmodule