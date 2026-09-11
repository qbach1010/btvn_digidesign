`timescale 1ns / 1ps

module tb_fir;

    parameter WIDTH = 16;

    // Interface signals
    reg clk;
    reg rst_n;
    reg signed [WIDTH-1:0] x;
    reg signed [8*WIDTH-1:0] h_packed;
    
    wire signed [2*WIDTH+3:0] y_direct;
    wire signed [2*WIDTH+3:0] y_transpose;

    // Reverse coefficients for FIR Transpose to ensure mathematical equivalence
    wire signed [8*WIDTH-1:0] h_packed_trans;
    genvar k;
    generate
        for (k = 0; k < 8; k = k + 1) begin : reverse_h
            assign h_packed_trans[k*WIDTH +: WIDTH] = h_packed[(7-k)*WIDTH +: WIDTH];
        end
    endgenerate

    // Instantiate DUT 1: Direct Form
    fir_direct_form #(WIDTH) u_direct (
        .clk(clk),
        .rst_n(rst_n),
        .x(x),
        .h_packed(h_packed),
        .y(y_direct)
    );

    // Instantiate DUT 2: Transpose Form
    fir_transpose_form #(WIDTH) u_transpose (
        .clk(clk),
        .rst_n(rst_n),
        .x(x),
        .h_packed(h_packed_trans),
        .y(y_transpose)
    );

    // Clock generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // File I/O and processing variables
    integer file_in;
    integer scan_count;
    integer test_cases = 0;
    integer match_count = 0;
    integer mismatch_count = 0;
    integer i;

    reg signed [WIDTH-1:0] x_in [0:7];
    reg signed [WIDTH-1:0] h_in [0:7];
    reg signed [2*WIDTH+3:0] golden_y;

// Main Test Process
    initial begin
        // 1. Open the data file
        file_in = $fopen("fir_data.txt", "r");
        if (file_in == 0) begin
            $display("ERROR: Could not open fir_data.txt");
            $stop;
        end

        // 2. Initialize signals and reset
        rst_n = 0;
        x = 0;
        h_packed = 0;
        
        // Hold reset for a few cycles
        #25; 
        rst_n = 1;

        $display("---------------------------------------------------");
        $display("Starting FIR tests using 'fir_data.txt'...");
        $display("---------------------------------------------------");

        // 3. Read and process the file dynamically
        // --- ADDED NAMED BLOCK HERE ---
        begin : READ_LOOP 
            while (!$feof(file_in)) begin
                // Read 8 x inputs
                scan_count = $fscanf(file_in, "%d %d %d %d %d %d %d %d", 
                    x_in[0], x_in[1], x_in[2], x_in[3], x_in[4], x_in[5], x_in[6], x_in[7]);
                
                // Break if end of file is reached or an empty line is parsed
                // --- REPLACED 'break' WITH 'disable READ_LOOP' ---
                if (scan_count != 8) disable READ_LOOP; 

                // Read 8 h coefficients
                scan_count = $fscanf(file_in, "%d %d %d %d %d %d %d %d", 
                    h_in[0], h_in[1], h_in[2], h_in[3], h_in[4], h_in[5], h_in[6], h_in[7]);
                if (scan_count != 8) begin
                    $display("ERROR: Incomplete h values at test %0d", test_cases + 1);
                    disable READ_LOOP; // Acts as a break
                end

                // Read golden y output
                scan_count = $fscanf(file_in, "%d", golden_y);
                if (scan_count != 1) begin
                    $display("ERROR: Missing golden y value at test %0d", test_cases + 1);
                    disable READ_LOOP; // Acts as a break
                end

                test_cases = test_cases + 1;

                // Pack the h array into the flattened h_packed signal
                for (i = 0; i < 8; i = i + 1) begin
                    h_packed[i*WIDTH +: WIDTH] = h_in[i];
                end

                // Inject the 8 x samples sequentially.
                // x_in[7] must go in first so that x_in[0] lands in x_temp[0] at the end.
                for (i = 7; i >= 0; i = i - 1) begin
                    @(negedge clk);
                    x = x_in[i];
                end

                // Wait 2 positive edges for the pipeline shift and sum processing to complete
                @(posedge clk); 
                @(posedge clk); 
                
                // Short delay to capture the stable result safely after the clock edge
                #1; 

                // 4. Compare outputs
                if ((y_direct !== golden_y) || (y_transpose !== golden_y)) begin
                    $display("[TEST %0d FAILED]", test_cases);
                    $display("  Expected : %0d", golden_y);
                    $display("  Direct   : %0d", y_direct);
                    $display("  Transpose: %0d", y_transpose);
                    mismatch_count = mismatch_count + 1;
                end else begin
                    match_count = match_count + 1;
                end
            end
        end // END OF READ_LOOP BLOCK

        $fclose(file_in);

        // 5. Print final test summary
        $display("---------------------------------------------------");
        $display("TEST SUMMARY:");
        $display("Total test cases : %0d", test_cases);
        $display("Matched          : %0d", match_count);
        $display("Mismatched       : %0d", mismatch_count);
        
        if (mismatch_count == 0 && test_cases > 0)
            $display("=> SUCCESS! Both FIR forms exactly match the golden outputs.");
        else
            $display("=> FAILED! Check the mismatch logs above.");
        $display("---------------------------------------------------");
        
        $stop;
    end

endmodule
