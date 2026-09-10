module fir_direct_form #(
	parameter WIDTH = 16)(
	input clk,
	input rst_n,
	input [WIDTH-1:0] x,
	input [WIDTH-1:0] h [7:0],
	output [2 * WIDTH + 3:0] y
	);
	
	reg [WIDTH-1:0] x_temp [7:0];
	reg [2*WIDTH-1:0] mult [7:0];
	integer i;
	
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			for(i = 0; i < 8; i++) begin
				x_temp[i] <= 0;
			end
		end
		else begin
			x_temp[0] <= x;
			for(i = 1; i < 8; i++) begin
				x_temp[i] <= x_temp[i-1];
			end 
		end
	end
	
	always @(*) begin
		y_comb = 0;
		for(i = 0; i < 8; i++) begin
				mult[i] = h[i] * x_temp[i];
		end
		for(i = 0; i < 8; i++) begin
				y_comb = y_comb + mult[i];
		end
	end
	
	assign y = y_comb;

endmodule	