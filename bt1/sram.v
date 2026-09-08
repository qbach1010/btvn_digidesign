module sram #(
    parameter DATA_WIDTH = 16,     
    parameter ADDR_WIDTH = 10      
)(
    input  wire                  cs_n, 
    input  wire                  we_n, 
    input  wire                  oe_n, 
    input  wire [ADDR_WIDTH-1:0] addr, 
    inout  wire [DATA_WIDTH-1:0] data  
);

    reg [DATA_WIDTH-1:0] mem_array [0:(1<<ADDR_WIDTH)-1];
	 
	 //Chip Select =0, Write Enable = 1 => write

    always @(cs_n,we_n,mem_array) begin
        if (!cs_n && !we_n) begin
            mem_array[addr] = data; 
        end
    end
	 
	 //Chip Select = 0, Output Enable = 0, Write Enable = 1 => read

    assign data = (!cs_n && !oe_n && we_n) ? mem_array[addr] : {DATA_WIDTH{1'bz}};

endmodule