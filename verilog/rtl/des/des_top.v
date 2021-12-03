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
    output reg  [31:0]  o_wb_data,      // output data

    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [38-1:0] io_in,
    output [38-1:0] io_out,
    output [38-1:0] io_oeb

    );

    reg [63:0] staging_input; // Staging memory
    reg [63:0] staging_output;
    reg [63:0] key;
    reg [31:0] ctrl; // Control register
    reg [31:0] sts; // Status register
    wire [63:0] o_ciphertext;
    wire o_dv;

    wire [7:0] bus_data;

    // assign io_oeb[23:16] = 8'hff;
    // assign io_oeb[33] = 1'b1;
    assign io_oeb = {(38-1){reset}};


    async_fifo #(
        8,
        4
        )
    input_fifo
        (
        .wclk(io_in[34]),
        .wrst_n(reset),
        .winc(io_in[36]),
        .wdata(io_in[31:24]),
        .wfull(),
        .awfull(),
        .rclk(clk),
        .rrst_n(reset),
        .rinc(input_io_valid),
        .rdata(bus_data),
        .rempty(),
        .arempty()
        );

    assign io_out[33] = o_dv;

    reg io_ctrl_0;
    reg io_ctrl;
    reg input_io_valid_0;
    reg input_io_valid;
    always @(posedge clk) begin
        io_ctrl_0 <= io_in[35];
        io_ctrl <= io_ctrl_0;

        input_io_valid_0 <= io_in[36];
        input_io_valid <= input_io_valid_0;
    end

    assign o_wb_stall = 0;

    reg [31:0] count;
    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
        end
        else if (count == 16) begin
            count <= 0;
        end
        else if (input_io_valid && io_ctrl) begin
            count <= count + 1;
        end
        else begin
            count <= 0;
        end
    end

    // writes
    always @(posedge clk) begin
        if(reset) begin
            staging_input <= 0; // Staging memory
            ctrl <= 0; // Control register
            key <= 0;
        end
        else if (io_ctrl && input_io_valid) begin
            case (count)
                0 : staging_input[7:0] = bus_data;
                1 : staging_input[15:8] = bus_data;
                2 : staging_input[23:16] = bus_data;
                3 : staging_input[31:24] = bus_data;
                4 : staging_input[39:32] = bus_data;
                5 : staging_input[47:40] = bus_data;
                6 : staging_input[55:48] = bus_data;
                7 : staging_input[63:56] = bus_data;
                8 : key[7:0] = bus_data;
                9 : key[15:8] = bus_data;
                10 : key[23:16] = bus_data;
                11 : key[31:24] = bus_data;
                12 : key[39:32] = bus_data;
                13 : key[47:40] = bus_data;
                14 : key[55:48] = bus_data;
                15 : key[63:56] = bus_data;
                16 : ctrl[1:0] = 3;
            endcase
        end
        else begin
            if (i_wb_stb && i_wb_cyc && i_wb_we && !o_wb_stall && (i_wb_addr == STAGING_INPUT_ADDR)) begin
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
    end

    reg [31:0] outputcount;
    always @(posedge clk) begin
        if (reset) begin
            outputcount <= 0;
        end
        else if (o_dv) begin
            outputcount <= outputcount + 1;
        end
        else begin
            outputcount <= 0;
        end
    end 

    reg [7:0] io_out_trans;
    assign io_out[23:16] = io_out_trans;

    always@ (posedge clk) begin
        if (reset) begin
            sts <= 0;
            staging_output <= 0;
        end
        else if (io_ctrl && input_io_valid) begin
            case (outputcount)
                0 : io_out_trans[7:0] = o_ciphertext[7:0];
                1 : io_out_trans[7:0] = o_ciphertext[15:8];
                2 : io_out_trans[7:0] = o_ciphertext[23:16];
                3 : io_out_trans[7:0] = o_ciphertext[31:24];
                4 : io_out_trans[7:0] = o_ciphertext[39:32];
                5 : io_out_trans[7:0] = o_ciphertext[47:40];
                6 : io_out_trans[7:0] = o_ciphertext[55:48];
                7 : io_out_trans[7:0] = o_ciphertext[63:56];
            endcase
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
        .o_dv,
        .mid_data(la_data_out[63:0]),
        .mid_key(la_data_out[127:64])
    );

endmodule