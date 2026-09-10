// N: num of words per RAM, M: size of word (bits)
module MAC_K4 # (parameter N = 64, M = 16) (
    input [M-1:0] a, b,
    input clr, en, clk, rst_n,
    output reg signed [2*M + $clog2(N) - 1 : 0] acc
);
    reg signed [2*M-1:0] product_ab;
    always @ (posedge clk) begin
        if (!rst_n) begin
            acc <= 0;
            product_ab <= 0;
        end
        else begin
            if (en) begin
                if (clr) begin
                    acc <= 0;
                    product_ab <= 0;
                end
                else begin
                    product_ab <= $signed(a) * $signed(b);
                    acc <= acc + product_ab;
                end
            end
        end
    end
endmodule