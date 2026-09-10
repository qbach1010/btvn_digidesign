module gcd_div_find (
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    input  wire [7:0] in_a,
    input  wire [7:0] in_b,
    output wire [7:0] gcd,
    output wire done
);

    // Internal wires connecting the Controller and GCD Search
    wire en_a;
    wire en_b;
    wire mode;
    wire stop;

    // Instantiate the Controller (FSM)
    gcd_div_fsm u_controller (
        .clk   (clk),
        .rst_n (rst_n),
        .start (start),
        .stop  (stop),   // Input from GCD Search
        .en_a  (en_a),   // Output to GCD Search
        .en_b  (en_b),   // Output to GCD Search
        .mode  (mode),   // Output to GCD Search
        .done  (done)
    );

    // Instantiate the GCD Search datapath
    gcd_div_search u_search (
        .clk   (clk),
        .mode  (mode),   // Input from FSM
        .en_a  (en_a),   // Input from FSM
        .en_b  (en_b),   // Input from FSM
        .in_a  (in_a),
        .in_b  (in_b),
        .gcd   (gcd),
        .stop  (stop)    // Output to FSM
    );

endmodule