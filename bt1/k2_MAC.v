module k2_MAC (
	input clr,
	input en,
	input clk,
	input signed [15:0] a, 
	input signed [15:0] b, 
	output reg signed [37:0] acc
	);
	wire signed [31:0] w1;
	wire signed [37:0] w2;
	
	assign w1 = a * b;
	assign w2 = clr ? 38'b0 : w1 + acc;
	
	always @(posedge clk) begin
		if(en) begin
			acc <= w2;
		end
	end
endmodule