// N: num of words per SRAM, M: size of word (bits)
module MAC_K2 # (parameter N = 64, M = 16) (
    input [M-1:0] a, b,
    input clr, en, clk, rst_n,
    output reg signed [2*M + $clog2(N) - 1 : 0] acc
);
    wire signed [2*M + $clog2(N) - 1 : 0] next_acc;

    assign next_acc = acc + $signed(a) * $signed(b);

    always @ (posedge clk)
        if (!rst_n) acc <= 0;
        else begin
            if (en) acc <= (clr ? 0 : next_acc);
            else acc <= 0;
        end
endmodule