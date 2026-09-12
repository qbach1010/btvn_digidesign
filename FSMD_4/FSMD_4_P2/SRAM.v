// M: num of rows, N: num of columns, SIZE: size of word (bits), P1 architecture
module async_SRAM_matrix_P1 # (parameter M = 8, N = 8, SIZE = 16) (
    input [$clog2(M)-1:0] row_addr,
    input [$clog2(N)-1:0] col_addr,
    output [SIZE-1:0] val
);
    reg [SIZE-1:0] sram [M*N-1:0];
	 
	// default data in ram
	integer j;
    initial begin
        for (j = 0; j < M*N; j = j + 1) begin
            sram[j] = j[SIZE-1:0];
        end
    end
	 
    assign val = sram[row_addr * N + col_addr];
endmodule

// N: num of rows, SIZE: size of word (bits), P1 architecture
// Vector size: N*1 with N is also num of columns in matrix
module async_SRAM_vector_P1 # (parameter N = 8, SIZE = 16) (
    input [$clog2(N)-1:0] row_addr,
    output [SIZE-1:0] val
);
    reg [SIZE-1:0] sram [N-1:0];
	
	// default data in ram
	integer j;
    initial begin
        for (j = 0; j < N; j = j + 1) begin
            sram[j] = j[SIZE-1:0];
        end
    end
	 
    assign val = sram[row_addr];
endmodule

// P2 architecture
module async_SRAM_matrix_P2 #(parameter M = 8, N = 8, SIZE = 16) (
    input [$clog2(M+1)-1:0] row_addr,
    output [N*SIZE-1:0] val
);
    reg [M*SIZE-1:0] sram [N-1:0];
    
	 // default data in ram
    integer i, j;
    initial begin
        for (j=0; j<N; j=j+1) begin
            for (i=0; i<M; i=i+1) sram[j][i*SIZE +: SIZE] = j[SIZE-1:0];
        end
    end
    
    genvar g_j;
    generate
        for (g_j=0; g_j<N; g_j=g_j+1) begin : gen_assign
            assign val[g_j*SIZE +: SIZE] = sram[g_j][row_addr*SIZE +: SIZE];
        end
    endgenerate
endmodule

// P2 architecture
module async_SRAM_vector_P2 #(parameter N = 8, SIZE = 16) (
    output [N*SIZE-1:0] val
);
    reg [N*SIZE-1:0] sram_x;

	 // default data in ram
    initial begin
        sram_x = {(N*SIZE){1'b1}}; 
    end
    
    assign val = sram_x;
endmodule

// M: num of rows, N: num of columns, W: size of output element (bits), P1 architecture
module sync_write_SRAM_P1 # (parameter M = 8, W = 35) (
    input clk, rst_n, write_en,
    input [W-1:0] acc,
    input [$clog2(M)-1:0] row_addr,
	output reg [M*W-1: 0] result
);
    always @ (posedge clk)
        if (!rst_n) result <= 0;
        else
            if (write_en) result[row_addr * W +: W] <= acc;
endmodule

// P2 architecture
module sync_write_SRAM_P2 #(parameter M = 8, W = 35) (
    input clk, rst_n, write_en,
    input [W-1:0] acc,
    input [$clog2(M+1)-1:0] addr,
    output reg [M*W-1:0] result
);
    always @(posedge clk) begin
        if (!rst_n) result <= 0;
        else if (write_en) result[(addr - 1) * W +: W] <= acc;
    end
endmodule