module FSMD_1_K2 # (parameter N = 64, M = 16) (
    input clk,
    input rst_n,
    input start,
    output busy,
	 output [2*M + $clog2(N) - 1 : 0] result
);
    wire counter_en, write_en, mac_clr, mac_en, last;
    wire [$clog2(N)-1:0] address;
    wire [M-1:0] A_val, B_val;
    wire [2*M + $clog2(N) - 1 : 0] acc_out;

    controller_K2 FSM (
        .clk(clk), .rst_n(rst_n), 
        .start(start), .last(last),
        .counter_en(counter_en), .write_en(write_en),
        .mac_clr(mac_clr), .mac_en(mac_en), 
        .busy(busy)
    );

    counter_K2 #(.N(N)) addr_counter (
        .clk(clk), .rst_n(rst_n), .en(counter_en), .clr(!busy),
        .count_val(address), .last(last)
    );

    async_SRAM #(.N(N), .M(M)) sram_A (
        .addr(address), 
        .val(A_val)
    );

    async_SRAM #(.N(N), .M(M)) sram_B (
        .addr(address), 
        .val(B_val)
    );

    MAC_K2 #(.M(M), .N(N)) mac_k2 (
        .clk(clk), .rst_n(rst_n),
        .a(A_val), .b(B_val),
        .clr(mac_clr), .en(mac_en),
        .acc(acc_out)
    );

    sync_write_SRAM #(.N(N), .M(M)) ram_y (
        .clk(clk), .rst_n(rst_n), .write_en(write_en),
        .acc(acc_out), .word(result)
    );

endmodule