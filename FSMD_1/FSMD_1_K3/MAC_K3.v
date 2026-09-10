// N_b: num of words per bank, B: num of banks, M: size of word (bits)
module MAC_K3 # (parameter N_b = 16, B = 4, M = 16) (
    input [B*M-1:0] a, b,
    input clr, en, clk, rst_n,
    output reg signed [2*M + $clog2(N_b*B) - 1 : 0] acc
);
    reg signed [2*M + $clog2(N_b*B) - 1 : 0] sum_ab;

    integer i;
    always @ (*) begin
        sum_ab = 0;
        for (i=0; i<B; i=i+1)
            sum_ab = sum_ab + ($signed(a[i*M +: M]) * $signed(b[i*M +: M]));
    end

    always @ (posedge clk)
        if (!rst_n) acc <= 0;
        else begin
            if (en) acc <= (clr ? 0 :(sum_ab + acc));
            else acc <= 0;
        end
endmodule