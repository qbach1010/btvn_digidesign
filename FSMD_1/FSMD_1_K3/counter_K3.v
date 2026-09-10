module counter_K3 # (parameter N_b = 16) (
    input en, clk, rst_n, clr,
    output reg [$clog2(N_b)-1:0] count_val,
    output last
);
    always @ (posedge clk) begin
        if (!rst_n) count_val <= 0;
        else 
            // auto clear after finish counting
            if (clr) count_val <= 0;
            else count_val <= en ? (count_val+1) : count_val;
    end

    assign last = (count_val == N_b-1);
endmodule