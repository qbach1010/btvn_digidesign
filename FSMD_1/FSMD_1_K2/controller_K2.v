module controller_K2 (
    input start, last, clk, rst_n,
    output reg counter_en, write_en,
    output reg mac_clr, mac_en,
    output reg busy
);
    localparam S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
    reg [1:0] state, next_state;

    always @ (state)
        case (state)
            S0: {counter_en, write_en, mac_clr, mac_en, busy} = 5'b0;
            S1: {counter_en, write_en, mac_clr, mac_en, busy} = 5'b00111;
            S2: {counter_en, write_en, mac_clr, mac_en, busy} = 5'b10011;
            S3: {counter_en, write_en, mac_clr, mac_en, busy} = 5'b01001;
        endcase
    
    always @ (state, start, last)
        case (state)
            S0: next_state = start ? S1 : S0;
            S1: next_state = S2;
            S2: next_state = last ? S3 : S2;
            S3: next_state = S0;
        endcase
    
    always @ (posedge clk)
        if (!rst_n) state <= S0;
        else state <= next_state;
endmodule