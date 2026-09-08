module gcd_fsm(
	input clk,
	input rst_n,
	input start,
	input equal,
	input greater,
	output reg en_a,
	output reg en_b,
	output reg mode,
	output reg done);
	
	localparam IDLE = 2'b00;
	localparam START = 2'b01;
	localparam CAL = 2'b10;
	localparam DONE = 2'b11;
	
	
	reg [1:0] current_state, next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
	 always @(*) begin
        next_state = current_state; 

        case (current_state)
            IDLE: begin
                if (start == 1'b1) begin
                    next_state = START;
                end
            end
            
            START: begin
                next_state = CAL; 
            end
            
            CAL: begin
                if (equal == 1'b1) begin
                    next_state = DONE;
                end
            end
            
            DONE: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
	 
	 always @(*) begin
        en_a = 1'b0;
        en_b = 1'b0;
        mode = 1'b0;
        done = 1'b0;

        case (current_state)
            IDLE: begin

            end
            
            START: begin
                en_a = 1'b1;
                en_b = 1'b1;
                mode = 1'b1;
            end
            
            CAL: begin
                en_a = greater;
                en_b = ~greater;
                mode = 1'b0;
            end
            
            DONE: begin
                done = 1'b1;
                en_a = 1'b0;
            end
        endcase
    end
	
	
	
	
endmodule