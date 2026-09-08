module gcd_search(
	input [7:0] in_a,
	input [7:0] in_b,
	input en_a,
	input en_b,
	input clk,
	input mode,
	output reg [7:0] gcd,
	output reg greater,
	output reg equal);
	
	wire [7:0] cal_a;
	wire [7:0] cal_b;
	reg [7:0] compare_b;
	
	//vi end thuat toan la compare_a = compare_b = gcd nen dung luon gcd
	
	assign cal_a = mode ? in_a : gcd - compare_b;
	assign cal_b = mode ? in_b : compare_b - gcd;
	
	always @(posedge clk) begin
		if(en_a) begin
			gcd <= cal_a;
		end
		if(en_b) begin
			compare_b <= cal_b;
		end		
	end
	
	always @(gcd, compare_b) begin
		if(gcd > compare_b) begin
			greater = 1'b1;
			equal = 1'b0;
		end
		else if(gcd == compare_b) begin
			greater = 1'b0;
			equal = 1'b1;
		end
		else begin
			greater = 1'b0;
			equal = 1'b0;
		end
	end

endmodule