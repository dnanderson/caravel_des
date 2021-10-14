rm -f ./DES_TB.out
rm -f ./DES_TB.vcd
iverilog -g2001 -Wall -I ../../verilog/rtl -o DES_TB.out ../../verilog/rtl/des_tb.v
vvp DES_TB.out

