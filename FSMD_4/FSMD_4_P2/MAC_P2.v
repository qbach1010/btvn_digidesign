module MAC_P2 #(parameter N = 8, SIZE = 16) (
    input clk, rst_n, en,
    input [N*SIZE-1:0] a_vector,
    input [N*SIZE-1:0] x_vector,
    output reg signed [2*SIZE + $clog2(N) - 1 : 0] acc
);
    wire signed [SIZE-1:0] a [N-1:0];
    wire signed [SIZE-1:0] b [N-1:0];
    
    genvar i;
    generate
        for (i=0; i<N; i=i+1) begin : unpack
            assign a[i] = a_vector[i*SIZE +: SIZE];
            assign b[i] = x_vector[i*SIZE +: SIZE];
        end
    endgenerate

    wire signed [2*SIZE-1:0] mul [N-1:0];
    generate
        for (i=0; i<N; i=i+1) begin : mults
            assign mul[i] = a[i] * b[i];
        end
    endgenerate

    wire signed [2*SIZE:0] add1 [3:0];
    assign add1[0] = mul[0] + mul[1];
    assign add1[1] = mul[2] + mul[3];
    assign add1[2] = mul[4] + mul[5];
    assign add1[3] = mul[6] + mul[7];

    wire signed [2*SIZE+1:0] add2 [1:0];
    assign add2[0] = add1[0] + add1[1];
    assign add2[1] = add1[2] + add1[3];

    wire signed [2*SIZE+2:0] add3;
    assign add3 = add2[0] + add2[1];

    always @(posedge clk) begin
        if (!rst_n) acc <= 0;
        else if (en) acc <= add3;
    end
endmodule