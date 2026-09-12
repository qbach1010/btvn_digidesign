module controller_P2 (
    input clk, rst_n, start, last_row,
    output reg counter_en, write_en, mac_en, busy
);
    localparam S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
    reg [1:0] state, next_state;

    always @(*) begin
        case(state)
            S0: {counter_en, mac_en, write_en, busy} = 4'b0000;
            S1: {counter_en, mac_en, write_en, busy} = 4'b1101;
            S2: {counter_en, mac_en, write_en, busy} = 4'b1111;
            S3: {counter_en, mac_en, write_en, busy} = 4'b1011;
        endcase
    end

    always @(*) begin
        case(state)
            S0: next_state = start ? S1 : S0;
            S1: next_state = S2;
            S2: next_state = last_row ? S3 : S2;
            S3: next_state = S0;
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n) state <= S0;
        else state <= next_state;
    end
endmodule