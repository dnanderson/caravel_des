`timescale 1ns / 100ps


module des(
    input i_clk,              // System clock
    input [63:0] i_cleartext,        
    input [63:0] i_key,
    input i_dv,               // Input data valid
    output [63:0] o_ciphertext,
    output o_dv           // Output data valid
    );

    wire [63:0] round_data [0:16];
    wire [47:0] round_key [0:16];
    wire round_dv [0:16];

    // Key shift schedule: 1 means shift 1, 0 means shift 2
    reg [16:0] SHIFT_SCHEDULE = 16'b1000000100000011;

    // Initial Permutation
    // 58 50 42 34 26 18 10 2
    // 60 52 44 36 28 20 12 4
    // 62 54 46 38 30 22 14 6
    // 64 56 48 40 32 24 16 8
    // 57 49 41 33 25 17 9 1
    // 59 51 43 35 27 19 11 3
    // 61 53 45 37 29 21 13 5
    // 63 55 47 39 31 23 15 7 

    // Perform initial permutation
    wire [63:0] ct;
    wire [63:0] initial_permutation;
    assign ct = i_cleartext;
    assign round_data[0] =
        { ct[6], ct[14], ct[22], ct[30], ct[38], ct[46], ct[54], ct[62],
          ct[4], ct[12], ct[20], ct[28], ct[36], ct[44], ct[52], ct[60],
          ct[2], ct[10], ct[18], ct[26], ct[34], ct[42], ct[50], ct[58],
          ct[0], ct[8],  ct[16], ct[24], ct[32], ct[40], ct[48], ct[56],
          ct[7], ct[15], ct[23], ct[31], ct[39], ct[47], ct[55], ct[63],
          ct[5], ct[13], ct[21], ct[29], ct[37], ct[45], ct[53], ct[61],
          ct[3], ct[11], ct[19], ct[27], ct[35], ct[43], ct[51], ct[59],
          ct[1], ct[9],  ct[17], ct[25], ct[33], ct[41], ct[49], ct[57]};

    wire[63:0] ik;
    assign ik = i_key;

    // Key permutation described here
    // C creation
    // 57 49 41 33 25 17 9
    // 1 58 50 42 34 26 18
    // 10 2 59 51 43 35 27
    // 19 11 3 60 52 44 36
    wire [27:0] round_c [0:16];
    assign round_c[0] = 
        { ik[7],  ik[15], ik[23], ik[31], ik[39], ik[47], ik[55],
          ik[63], ik[6],  ik[14], ik[22], ik[30], ik[38], ik[46],
          ik[54], ik[62], ik[5],  ik[13], ik[21], ik[29], ik[37],
          ik[45], ik[53], ik[61], ik[4],  ik[12], ik[20], ik[28]};

    // // D Creation
    // // 63 55 47 39 31 23 15
    // // 7 62 54 46 38 30 22
    // // 14 6 61 53 45 37 29
    // // 21 13 5 28 20 12 4 
    wire [27:0] round_d [0:16];
    assign round_d[0] =
        { ik[1],  ik[9],  ik[17], ik[25], ik[33], ik[41], ik[49],
          ik[57], ik[2],  ik[10], ik[18], ik[26], ik[34], ik[42],
          ik[50], ik[58], ik[3],  ik[11], ik[19], ik[27], ik[35],
          ik[43], ik[51], ik[59], ik[36], ik[44], ik[52], ik[60]};


    assign round_dv[0] = i_dv;

    // Make the copies of each round, and its respective round key generation
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            round rd (
                .i_clk(i_clk),
                .i_cleartext(round_data[i]),
                .i_key(round_key[i]),
                .i_dv(round_dv[i]),
                .o_ciphertext(round_data[i+1]),
                .o_dv(round_dv[i+1])
            );
            key_round krd (
                .i_clk(i_clk),
                .i_dv(round_dv[i]),
                .i_c(round_c[i]),
                .i_d(round_d[i]),
                .i_shift_indicator(SHIFT_SCHEDULE[i]),
                .o_rd_key(round_key[i]),
                .o_c(round_c[i+1]),
                .o_d(round_d[i+1])
            );
        end
    endgenerate

    // Final round output
    wire [63:0] fro;
    assign fro = {round_data[16][31:0], round_data[16][63:32]};
    // Assign output ciphertext as the final permutation
    assign o_ciphertext = 
    { fro[24], fro[56], fro[16], fro[48], fro[8],  fro[40], fro[0], fro[32],
      fro[25], fro[57], fro[17], fro[49], fro[9],  fro[41], fro[1], fro[33],
      fro[26], fro[58], fro[18], fro[50], fro[10], fro[42], fro[2], fro[34],
      fro[27], fro[59], fro[19], fro[51], fro[11], fro[43], fro[3], fro[35],
      fro[28], fro[60], fro[20], fro[52], fro[12], fro[44], fro[4], fro[36],
      fro[29], fro[61], fro[21], fro[53], fro[13], fro[45], fro[5], fro[37],
      fro[30], fro[62], fro[22], fro[54], fro[14], fro[46], fro[6], fro[38],
      fro[31], fro[63], fro[23], fro[55], fro[15], fro[47], fro[7], fro[39]};

    assign o_dv = round_dv[16];

endmodule