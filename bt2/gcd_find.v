module gcd_find(
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    input  wire [7:0] in_a,
    input  wire [7:0] in_b,
    output wire done,
    output wire [7:0] gcd
);

    wire en_a;
    wire en_b;
    wire mode;
    wire greater;
    wire equal;

    gcd_search datapath_inst (
        .in_a(in_a),
        .in_b(in_b),
        .en_a(en_a),
        .en_b(en_b),
        .clk(clk),
        .mode(mode),
        .gcd(gcd),
        .greater(greater),
        .equal(equal)
    );
	 
	 
	 
	 /*gcd_search_by_divider datapath_inst (
        .in_a(in_a),
        .in_b(in_b),
        .en_a(en_a),
        .en_b(en_b),
        .clk(clk),
        .mode(mode),
        .gcd(gcd),
        .greater(greater),
        .equal(equal)
    );*/

	 


    gcd_fsm fsm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .equal(equal),
        .greater(greater),
        .en_a(en_a),
        .en_b(en_b),
        .mode(mode),
        .done(done)
    );

endmodule