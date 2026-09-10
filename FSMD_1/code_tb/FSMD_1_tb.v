`timescale 1ns / 1ps

module FSMD_1_tb();
    parameter N = 64;   // num of words in SRAM A, B
    parameter B = 4;    // num of Banks
    parameter M = 16;   // size of each A[i] (bits)

    reg clk;
    reg rst_n;
    reg start;
    wire busy_k2, busy_k3, busy_k4;

    FSMD_1_K2 #(.N(N), .M(M)) dut_k2 (
        .clk(clk), .rst_n(rst_n), 
        .start(start), .busy(busy_k2)
    );

    FSMD_1_K3 #(.N(N), .B(B), .M(M)) dut_k3 (
        .clk(clk), .rst_n(rst_n), 
        .start(start), .busy(busy_k3)
    );

    FSMD_1_K4 #(.N(N), .M(M)) dut_k4 (
        .clk(clk), .rst_n(rst_n), 
        .start(start), .busy(busy_k4)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    integer file, r, i;
    integer test_idx = 0;
    integer fail_k2 = 0;
    integer fail_k3 = 0;
    integer fail_k4 = 0;

    // num of cycles need to complete computing
    integer cycle_k2 = 0;
    integer cycle_k3 = 0;
    integer cycle_k4 = 0;

    // count until busy = 0
    always @(posedge clk) begin
        if (busy_k2) cycle_k2 = cycle_k2 + 1;
        if (busy_k3) cycle_k3 = cycle_k3 + 1;
        if (busy_k4) cycle_k4 = cycle_k4 + 1;
    end
    
    integer temp_val;                      // temp value read from file
    reg signed [37:0] expected_out;        // golden output read from file
    reg signed [37:0] actual_k2, actual_k3, actual_k4; // actual output by K2, K3, K4

    initial begin
        clk = 0;
        start = 0;
        rst_n = 0;
        #50 rst_n = 1;

        file = $fopen("dot_product_data.txt", "r");
        if (file == 0) begin
            $display("ERROR: Can not open dot_product_data.txt");
            $stop;
        end

        $display("========================================================");
        $display("START TESTING (FSMD K2, K3, K4)");
        $display("========================================================");

        // read data from file and coumputing
        begin : read_loop
            while (1) begin

                // read the first value in file (A[0])
                r = $fscanf(file, "%d", temp_val);
                if (r <= 0) disable read_loop;
                dut_k2.sram_A.sram[0] = temp_val;
                dut_k3.sram_A.sram[0] = temp_val;
                dut_k4.sram_A.sram[0] = temp_val;

                // read all next values of vector A
                for (i = 1; i < N; i = i + 1) begin
                    $fscanf(file, "%d", temp_val);
                    dut_k2.sram_A.sram[i] = temp_val;
                    dut_k3.sram_A.sram[i] = temp_val;
                    dut_k4.sram_A.sram[i] = temp_val;
                end

                // read all vector B
                for (i = 0; i < N; i = i + 1) begin
                    $fscanf(file, "%d", temp_val);
                    dut_k2.sram_B.sram[i] = temp_val;
                    dut_k3.sram_B.sram[i] = temp_val;
                    dut_k4.sram_B.sram[i] = temp_val;
                end

                // read golden output
                $fscanf(file, "%d", expected_out);
                
                // index of this testing scenario to display (start from 1 so plus 1)
                test_idx = test_idx + 1;

                // reset before running
                // these values must remain unchanged during diff test_idx in each architecture K2, K3, K4
                cycle_k2 = 0;
                cycle_k3 = 0;
                cycle_k4 = 0;

                // let the circuits run
                @(negedge clk);
                start = 1;
                @(negedge clk);
                start = 0;

                // wait for complete computing
                wait(busy_k2 == 0 && busy_k3 == 0 && busy_k4 == 0);
                #50;

                actual_k2 = $signed(dut_k2.ram_y.word);
                actual_k3 = $signed(dut_k3.ram_y.word);
                actual_k4 = $signed(dut_k4.ram_y.word);

                if (actual_k2 !== expected_out) begin
                    $display("[FAIL K2] Test %0d: Expected = %0d | Got = %0d", test_idx, expected_out, actual_k2);
                    fail_k2 = fail_k2 + 1;
                end

                if (actual_k3 !== expected_out) begin
                    $display("[FAIL K3] Test %0d: Expected = %0d | Got = %0d", test_idx, expected_out, actual_k3);
                    fail_k3 = fail_k3 + 1;
                end
                
                if (actual_k4 !== expected_out) begin
                    $display("[FAIL K4] Test %0d: Expected = %0d | Got = %0d", test_idx, expected_out, actual_k4);
                    fail_k4 = fail_k4 + 1;
                end
            end
        end

        $fclose(file);

        // FINAL RESULT
        $display("\n========================================================");
        $display("TEST SUMMARY (Total Tests: %0d)", test_idx);
        
        if (fail_k2 == 0) $display(" - K2 : PASS ALL %d cases <<<", test_idx);
        else              $display(" - K2 : FAIL (%0d errors) <<<", fail_k2);

        if (fail_k3 == 0) $display(" - K3 : PASS ALL %d cases <<<", test_idx);
        else              $display(" - K3 : FAIL (%0d errors) <<<", fail_k3);

        if (fail_k4 == 0) $display(" - K4 : PASS ALL %d cases <<<", test_idx);
        else              $display(" - K4 : FAIL (%0d errors) <<<", fail_k4);

        $display("========================================================");

        $display("\nPERFORMANCE REPORT (CYCLES/VECTOR)");
        // plus 1 for the last cycle to wirte acc to RAM Y
        $display(" - K2 (Sequential) : %0d cycles", cycle_k2 + 1);
        $display(" - K3 (Parallel)   : %0d cycles", cycle_k3 + 1);
        $display(" - K4 (Pipeline)   : %0d cycles\n", cycle_k4 + 1);

        $display("========================================================");
        $stop;
    end
endmodule