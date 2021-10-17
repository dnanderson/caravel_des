rm -f ./DES_TB.out
rm -f ./DES_TB.vcd
pushd .
cd ../../verilog/rtl
iverilog -g2001 -Wall -I . -o DES_TB.out des_tb.v
vvp DES_TB.out
popd

