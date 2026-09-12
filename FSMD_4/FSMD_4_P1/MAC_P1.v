// N: num of columns, which means num of partial sum accumulated to each output
// SIZE: size of word (bits)
module MAC_P1 # (parameter N = 8, SIZE = 16) (
    input [SIZE-1:0] a, b,
    input clr, en, clk, rst_n,
    output reg signed [2*SIZE + $clog2(N) - 1 : 0] acc
);
    wire signed [2*SIZE + $clog2(N) - 1 : 0] next_acc;

    assign next_acc = acc + $signed(a) * $signed(b);

    always @ (posedge clk)
        if (!rst_n) acc <= 0;
        else begin
            if (en) acc <= (clr ? 0 : next_acc);
        end
endmodule