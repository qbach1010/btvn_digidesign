module gcd_div_search (
    input  wire clk,
    input  wire mode,
    input  wire en_a,
    input  wire en_b,
    input  wire [7:0] in_a,
    input  wire [7:0] in_b,
    output reg  [7:0] gcd,   
    output wire stop
);

    reg [7:0] reg_a; 
    wire [7:0] next_a;
    wire [7:0] next_b;


    wire [7:0] rem_val = (gcd % reg_a);

    assign next_a = mode ? in_a : rem_val;


    assign next_b = mode ? in_b : reg_a;

    assign stop = (reg_a == 8'd0);

    always @(posedge clk) begin
        if (en_a) begin
            reg_a <= next_a;
        end
        if (en_b) begin
            gcd <= next_b;
        end
    end

endmodule