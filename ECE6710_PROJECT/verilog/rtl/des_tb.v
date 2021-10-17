`timescale 1ns / 100ps
`include "des_include.v"

module des_tb();

    reg i_clk, tb_send, tb_rst;
    reg [63:0] i_cleartext;
    reg [63:0] i_key;
    reg i_dv;
    wire [63:0] o_ciphertext;
    wire o_dv;
    integer errors, i;

    reg[63:0] testkeys [0:999];
    reg[63:0] teststrings [0:999];
    reg[63:0] expected [0:999];


    // This feeds inputs in
    task simulate_des_input;
        input [63:0] data;
        input [63:0] key;
        begin
            // Wait for negative edge of clock and then start setting inputs
            @(negedge i_clk);
            i_cleartext = data;
            i_key = key;
            i_dv = 1;
        end
    endtask

    reg[63:0] output_cntr = 0;

    // This expects outputs, performs a comparison
    always@(posedge i_clk) begin
		if (o_dv) begin
            if (expected[output_cntr] != o_ciphertext) begin
                $display("Error: Got output %x expected %x", o_ciphertext, expected[output_cntr]);
                errors = errors + 1;
            end
			output_cntr <= output_cntr + 1;
		end
    end

    des #()
    dut(.i_clk,
        .i_cleartext,
        .i_key,
        .i_dv,
        .o_ciphertext,
        .o_dv
    );

    // Clock
    initial begin
        i_clk = 0;
        forever begin
            #5  i_clk = ~i_clk;
        end
    end

    // Main test block
    initial begin
        $dumpfile("DES_TB.vcd");
        $dumpvars(0, des_tb);

        // These are the input and result comparisons
        // We use two files for input and a single file for expected output
        $readmemh("key_input.txt", testkeys);
        $readmemh("block_input.txt", teststrings);
        $readmemh("expected.txt", expected);

        errors = 0;
        $timeformat(-9, 0, " ns", 20);
        $display("*** Start of Simulation ***");
        for (i=0; i < 1000; i++) begin
            simulate_des_input(teststrings[i], testkeys[i]);
        end
        repeat (1000) @ (negedge i_clk);


        $display("*** Simulation done with %0d errors at time %0t ***", errors, $time);
        $finish;

    end


endmodule
