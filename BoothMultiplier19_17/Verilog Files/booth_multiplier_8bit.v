module booth_multiplier_8bit (
    input clk,
    input reset,
    input start,
    input signed [7:0] multiplier,
    input signed [7:0] multiplicand,
    output reg signed [15:0] product,
    output reg done
);

    reg [3:0] count;
    reg [7:0] A, Q, M;
    reg Q_1;
    reg [1:0] state;

    parameter IDLE = 2'b00, 
              CHECK = 2'b01, 
              SHIFT = 2'b10, 
              FINISH = 2'b11;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done <= 0;
            product <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        A <= 8'b0;
                        M <= multiplicand;
                        Q <= multiplier;
                        Q_1 <= 1'b0;
                        count <= 4'd8;
                        state <= CHECK;
                    end
                end

                CHECK: begin
                    case ({Q[0], Q_1})
                        2'b01: A <= A + M;      // Add multiplicand
                        2'b10: A <= A - M;      // Subtract multiplicand
                        default: A <= A;        // Do nothing for 00 or 11
                    endcase
                    state <= SHIFT;
                end

                SHIFT: begin
                    // Arithmetic Right Shift (Preserves Sign Bit)
                    {A, Q, Q_1} <= {A[7], A, Q}; 
                    if (count == 1)
                        state <= FINISH;
                    else begin
                        count <= count - 1;
                        state <= CHECK;
                    end
                end

                FINISH: begin
                    product <= {A, Q};
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule