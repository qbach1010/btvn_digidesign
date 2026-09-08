module k2_FSM(
	input start,
	input last,
	input rst_n,
	input clk,
	output reg mac_clr,
	output reg mac_en,
	output reg write_en,
	output reg counter_en,
	output reg busy);
	
	//state encoding
	localparam IDLE = 2'b00;
	localparam START = 2'b01;
	localparam CAL = 2'b10;
	localparam WRITE = 2'b11;
	
	reg [1:0] state;
	
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
                if (last == 1'b1) begin
                    next_state = WRITE;
                end
            end
            
            WRITE: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end

    always @(*) begin
		//default = IDLE
        counter_en = 1'b0;
        mac_en     = 1'b0;
        mac_clr    = 1'b0;
        write_en   = 1'b0;
        busy       = 1'b0;

        case (current_state)
            IDLE: begin
				
            end
            
            START: begin
                mac_en  = 1'b1;
                mac_clr = 1'b1;
                busy    = 1'b1;
            end
            
            CAL: begin
                counter_en = 1'b1;
                mac_en     = 1'b1;
                mac_clr    = 1'b0;
                busy       = 1'b1;
            end
            
            WRITE: begin
                write_en = 1'b1;
                busy     = 1'b1;
            end
				
        endcase
    end
	
endmodule