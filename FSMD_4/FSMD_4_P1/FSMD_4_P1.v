// M: num of rows, N: num of columns, SIZE: size of each input element (bits)
module FSMD_4_P1 # (parameter M = 8, N = 8, SIZE = 16) (
    input clk, rst_n, start,
    output busy,
    // output vector: M rows, 1 column
    // size of each output element: 2*SIZE + $clog2(N)
    output [M*(2*SIZE + $clog2(N)) - 1 : 0] result_vector
);
    localparam W = 2*SIZE + $clog2(N);

    wire counter_en, write_en, mac_clr, mac_en;
    wire last_col, last_cnt, last_row;
    
    wire [$clog2(N+1)-1:0] col_count_out;
    wire [$clog2(N)-1:0]   col_addr; 
    wire [$clog2(M)-1:0]   row_addr;
    
    wire [SIZE-1:0] a_val, x_val;
    wire signed [W-1:0] acc_out;
    
    // column counter mode N+1 so col_count_out may larger in size than col_addr
    assign col_addr = col_count_out[$clog2(N)-1:0];

    controller_P1 FSM (
        .clk(clk), .rst_n(rst_n), .start(start),
        .last_col(last_col), .last_row(last_row),
        .counter_en(counter_en), .write_en(write_en),
        .mac_clr(mac_clr), .mac_en(mac_en), .busy(busy)
    );

    counter_col_P1 #(.N(N)) col_cnt (
        .clk(clk), .rst_n(rst_n), .en(counter_en),
        .count_val(col_count_out), // not col_addr
        .last_col(last_col), .last_cnt(last_cnt)
    );

    counter_row_P1 #(.M(M)) row_cnt (
        .clk(clk), .rst_n(rst_n), .en(last_cnt),
        .count_val(row_addr), 
        .last_row(last_row)
    );

    async_SRAM_matrix_P1 #(.M(M), .N(N), .SIZE(SIZE)) sram_A (
        .row_addr(row_addr), .col_addr(col_addr),
        .val(a_val)
    );

    async_SRAM_vector_P1 #(.N(N), .SIZE(SIZE)) sram_x (
        .row_addr(col_addr),
        .val(x_val)
    );

    MAC_P1 #(.N(N), .SIZE(SIZE)) mac_unit (
        .clk(clk), .rst_n(rst_n), 
        .en(mac_en), .clr(mac_clr),
        .a(a_val), .b(x_val), 
        .acc(acc_out)
    );

    sync_write_SRAM_P1 #(.M(M), .W(W)) ram_y (
        .clk(clk), .rst_n(rst_n), .write_en(write_en),
        .row_addr(row_addr), .acc(acc_out),
        .result(result_vector)
    );

endmodule