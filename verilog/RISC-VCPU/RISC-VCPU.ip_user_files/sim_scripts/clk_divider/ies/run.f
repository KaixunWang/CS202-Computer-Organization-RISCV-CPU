-makelib ies_lib/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "C:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../RISC-VCPU.srcs/sources_1/ip/clk_divider/clk_divider_clk_wiz.v" \
  "../../../../RISC-VCPU.srcs/sources_1/ip/clk_divider/clk_divider.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

