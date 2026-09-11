module fir_transpose_form #(
    parameter WIDTH = 16
)(
    input clk,
    input rst_n,
    input signed [WIDTH-1:0] x,
    input signed [8*WIDTH-1:0] h_packed, 
    output reg signed [2*WIDTH+3:0] y
);
	 wire signed [WIDTH-1:0] h [7:0];
	 reg signed [2*WIDTH-1:0] mult [7:0];
	 reg signed [2*WIDTH+3:0] acc [6:0]; //accumilation
	 reg signed [2*WIDTH+3:0] sum [7:1];
	 
	 reg signed [WIDTH-1:0] x_reg;
	 
    genvar k;
    generate
        for (k = 0; k < 8; k = k + 1) begin : unpack_h
            assign h[k] = h_packed[k*WIDTH +: WIDTH]; 
        end
    endgenerate
	 
	 integer i;
	 
	 always @(*) begin
		  for(i = 0; i < 8; i = i + 1) begin
            mult[i] = x_reg * h[i];
        end
		  for(i = 1; i < 8; i = i + 1) begin
            sum[i] = mult[i] + acc[i-1];
        end
	 end
	 
	 always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			x_reg <= 0;
			for(i = 0; i < 7; i = i + 1) begin
            acc[i] <= 0;
         end
			y <= 0;
		end
		else begin
			x_reg <= x;
			acc[0] <= mult[0];
			for(i = 1; i < 7; i = i + 1) begin
            acc[i] <= sum[i];
         end
		   y <= sum[7];
		end
	 end 
endmodule