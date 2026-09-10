// N: num of words, M: size of word (bits)
module async_SRAM # (parameter N = 64, M = 16) (
    input [$clog2(N)-1:0] addr,
    output [M-1:0] val
);
    reg [M-1:0] sram [N-1:0];
    assign val = sram[addr];
endmodule

// N: num of words, M: size of word (bits)
module sync_SRAM # (parameter N = 64, M = 16) (
    input [$clog2(N)-1:0] addr,
    input clk, rst_n,
    output reg [M-1:0] val
);
    reg [M-1:0] sram [N-1:0];
    always @ (posedge clk)
        if (!rst_n) val <= 0;
        else val <= sram[addr];
endmodule

// N_b: num of words per bank, B: num of banks, M: size of word (bits)
module async_multibank_SRAM # (parameter N_b = 16, B = 4, M = 16) (
    input [$clog2(N_b)-1:0] addr,
    output [M*B-1:0] val
);
    // multi-bank SRAM with B banks, N_b words per bank
    reg [M-1:0] sram [B*N_b-1:0];
    genvar i;
    generate
        for (i=0; i<B; i=i+1) begin : gen_bank
            assign val[(i+1)*M-1 : i*M] = sram[i*N_b + addr];
        end
    endgenerate
endmodule

module sync_write_SRAM # (parameter N = 64, M = 16) (
    input clk, rst_n, write_en,
    input [2*M + $clog2(N) - 1 : 0] acc
);
    reg [2*M + $clog2(N) - 1 : 0] word;
    always @ (posedge clk)
        if (!rst_n) word <= 0;
        else word <= write_en ? acc : word;
endmodule