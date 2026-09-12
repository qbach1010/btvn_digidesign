module counter_row_P1 # (parameter M = 8) (
    // input en of row counter is output last_cnt from column counter
    input en, clk, rst_n,
    // row counter M
    output reg [$clog2(M)-1:0] count_val,
    output last_row
);
    always @ (posedge clk) begin
        if (!rst_n) count_val <= 0;
        else
            if (en) count_val <= last_row ? 0 : (count_val+1);
    end

    assign last_row = (count_val == M-1);
endmodule