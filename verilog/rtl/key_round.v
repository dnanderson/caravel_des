module key_round(
    input i_clk,              // System clock
    input i_dv,               // Input data valid
    input [27:0] i_c,
    input [27:0] i_d,
    input i_shift_indicator,
    output [47:0] o_rd_key,
    output reg [27:0] o_c,
    output reg [27:0] o_d
    );

    reg [27:0] shift_i_c;
    reg [27:0] shift_i_d;

    // Perform a bit rotation
    always@ (i_c, i_d) begin
        if (i_shift_indicator) begin
            shift_i_c <= {i_c[26:0], i_c[27]};
            shift_i_d <= {i_d[26:0], i_d[27]};
        end
        else begin
            shift_i_c <= {i_c[25:0], i_c[27:26]};
            shift_i_d <= {i_d[25:0], i_d[27:26]};
        end
    end

    // key permutation 2 described here, 1-indexed starting from bit 0 up
    // Below is reversed and zero indexed to assign correctly
    //   14 17 11 24 1 5
    //   3 28 15 6 21 10
    //   23 19 12 4 26 8
    //   16 7 27 20 13 2
    //   41 52 31 37 47 55
    //   30 40 51 45 33 48
    //   44 49 39 56 34 53
    //   46 42 50 36 29 32

    // Permute and assign rd_key
    wire [55:0] p;
    assign p = {shift_i_c, shift_i_d};
    assign o_rd_key =
    { p[31], p[28], p[35], p[49], p[41], p[45],
      p[52], p[33], p[55], p[38], p[48], p[43],
      p[47], p[32], p[44], p[50], p[39], p[29],
      p[54], p[46], p[36], p[30], p[51], p[40],
      p[1],  p[12], p[19], p[26], p[6],  p[15],
      p[7],  p[25], p[3],  p[11], p[18], p[22],
      p[9],  p[20], p[5],  p[14], p[27], p[2],
      p[4],  p[0],  p[23], p[10], p[16], p[13]};


    always@(posedge i_clk) begin
        if(i_dv) begin
            o_c = shift_i_c;
            o_d = shift_i_d;
        end
    end

endmodule