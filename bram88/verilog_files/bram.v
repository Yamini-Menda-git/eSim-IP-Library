module bram(
input clk,
input we,
input [3:0] addr,
input [7:0] din,
output reg [7:0] dout
);

reg [7:0] m0,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15;

always @(posedge clk) begin

if(we) begin
case(addr)
4'd0: m0 <= din;
4'd1: m1 <= din;
4'd2: m2 <= din;
4'd3: m3 <= din;
4'd4: m4 <= din;
4'd5: m5 <= din;
4'd6: m6 <= din;
4'd7: m7 <= din;
4'd8: m8 <= din;
4'd9: m9 <= din;
4'd10: m10 <= din;
4'd11: m11 <= din;
4'd12: m12 <= din;
4'd13: m13 <= din;
4'd14: m14 <= din;
4'd15: m15 <= din;
endcase
end

case(addr)
4'd0: dout <= m0;
4'd1: dout <= m1;
4'd2: dout <= m2;
4'd3: dout <= m3;
4'd4: dout <= m4;
4'd5: dout <= m5;
4'd6: dout <= m6;
4'd7: dout <= m7;
4'd8: dout <= m8;
4'd9: dout <= m9;
4'd10: dout <= m10;
4'd11: dout <= m11;
4'd12: dout <= m12;
4'd13: dout <= m13;
4'd14: dout <= m14;
4'd15: dout <= m15;
endcase

end

endmodule