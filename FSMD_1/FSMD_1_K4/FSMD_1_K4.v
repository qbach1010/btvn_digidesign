module FSMD_1_K4 # (parameter N = 64, M = 16) (
    input clk,
    input rst_n,
    input start,
    output busy
);
    wire counter_en, write_en, mac_clr, mac_en, last;
    wire [$clog2(N+2)-1:0] cnt_val;
    wire [$clog2(N)-1:0] address;
    wire [M-1:0] A, B;
    wire [2*M + $clog2(N) - 1 : 0] acc_out;

    assign address = cnt_val[$clog2(N)-1:0];

    controller_K4 FSM (
        .clk(clk), .rst_n(rst_n), 
        .start(start), .last(last),
        .counter_en(counter_en), .write_en(write_en),
        .mac_clr(mac_clr), .mac_en(mac_en), 
        .busy(busy)
    );

    counter_K4 #(.N(N)) addr_counter (
        .clk(clk), .rst_n(rst_n), .en(counter_en), .clr(!busy),
        .count_val(cnt_val), .last(last)
    );

    sync_SRAM #(.N(N), .M(M)) sram_A (
        .clk(clk), .rst_n(rst_n),
        .addr(address), 
        .val(A)
    );

    sync_SRAM #(.N(N), .M(M)) sram_B (
        .clk(clk), .rst_n(rst_n),
        .addr(address), 
        .val(B)
    );

    MAC_K4 #(.N(N), .M(M)) mac_k4 (
        .clk(clk), .rst_n(rst_n),
        .a(A), .b(B),
        .clr(mac_clr), .en(mac_en),
        .acc(acc_out)
    );

    sync_write_SRAM #(.N(N), .M(M)) ram_y (
        .clk(clk), .rst_n(rst_n), .write_en(write_en),
        .acc(acc_out)
    );

endmodule