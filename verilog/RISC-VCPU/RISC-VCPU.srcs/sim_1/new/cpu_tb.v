`timescale 1ns / 1ps

module cpu_tb;

    // Inputs
    reg fpga_rst;
    reg fpga_clk;
    reg [15:0] switch_16;

    // Outputs
    wire [15:0] led_16;
    wire [7:0] seg_sel_8;
    wire [7:0] seg_tube0_8;
    wire [7:0] seg_tube1_8;

    // Instantiate the Unit Under Test (UUT)
    cpu uut (
        .fpga_rst(fpga_rst), 
        .fpga_clk(fpga_clk), 
        .switch_16(switch_16), 
        .led_16(led_16),
        .seg_sel_8(seg_sel_8),
        .seg_tube0_8(seg_tube0_8),
        .seg_tube1_8(seg_tube1_8)
    );

    // Clock generation: 10ns period (100MHz)
    always #5 fpga_clk = ~fpga_clk;

    initial begin
        // Initialize Inputs
        fpga_clk = 0;
        fpga_rst = 0;
        switch_16 = 16'b0;

        // Reset pulse
        #1000 fpga_rst = 1;

        #3000 switch_16 = 16'b1100_0000_0000_1000;
        #3000;
        switch_16 = 16'b1100_0001_0000_1000;//test case 6
        #30000;
        switch_16 = 16'b1100_0000_0000_1000;
        #3000;
        
    end


endmodule
