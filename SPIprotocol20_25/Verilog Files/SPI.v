`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.04.2026 10:09:06
// Design Name: 
// Module Name: spi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SPI (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [7:0] data_in,
    input wire [7:0] mdata_in,
    input wire slave_sel,
    output wire [7:0] slave0_data,
    output wire [7:0] slave1_data,
    output wire done,
    output wire [7:0] mparallel_data
);
    wire mosi, sclk;
    wire [1:0] ss;
    wire miso0, miso1;
    wire miso;
 
    assign miso = (ss[0] == 1'b0) ? miso0 :
                  (ss[1] == 1'b0) ? miso1 : 1'b0;
 
    spi_master master (
        .clk(clk), .reset(reset), .start(start),
        .miso(miso), .data_in(data_in), .slave_sel(slave_sel),
        .mosi(mosi), .sclk(sclk), .ss(ss), .done(done),
        .mparallel_data(mparallel_data)
    );
    spi_slave slave0 (
        .clk(clk), .sclk(sclk), .ss(ss[0]), .mosi(mosi),
        .mdata_in(mdata_in), .miso(miso0),
        .parallel_data(slave0_data), .byte_done()
    );
    spi_slave slave1 (
        .clk(clk), .sclk(sclk), .ss(ss[1]), .mosi(mosi),
        .mdata_in(mdata_in), .miso(miso1),
        .parallel_data(slave1_data), .byte_done()
    );
endmodule
module spi_master (
    input  wire clk,
    input  wire reset,
    input  wire start,
    input  wire miso,
    input  wire [7:0] data_in,
    input  wire slave_sel,
    output reg  mosi,
    output reg  sclk,
    output reg  [1:0] ss,
    output reg  done,
    output reg  [7:0] mparallel_data
);
    reg [2:0] state;
    localparam IDLE          = 3'd0,
               LOAD          = 3'd1,
               TRANSFER_LOW  = 3'd2,
               TRANSFER_HIGH = 3'd3,
               FINISH        = 3'd4;
 
    reg [7:0] shift_reg_out;
    reg [2:0] bit_cnt;
 
    // -------------------------------------------------------
    // Logic Block 1 - UNCHANGED from original
    // -------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state   <= IDLE;
            sclk    <= 0;
            ss      <= 2'b11;
            mosi    <= 0;
            done    <= 0;
            bit_cnt <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    sclk <= 0;
                    if (start) state <= LOAD;
                end
                LOAD: begin
                    ss      <= (slave_sel == 0) ? 2'b10 : 2'b01;
                    bit_cnt <= 0;
                    state   <= TRANSFER_LOW;
                end
                TRANSFER_LOW: begin
                    sclk  <= 0;
                    mosi  <= shift_reg_out[7 - bit_cnt];
                    state <= TRANSFER_HIGH;
                end
                TRANSFER_HIGH: begin
                    sclk <= 1;
                    if (bit_cnt == 3'd7) state <= FINISH;
                    else begin
                        bit_cnt <= bit_cnt + 1;
                        state   <= TRANSFER_LOW;
                    end
                end
                FINISH: begin
                    sclk  <= 0;
                    ss    <= 2'b11;
                    done  <= 1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
 
    // -------------------------------------------------------
    // Logic Block 2 - FIXED (two changes marked FIX A / FIX B)
    // -------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg_out  <= 8'h00;
            mparallel_data <= 8'h00;
        end else begin
 
            if (state == LOAD) begin
                shift_reg_out  <= data_in;
                mparallel_data <= 8'h00;          // FIX A: clear before every transfer
            end
 
            if (state == TRANSFER_HIGH) begin     // FIX B: sample on TRANSFER_HIGH
                mparallel_data <= {mparallel_data[6:0], miso};
            end
 
        end
    end
endmodule
module spi_slave (
    input  wire clk,
    input  wire sclk,
    input  wire ss,          // active-LOW
    input  wire mosi,
    input  wire [7:0] mdata_in,
    output wire miso,        // CHANGED: wire, driven combinationally
    output reg  [7:0] parallel_data,
    output reg  byte_done
);
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg_in;
    reg [7:0] shift_reg_out;
 
    reg sclk_delayed;
    wire sclk_rising = (sclk && !sclk_delayed);
 
    // COMBINATIONAL MISO drive - zero latency, no sclk_falling needed
    // When ss is deasserted (high), output high-Z so the MISO MUX works.
    assign miso = ss ? 1'bz : shift_reg_out[7 - bit_cnt];
 
    always @(posedge clk or posedge ss) begin
        if (ss) begin                      // ss HIGH = slave deasserted = reset
            bit_cnt       <= 0;
            byte_done     <= 0;
            sclk_delayed  <= 0;
            shift_reg_out <= mdata_in;     // preload all 8 bits
            shift_reg_in  <= 8'h00;
        end else begin
            sclk_delayed <= sclk;
 
            // Sample MOSI on rising edge of sclk (unchanged from original)
            if (sclk_rising) begin
                shift_reg_in <= {shift_reg_in[6:0], mosi};
                bit_cnt      <= bit_cnt + 1;
                if (bit_cnt == 7) begin
                    parallel_data <= {shift_reg_in[6:0], mosi};
                    byte_done     <= 1;
                end
            end
        end
    end
endmodule