`timescale 1ns/1ps

module cordic (
    input  wire        clk,
    input  wire        rst_n,
    input  wire signed [15:0] degree_in,    // Input: -180 to 180 (Normal degrees)
    input  wire        start,
    output reg  signed [15:0] sine_out,     // Output: Q1.14 format (scaled by 16384)
    output reg  signed [15:0] cos_out,      // Output: Q1.14 format (scaled by 16384)
    output reg         done
);

    // Look-up Table: atan(2^-i) scaled to 16-bit (180 degrees = 32768)
    reg signed [15:0] atan_table [0:13];
    initial begin
        atan_table[0]  = 16'd8192;   // 45.0 degrees
        atan_table[1]  = 16'd4836;   // 26.565
        atan_table[2]  = 16'd2555;   // 14.036
        atan_table[3]  = 16'd1297;   // 7.125
        atan_table[4]  = 16'd651;    // 3.576
        atan_table[5]  = 16'd326;    // 1.790
        atan_table[6]  = 16'd163;    // 0.895
        atan_table[7]  = 16'd81;     // 0.448
        atan_table[8]  = 16'd41;     // 0.224
        atan_table[9]  = 16'd20;     // 0.112
        atan_table[10] = 16'd10;     // 0.056
        atan_table[11] = 16'd5;      // 0.028
        atan_table[12] = 16'd2;      // 0.014
        atan_table[13] = 16'd1;      // 0.007
    end

    reg signed [15:0] x, y, z;
    reg [3:0] i;
    reg busy;

    // Scaling constants
    // K = 0.60725 * 16384 (Q1.14) = 9949
    localparam signed [15:0] K = 16'd9949;
    // ANGLE_CONV = 32768 / 180 = 182.044... we use 182 for integer math
    localparam signed [15:0] ANGLE_CONV = 16'd182; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy <= 0;
            done <= 0;
            i    <= 0;
            sine_out <= 0;
            cos_out  <= 0;
        end else if (start && !busy) begin
            busy <= 1;
            done <= 0;
            i    <= 0;
            x    <= K;      
            y    <= 0;      
            // Internal calculation: Convert degrees to CORDIC units
            z    <= degree_in * ANGLE_CONV; 
        end else if (busy) begin
            if (i <= 13) begin
                // Standard CORDIC rotation logic
                if (z >= 0) begin
                    x <= x - (y >>> i);
                    y <= y + (x >>> i);
                    z <= z - atan_table[i];
                end else begin
                    x <= x + (y >>> i);
                    y <= y - (x >>> i);
                    z <= z + atan_table[i];
                end
                i <= i + 1;
            end else begin
                // Results are already in Q1.14 (scaled by 16384) because initial X was K
                sine_out <= y;
                cos_out  <= x;
                done     <= 1;
                busy     <= 0;
            end
        end
    end
endmodule