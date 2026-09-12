module counter_col_P1 # (parameter N = 8) (
    input en, clk, rst_n,
    // column counter mod N+1, not N
    // So that output will be saved in RAM Y with the right idex
    output reg [$clog2(N+1)-1:0] count_val,
    output last_col, last_cnt
);
    always @ (posedge clk) begin
        if (!rst_n) count_val <= 0;
        else
            if (en) count_val <= last_cnt ? 0 : (count_val+1);
    end

    assign last_col = (count_val == N-1);
    assign last_cnt = (count_val == N);
endmodule