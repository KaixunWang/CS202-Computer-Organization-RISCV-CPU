`include "defines.v"

module bin32_to_bcd8(
    input  [31:0] bin,
    output reg [31:0] bcd // 8位，每4位一位十进制
);
    integer i, j;
    reg [63:0] shift_reg;
    always @(*) begin
        shift_reg = 64'd0;
        if(bin[31] == 1'b1) begin
            // 如果是负数，补码转为正数
            shift_reg[31:0] = ~bin + 1;
            for (i = 0; i < 32; i = i + 1) begin
            // 对每一位BCD做加3判定
            for (j = 0; j < 8; j = j + 1) begin
                if (shift_reg[32 + j*4 +: 4] >= 5)
                    shift_reg[32 + j*4 +: 4] = shift_reg[32 + j*4 +: 4] + 3;
            end
            shift_reg = shift_reg << 1;
        end
        bcd = shift_reg[63:32];
        end else begin
            // 如果是正数，直接赋值
            shift_reg[31:0] = bin;
        for (i = 0; i < 32; i = i + 1) begin
            // 对每一位BCD做加3判定
            for (j = 0; j < 8; j = j + 1) begin
                if (shift_reg[32 + j*4 +: 4] >= 5)
                    shift_reg[32 + j*4 +: 4] = shift_reg[32 + j*4 +: 4] + 3;
            end
            shift_reg = shift_reg << 1;
        end
        bcd = shift_reg[63:32];
        end
        
    end
endmodule
