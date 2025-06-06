module cpuclk_tb(  );  // a reference testbench for 'cpuclk' 
reg clkin;
 wire clkout;
 clk_cpu_23MHz ucpu( .clk_in1(clkin), .clk_out1(clkout) );
 initial        
clkin = 1'b0;
 always #5 clkin=~clkin;
 endmodule