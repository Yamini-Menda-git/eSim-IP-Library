
module divider_8bit (
    input  wire [7:0] dividend,
    input  wire [7:0] divisor,
    output reg  [7:0] quotient,
    output reg  [7:0] remainder,
    output reg        div_by_zero
);

    integer i;

    // Internal variables for the combinational loop
    // NOTE: 'A' must be 9 bits wide to properly store the sign bit during subtraction
    reg signed [8:0] A;  
    reg        [7:0] Q;  
    reg        [7:0] M;  

    always @* begin
        // Default output states
        div_by_zero = 0;
        quotient    = 0;
        remainder   = 0;

        if (divisor == 0) begin
            div_by_zero = 1;
        end 
        else begin
            // Step 1: Initialize values
            A = 9'b0;
            Q = dividend;
            M = divisor;

            // Step 2: Unroll the 8 iterations of Non-Restoring Division
            for (i = 0; i < 8; i = i + 1) begin
                
                // 1. Shift left {A, Q} by 1 bit
                A = (A << 1) | Q[7];
                Q = Q << 1;

                // 2. Add or Subtract M based on the sign bit of A (A[8])
                if (A[8] == 1'b1) begin
                    A = A + $signed({1'b0, M}); // Add M with proper 9-bit expansion
                end 
                else begin
                    A = A - $signed({1'b0, M}); // Subtract M
                end

                // 3. Determine the next quotient bit based on the new sign of A
                if (A[8] == 1'b1) begin
                    Q[0] = 1'b0; end
                 else begin
                    Q[0] = 1'b1;
                end
            end

            // Step 3: Final restoration (if remainder is negative, add M back)
            if (A[8] == 1'b1) begin
                A = A + $signed({1'b0, M});
            end

            // Step 4: Output assignment
            quotient  = Q;
            remainder = A[7:0];
        end
    end

endmodule

