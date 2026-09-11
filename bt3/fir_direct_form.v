module fir_direct_form #(
    parameter WIDTH = 16
)(
    input clk,
    input rst_n,
    input signed [WIDTH-1:0] x,
    input signed [8*WIDTH-1:0] h_packed, 
    output reg signed [2*WIDTH+3:0] y
);

    wire signed [WIDTH-1:0] h [7:0];
	 

    genvar k;
    generate
        for (k = 0; k < 8; k = k + 1) begin : unpack_h
            assign h[k] = h_packed[k*WIDTH +: WIDTH]; 
        end
    endgenerate

    reg signed [WIDTH-1:0] x_temp [7:0];
    reg signed [2*WIDTH-1:0] mult [7:0];
    reg signed [2*WIDTH+3:0] y_comb; 
    integer i;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(i = 0; i < 8; i = i + 1) begin
                x_temp[i] <= 0;
            end
        end
        else begin
            x_temp[0] <= x;
            for(i = 1; i < 8; i = i + 1) begin
                x_temp[i] <= x_temp[i-1];
					 
            end 
				y <= y_comb;
        end
    end
    
    always @(*) begin
        y_comb = 0; 
        
        for(i = 0; i < 8; i = i + 1) begin
            mult[i] = h[i] * x_temp[i]; 
        end
        
        for(i = 0; i < 8; i = i + 1) begin
            y_comb = y_comb + mult[i];
        end
    end

    
endmodule