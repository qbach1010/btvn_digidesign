module gcd_search_by_divider(
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
    reg  [7:0] compare_b;
    
    wire [7:0] rem_a;
    wire [7:0] rem_b;
	 
	 //think gcd as compare_a
    
    assign rem_a = gcd % compare_b;
    assign rem_b = compare_b % gcd;
    
    assign cal_a = mode ? in_a : ((rem_a == 8'd0) ? compare_b : rem_a);
    assign cal_b = mode ? in_b : ((rem_b == 8'd0) ? gcd       : rem_b);
    

    always @(posedge clk) begin
        if (en_a) begin
            gcd <= cal_a;
        end
        if (en_b) begin
            compare_b <= cal_b;
        end        
    end
    
    always @(*) begin
        if (gcd > compare_b) begin
            greater = 1'b1;
            equal   = 1'b0;
        end
        else if (gcd == compare_b) begin
            greater = 1'b0;
            equal   = 1'b1;
        end
        else begin
            greater = 1'b0;
            equal   = 1'b0;
        end
    end

endmodule