`timescale 1ns / 100ps

// 2. Transmit block for uart
// This is the test bench

module tb_des();

    reg i_clk, tb_send, tb_rst;
    reg [63:0] i_cleartext;
    reg [63:0] i_key;
    reg i_dv;
    wire [63:0] o_ciphertext;
    wire o_dv;
    integer errors, b_errors, i;

    reg[63:0] teststring = "12345678";
    reg[63:0] testkey = "12345678";

    task simulate_des_input;
        input [63:0] data;
        input [63:0] key;
        begin

            b_errors = errors;

            // Wait for negative edge of clock and then start setting inputs
            @(negedge i_clk);
            i_cleartext = data;
            i_key = key;
            i_dv = 1;
            @(posedge o_dv);
            $display("0x%h at time %0t", o_ciphertext, $time);
        end
    endtask

    des #()
    dut(.i_clk,
        .i_cleartext,
        .i_key,
        .i_dv,               // Input data valid
        .o_ciphertext,
        .o_dv           // Output data valid
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
        $dumpfile("out.vcd");
        $dumpvars;

        errors = 0;
        $timeformat(-9, 0, " ns", 20);
        $display("*** Start of Simulation ***");

        simulate_des_input(teststring, teststring);
        repeat (20000) @ (negedge i_clk);

        $display("*** Simulation done with %0d errors at time %0t ***", errors, $time);
        $finish;

    end  // end initial begin


endmodule