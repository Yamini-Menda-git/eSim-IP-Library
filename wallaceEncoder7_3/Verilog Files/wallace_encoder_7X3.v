module wallace_encoder_7X3 (
    input [6:0] thermo_in, // From 7 ADC Comparators
    output [2:0] binary_out // 3-bit Digital Output
);

    // Intermediate wires for the Tree
    wire s1_a, c1_a; 
    wire s1_b, c1_b; 
    wire s2, c2;     
    wire s3, c3;     

    // --- STAGE 1: Parallel Reduction ---
    // Process bits 0, 1, 2
    full_adder fa1 (
        .a(thermo_in[0]), .b(thermo_in[1]), .cin(thermo_in[2]), 
        .sum(s1_a), .cout(c1_a)
    );

    // Process bits 3, 4, 5
    full_adder fa2 (
        .a(thermo_in[3]), .b(thermo_in[4]), .cin(thermo_in[5]), 
        .sum(s1_b), .cout(c1_b)
    );

    // --- STAGE 2: LSB Generation ---
    // Combine sums and the 7th bit (thermo_in[6])
    // The sum here is the actual LSB of our ADC result
    full_adder fa3 (
        .a(s1_a), .b(s1_b), .cin(thermo_in[6]), 
        .sum(binary_out[0]), .cout(c2)
    );

    // --- STAGE 3: Weight-2 and Weight-4 Reduction ---
    // Combine all Carry bits (which represent '2')
    full_adder fa4 (
        .a(c1_a), .b(c1_b), .cin(c2), 
        .sum(binary_out[1]), .cout(binary_out[2])
    );

endmodule
// Structural Full Adder 
module full_adder (
    input a, b, cin,
    output sum, cout
);
    // Sum = A ^ B ^ Cin
    // Cout = (A & B) | (Cin & (A ^ B))
    wire a_xor_b;
    
    xor g1(a_xor_b, a, b);
    xor g2(sum, a_xor_b, cin);
    
    assign cout = (a & b) | (cin & a_xor_b);
endmodule