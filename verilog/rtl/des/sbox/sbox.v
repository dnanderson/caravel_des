`timescale 1ns / 100ps

module sbox(
    input [47:0] i_data,
    output [31:0] o_data
);

    sbox1 s1(i_data[47:42], o_data[31:28]);
    sbox2 s2(i_data[41:36], o_data[27:24]);
    sbox3 s3(i_data[35:30], o_data[23:20]);
    sbox4 s4(i_data[29:24], o_data[19:16]);
    sbox5 s5(i_data[23:18], o_data[15:12]);
    sbox6 s6(i_data[17:12], o_data[11:8]);
    sbox7 s7(i_data[11:6],  o_data[7:4]);
    sbox8 s8(i_data[5:0],   o_data[3:0]);

endmodule
