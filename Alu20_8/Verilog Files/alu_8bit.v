module alu_8bit (
    input  [7:0] A, B,      
    input  [3:0]       ALU_Sel,  
    output reg [7:0] ALU_Out
);

    always @(*) begin
        case(ALU_Sel)
          
            4'b0000: ALU_Out = A + B;        // Addition
            4'b0001: ALU_Out = A - B;        // Subtraction
            4'b0010: ALU_Out = A * B;        // Multiplication
            4'b0011: ALU_Out = A / B;        // Division
            4'b0100: ALU_Out = A << 1;       // Logical shift left
            4'b0101: ALU_Out = A >> 1;       // Logical shift right
            4'b0110: ALU_Out = ~A;           // Logical NOT (Unary)
            4'b0111: ALU_Out = A & B;        // Logical AND
            4'b1000: ALU_Out = A | B;        // Logical OR
            4'b1001: ALU_Out = A ^ B;        // Logical XOR
            4'b1010: ALU_Out = ~(A ^ B);     // Logical XNOR
            4'b1011: ALU_Out = ~(A & B);     // Logical NAND
            4'b1100: ALU_Out = ~(A | B);     // Logical NOR
            4'b1101: ALU_Out = (A < B) ? 1'b1 : 1'b0;  // Less than
            4'b1110: ALU_Out = (A == B) ? 1'b1 : 1'b0; // Equality
            4'b1111: ALU_Out = (A > B) ? 1'b1 : 1'b0;  // Greater than (Last Case)
            
            default: ALU_Out = {8{1'b0}};
        endcase
    end

endmodule