pushd .
python3 prepare_des_results.py
cd ../verilog/rtl
rm -f ./DES_TB.out
rm -f ./DES_TB.vcd
#iverilog -g2001 -Wall -I . -o DES_TB.out des_tb.v
#vvp DES_TB.out
iverilog -g2001 -Wall -I . -o DES_TB.out des_decrypt_tb.v
vvp DES_TB.out
popd

