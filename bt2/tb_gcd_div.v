`timescale 1ns/1ps

module tb_gcd_div();

    // Declare signals connected to the DUT
    reg clk;
    reg rst_n;
    reg start;
    reg [7:0] in_a;
    reg [7:0] in_b;
    wire done;
    wire [7:0] gcd_out;

    // Variables used for file operations and validation
    integer file;
    integer scan_count;
    reg [7:0] expected_gcd;
    integer test_passed = 0;
    integer test_failed = 0;

    // Variables used for cycle measurement
    integer current_cycles;
    integer max_cycles = 0;
    integer total_cycles = 0;
    real average_cycles;

    // Instantiate the DUT (using the gcd_div_find module written previously)
    gcd_div_find dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .in_a(in_a),
        .in_b(in_b),
        .done(done),
        .gcd(gcd_out)
    );

    // Generate a 10ns clock cycle
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Testbench scenario (Read file, verify, and measure cycles)
    initial begin
        // 1. Initial system reset
        rst_n = 0;
        start = 0;
        in_a = 0;
        in_b = 0;
        #20;
        rst_n = 1;
        #10;

        // 2. Open the data file (Ensure the txt file is in the simulation directory)
        file = $fopen("gcd_uint8_data.txt", "r");
        if (file == 0) begin
            $display("ERROR: Cannot open gcd_uint8_data.txt");
            $finish;
        end

        $display("Starting GCD Verification and Cycle Measurement...");

        // 3. Read line by line until End of File (EOF)
        while (!$feof(file)) begin
            // Read 3 decimal numbers (%d) on a single line
            scan_count = $fscanf(file, "%d %d %d\n", in_a, in_b, expected_gcd);

            // If exactly 3 values were read, feed them to the circuit
            if (scan_count == 3) begin
                
                // Assert start pulse for 1 clock cycle
                @(posedge clk);
                start = 1;
                @(posedge clk);
                start = 0;

                // Reset the cycle counter for this specific calculation
                current_cycles = 0;

                // Wait until the done flag is asserted, counting every clock edge
                while (done == 0) begin
                    @(posedge clk);
                    current_cycles = current_cycles + 1;
                end
                
                // Align to the clock edge before checking the result
                @(posedge clk); 

                // Update performance metrics
                if (current_cycles > max_cycles) begin
                    max_cycles = current_cycles;
                end
                total_cycles = total_cycles + current_cycles;

                // Compare the calculated result with the expected result from the txt file
                if (gcd_out !== expected_gcd) begin
                    $display("FAILED: GCD(%d, %d) | Calculated: %d | Expected: %d", 
                             in_a, in_b, gcd_out, expected_gcd);
                    test_failed = test_failed + 1;
                end else begin
                    test_passed = test_passed + 1;
                end
            end
        end

        // 4. Close the file and report the summary
        $fclose(file);

        // Calculate average cycles. We multiply by 1.0 to force floating-point (real) division.
        average_cycles = total_cycles / ((test_passed + test_failed) * 1.0);

        $display("========================================");
        $display("SIMULATION SUMMARY:");
        $display("PASSED cases  : %d", test_passed);
        $display("FAILED cases  : %d", test_failed);
        $display("----------------------------------------");
        $display("PERFORMANCE METRICS:");
        $display("Worst-case    : %d clock cycles", max_cycles);
        $display("Average cycles: %f clock cycles", average_cycles);
        $display("========================================");
        
        $finish;
    end

endmodule
