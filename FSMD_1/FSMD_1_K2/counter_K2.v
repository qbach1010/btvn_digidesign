module counter_K2 # (parameter N = 64) (
    input en, clk, rst_n, clr,
    output reg [$clog2(N)-1:0] count_val,
    output last
);
    always @ (posedge clk) begin
        if (!rst_n) count_val <= 0;
        else
            // auto clear after finish counting
            if (clr) count_val <= 0;
            else count_val <= en ? (count_val+1) : count_val;
    end

    assign last = (count_val == N-1);
endmodule