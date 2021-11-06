`default_nettype none

module des_top #(
    parameter   [31:0]  BASE_ADDRESS    = 32'h3000_0000,        // base address
    parameter   [31:0]  STAGING_INPUT_ADDR = BASE_ADDRESS,
    parameter   [31:0]  STAGING_OUTPUT_ADDR  = BASE_ADDRESS + 8,
    parameter   [31:0]  KEY_ADDR  = STAGING_OUTPUT_ADDR + 8,
    parameter   [31:0] CTRL_ADDR = KEY_ADDR + 8,
    parameter   [31:0] STS_ADDR = CTRL_ADDR + 4
    ) (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif
    input wire          clk,
    input wire          reset,

    // wb interface
    input wire          i_wb_cyc,       // wishbone transaction
    input wire          i_wb_stb,       // strobe - data valid and accepted as long as !o_wb_stall
    input wire          i_wb_we,        // write enable
    input wire  [31:0]  i_wb_addr,      // address
    input wire  [31:0]  i_wb_data,      // incoming data
    output reg          o_wb_ack,       // request is completed 
    output wire         o_wb_stall,     // cannot accept req
    output reg  [31:0]  o_wb_data      // output data

    );

    reg [63:0] staging_input; // Staging memory
    reg [63:0] staging_output;
    reg [63:0] key;
    reg [31:0] ctrl; // Control register
    reg [31:0] sts; // Status register
    wire [63:0] o_ciphertext;
    wire o_dv;


    assign o_wb_stall = 0;

    // writes
    always @(posedge clk) begin
        if(reset) begin
            staging_input <= 0; // Staging memory
            ctrl <= 0; // Control register
        end
        else if (i_wb_stb && i_wb_cyc && i_wb_we && !o_wb_stall && (i_wb_addr == STAGING_INPUT_ADDR)) begin
            staging_input[31:0] <= i_wb_data[31:0];
        end
        else if(i_wb_stb && i_wb_cyc && i_wb_we && !o_wb_stall && i_wb_addr == (STAGING_INPUT_ADDR+4)) begin
            staging_input[63:32] <= i_wb_data[31:0];
        end
        else if (i_wb_stb && i_wb_cyc && i_wb_we && !o_wb_stall && (i_wb_addr == KEY_ADDR)) begin
            key[31:0] <= i_wb_data[31:0];
        end
        else if(i_wb_stb && i_wb_cyc && i_wb_we && !o_wb_stall && i_wb_addr == (KEY_ADDR+4)) begin
            key[63:32] <= i_wb_data[31:0];
        end
        // Disallow writes to staging output for now
        // else if(i_wb_stb && i_wb_cyc && i_wb_we && !o_wb_stall && i_wb_addr == (STAGING_OUTPUT_ADDR)) begin
        //     staging_output[31:0] <= i_wb_data[31:0];
        // end
        // else if(i_wb_stb && i_wb_cyc && i_wb_we && !o_wb_stall && i_wb_addr == (STAGING_OUTPUT_ADDR+4)) begin
        //     staging_output[63:32] <= i_wb_data[31:0];
        // end
        else if(i_wb_stb && i_wb_cyc && i_wb_we && !o_wb_stall && i_wb_addr == CTRL_ADDR) begin
            ctrl[31:0] <= i_wb_data[31:0];
        end
        // Disallow writes to status register for now
        // else if(i_wb_stb && i_wb_cyc && i_wb_we && !o_wb_stall && i_wb_addr == STS_ADDR) begin
        //     sts[31:0] <= i_wb_data[31:0];
        // end
    end


    always@ (posedge clk) begin
        if (reset) begin
            sts <= 0;
            staging_output <= 0;
        end
        else begin
            sts[0] <= o_dv;
            staging_output <= o_ciphertext;
        end
    end

    // reads
    always @(posedge clk) begin
        if(i_wb_stb && i_wb_cyc && !i_wb_we && !o_wb_stall)
            case(i_wb_addr)
                STAGING_INPUT_ADDR:
                    o_wb_data <= staging_input[31:0];
                (STAGING_INPUT_ADDR+4):
                    o_wb_data <= staging_input[63:32]; 
                STAGING_OUTPUT_ADDR:
                    o_wb_data <= staging_output[31:0]; 
                (STAGING_OUTPUT_ADDR+4):
                    o_wb_data <= staging_output[63:32]; 
                KEY_ADDR:
                    o_wb_data <= key[31:0]; 
                (KEY_ADDR+4):
                    o_wb_data <= key[63:32]; 
                CTRL_ADDR:
                    o_wb_data <= ctrl[31:0]; 
                STS_ADDR:
                    o_wb_data <= sts[31:0]; 
                default:
                    o_wb_data <= 32'b0;
            endcase
    end

    // acks
    always @(posedge clk) begin
        if(reset)
            o_wb_ack <= 0;
        else
            // return ack immediately
            o_wb_ack <= (i_wb_stb && !o_wb_stall && 
                ((i_wb_addr == STAGING_INPUT_ADDR) ||
                 (i_wb_addr == STAGING_INPUT_ADDR+4) || 
                 (i_wb_addr == STAGING_OUTPUT_ADDR) || 
                 (i_wb_addr == STAGING_OUTPUT_ADDR+4) || 
                 (i_wb_addr == KEY_ADDR) || 
                 (i_wb_addr == KEY_ADDR+4) || 
                 (i_wb_addr == CTRL_ADDR) || 
                 (i_wb_addr == STS_ADDR)
                 ));
    end

    des u1 (
        .i_clk(clk),
        .i_cleartext(staging_input),        
        .i_key(key),
        .i_dv(ctrl[0]), 
        .i_encrypt(ctrl[1]),
        .o_ciphertext,
        .o_dv
    );

endmodule