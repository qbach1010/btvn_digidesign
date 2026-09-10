module counter_K4 # (parameter N = 64) (
    input en, clk, rst_n, clr,
    // $clog2(N+2) instead of $clog2(N) because we need N+2 cycles
    output reg [$clog2(N+2)-1:0] count_val,
    output last
);
    always @ (posedge clk) begin
        if (!rst_n) count_val <= 0;
        else
            // auto clear after finish counting
            if (clr) count_val <= 0;
            else count_val <= en ? (count_val+1) : count_val;
    end

    // need N+2 cycles to complete accumulation (pipeline 3 layers)
    assign last = (count_val == N+1);
endmodule