module counter_P2 #(parameter M = 8) (
    input clk, rst_n, en,
    output reg [$clog2(M+1)-1:0] count_val,
    output last_row
);
    always @(posedge clk) begin
        if (!rst_n) count_val <= 0;
        else
				if (en) count_val <= (count_val == M) ? 0 : (count_val + 1);
    end

    assign last_row = (count_val == M-1); 
endmodule