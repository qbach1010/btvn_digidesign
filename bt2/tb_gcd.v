`timescale 1ns/1ps

module tb_gcd();

    // Declare signals connected to the DUT
    reg clk;
    reg rst_n;
    reg start;
    reg [7:0] in_a;
    reg [7:0] in_b;
    wire done;
    wire [7:0] gcd_out;

    // Variables used for file operations
    integer file;
    integer scan_count;
    reg [7:0] expected_gcd;
    integer test_passed = 0;
    integer test_failed = 0;

    // Instantiate the DUT (using the gcd_top module written previously)
    gcd_find dut (
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

    // Testbench scenario (Read file and verify)
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

        $display("Starting GCD Verification Testbench...");

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

                // Wait until the done flag is asserted by the FSM
                wait(done == 1);
                
                // Align to the clock edge before checking the result
                @(posedge clk); 

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
        $display("========================================");
        $display("SIMULATION SUMMARY:");
        $display("PASSED cases: %d", test_passed);
        $display("FAILED cases: %d", test_failed);
        $display("========================================");
        $finish;
    end

endmodule
