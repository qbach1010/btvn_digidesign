// N: num of words, M: size of word (bits), K2 architecture
module async_SRAM # (parameter N = 64, M = 16) (
    input [$clog2(N)-1:0] addr,
    output [M-1:0] val
);
    reg [M-1:0] sram [N-1:0];
	 
	 // default data in ram
	 integer j;
    initial begin
        for (j = 0; j < N; j = j + 1) begin
            sram[j] = j[M-1:0];
        end
    end
	 
    assign val = sram[addr];
endmodule

// N: num of words, M: size of word (bits), K4 architecture
module sync_SRAM # (parameter N = 64, M = 16) (
    input [$clog2(N)-1:0] addr,
    input clk, rst_n,
    output reg [M-1:0] val
);
	 // force quartus to use LUT logic to synthesize async ram
	 // without this, sync ram will be synthesized and timing unequally with sync
    (* ramstyle = "logic" *) reg [M-1:0] sram [N-1:0];
	 
	 // default data in ram
	 integer i;
    initial begin
        for (i = 0; i < N; i = i + 1) begin
            sram[i] = i[M-1:0];
        end
    end
	 
    always @ (posedge clk)
        if (!rst_n) val <= 0;
        else val <= sram[addr];
endmodule

// N_b: num of words per bank, B: num of banks, M: size of word (bits), K3 architecture
module async_multibank_SRAM # (parameter N_b = 16, B = 4, M = 16) (
    input [$clog2(N_b)-1:0] addr,
    output [M*B-1:0] val
);
    // multi-bank SRAM with B banks, N_b words per bank
    reg [M-1:0] sram [B*N_b-1:0];
	 
	 // default data in ram
	 integer j;
    initial begin
        for (j = 0; j < B*N_b; j = j + 1) begin
            sram[j] = j[M-1:0];
        end
    end
	 
    genvar i;
    generate
        for (i=0; i<B; i=i+1) begin : gen_bank
            assign val[(i+1)*M-1 : i*M] = sram[i*N_b + addr];
        end
    endgenerate
endmodule

module sync_write_SRAM # (parameter N = 64, M = 16) (
    input clk, rst_n, write_en,
    input [2*M + $clog2(N) - 1 : 0] acc,
	 output reg [2*M + $clog2(N) - 1 : 0] word
);
    always @ (posedge clk)
        if (!rst_n) word <= 0;
        else word <= write_en ? acc : word;
endmodule