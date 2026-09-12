module FSMD_4_P2 #(parameter M = 8, N = 8, SIZE = 16) (
    input clk, rst_n, start,
    output busy,
    output [M*(2*SIZE + $clog2(N)) - 1 : 0] result_vector
);
    localparam W = 2*SIZE + $clog2(N);

    wire counter_en, write_en, mac_en, last_row;
    wire [$clog2(M+1)-1:0] address;
    wire [N*SIZE-1:0] a_val, x_val;
    wire signed [W-1:0] acc_out;

    controller_P2 FSM (
        .clk(clk), .rst_n(rst_n), .start(start),
        .last_row(last_row),
        .counter_en(counter_en), .write_en(write_en),
        .mac_en(mac_en), .busy(busy)
    );

    counter_P2 #(.M(M)) addr_counter (
        .clk(clk), .rst_n(rst_n), .en(counter_en),
        .count_val(address), .last_row(last_row)
    );

    async_SRAM_matrix_P2 #(.M(M), .N(N), .SIZE(SIZE)) sram_A (
        .row_addr(address), 
        .val(a_val)
    );

    async_SRAM_vector_P2 #(.N(N), .SIZE(SIZE)) sram_x (
        .val(x_val)
    );

    MAC_P2 #(.N(N), .SIZE(SIZE)) mac (
        .clk(clk), .rst_n(rst_n), .en(mac_en),
        .a_vector(a_val), .x_vector(x_val), 
        .acc(acc_out)
    );

    sync_write_SRAM_P2 #(.M(M), .W(W)) ram_y (
        .clk(clk), .rst_n(rst_n), .write_en(write_en),
        .addr(address), .acc(acc_out),
        .result(result_vector)
    );

endmodule