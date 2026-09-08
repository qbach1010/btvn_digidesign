module dot_product #(
    parameter N = 64,               
    parameter ADDR_WIDTH = 6        
)(
    input  wire clk,
    input  wire rst_n,              
    input  wire start,              
    output wire busy                
);


    wire [ADDR_WIDTH-1:0] address;
    wire last;
    wire [15:0] a_i;
    wire [15:0] b_i;
    wire [37:0] acc;
    
    wire mac_clr;
    wire mac_en;
    wire counter_en;
    wire write_en;

    k2_FSM fsm_inst (
        .start(start),
        .last(last),
        .clk(clk),
        .mac_clr(mac_clr),
        .mac_en(mac_en),
        .write_en(write_en),
        .counter_en(counter_en),
        .busy(busy)
    );

    counter #(
        .MAX_VAL(N - 1), 
        .MIN_VAL(0), 
        .INIT_VAL(0)
    ) counter_inst (
        .en(counter_en),
        .mode(1'b0),        
        .clk(clk),
        .rst_n(rst_n),
        .count_val(address), 
        .critical(last)      
    );

    sram #(
        .DATA_WIDTH(16),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) sram_a_inst (
        .cs_n(1'b0),         // chip select active
        .we_n(1'b1),         // read only
        .oe_n(1'b0),         // always output enabled
        .addr(address),
        .data(a_i)           
    );

    sram #(
        .DATA_WIDTH(16),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) sram_b_inst (
        .cs_n(1'b0),
        .we_n(1'b1),
        .oe_n(1'b0),
        .addr(address),
        .data(b_i)           
    );

    k2_MAC mac_inst (
        .clr(mac_clr),
        .en(mac_en),
        .clk(clk),
        .a(a_i),
        .b(b_i),
        .acc(acc)
    );


    wire [37:0] ram_y_data_bus;
    assign ram_y_data_bus = write_en ? acc : 38'bz; 

    sram #(
        .DATA_WIDTH(38),
        .ADDR_WIDTH(1)       
    ) ram_y_inst (
        .cs_n(1'b0),
        .we_n(~write_en),    
        .oe_n(1'b1),         
        .addr(1'b0),         
        .data(ram_y_data_bus)
    );

endmodule