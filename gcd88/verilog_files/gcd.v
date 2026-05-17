module gcd_seq (
    input clk,
    input rst,
    input start,
    input [7:0] a,
    input [7:0] b,
    output reg [7:0] gcd,
    output reg done
);

    reg [7:0] x, y;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x <= 0;
            y <= 0;
            gcd <= 0;
            done <= 0;
        end
        else begin
            if (start) begin
                x <= a;
                y <= b;
                done <= 0;
            end
            else if (y != 0) begin
                x <= y;
                y <= x % y;
            end
            else begin
                gcd <= x;
                done <= 1;
            end
        end
    end

endmodule