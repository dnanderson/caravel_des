module feistel_function(
    input [31:0] i_data,
    input [47:0] i_key,
    output [31:0] o_data
    );

    wire [47:0] expanded;
    wire [47:0] xor_result;
    wire[31:0] s_result;
    wire[31:0] permutation_result;


    // Expand input data from 32 to 48 bits
    // 32 1 2 3 4 5
    // 4 5 6 7 8 9
    // 8 9 10 11 12 13
    // 12 13 14 15 16 17
    // 16 17 18 19 20 21
    // 20 21 22 23 24 25
    // 24 25 26 27 28 29
    // 28 29 30 31 32 1
    wire [31:0] e;
    assign e = i_data;
    assign expanded =
        { e[0],  e[31], e[30], e[29], e[28], e[27],
          e[28], e[27], e[26], e[25], e[24], e[23],
          e[24], e[23], e[22], e[21], e[20], e[19],
          e[20], e[19], e[18], e[17], e[16], e[15],
          e[16], e[15], e[14], e[13], e[12], e[11],
          e[12], e[11], e[10], e[9],  e[8],  e[7],
          e[8],  e[7],  e[6],  e[5],  e[4],  e[3],
          e[4],  e[3],  e[2],  e[1],  e[0],  e[31]};

    // XOR Expanded input data with 48 bit key
    assign xor_result = expanded ^ i_key;

    // Perform substitution with 8 S-Boxes
    sbox sb(.i_data(xor_result),
           .o_data(s_result));

    // Do another permutation P
    wire [31:0] s;
    assign s = s_result;
    assign permutation_result =
        { s[16], s[25], s[12], s[11],
          s[3],  s[20], s[4],  s[15],
          s[31], s[17], s[9],  s[6],
          s[27], s[14], s[1],  s[22],
          s[30], s[24], s[8],  s[18],
          s[0],  s[5],  s[29], s[23],
          s[13], s[19], s[2],  s[26],
          s[10], s[21], s[28], s[7]};

    // Output
    assign o_data = permutation_result;

endmodule