// This round is repeated 16 different times in the main algorithm of DES

module round(
    input i_clk,              // System clock
    input [63:0] i_cleartext,        
    input [47:0] i_key,
    input i_dv,               // Input data valid
    output reg [63:0] o_ciphertext,
    output reg o_dv           // Output data valid
    );

    wire [31:0] s_lefthalf;
    wire [31:0] s_righthalf;

    wire [63:0] s_round_output;
    wire [31:0] s_feistel_output;
    wire [31:0] xor_result;


    assign s_righthalf = i_cleartext[31:0];
    assign s_lefthalf = i_cleartext[63:32];

    // Instantiate the DES feistel function

    feistel_function f(
        .i_key(i_key), 
        .i_data(s_righthalf),
        .o_data(s_feistel_output)
        );

    // XOR the output of the Feistel function
    assign xor_result = s_feistel_output ^ s_lefthalf;


    // xor_result becomes new right
    // Right side comes down untouched
    assign s_round_output = {s_righthalf, xor_result};


    // Register the output data from the XOR for output
    always@(posedge i_clk) begin
        if (i_dv) begin
            o_ciphertext <= s_round_output;
            o_dv <= 1;
        end
        else begin
            o_ciphertext = 0;
            o_dv <= 0;
        end
    end


endmodule