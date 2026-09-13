// N: num of columns, which means num of partial sum accumulated to each output
// SIZE: size of word (bits)
module MAC_P1 # (parameter N = 8, SIZE = 16) (
    input [SIZE-1:0] a, b,
    input clr, en, clk, rst_n,
    // force quartus to keep all FFs of acc, do not delete FFs that remains logic '0'
    (* noprune *) output reg signed [2*SIZE + $clog2(N) - 1 : 0] acc
);
    wire signed [2*SIZE + $clog2(N) - 1 : 0] next_acc;

    // force quartus to use dsp to multiply, do not try to use LE to add constant
    (* multstyle = "dsp" *) assign next_acc = acc + $signed(a) * $signed(b);

    always @ (posedge clk)
        if (!rst_n) acc <= 0;
        else begin
            if (en) acc <= (clr ? 0 : next_acc);
        end
endmodule