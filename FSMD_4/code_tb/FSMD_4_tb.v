`timescale 1ns / 1ps

module FSMD_4_tb();
    parameter M = 8;
    parameter N = 8;
    parameter SIZE = 16;
    parameter W = 35; // 2*SIZE + $clog2(N) = 35 bits

    reg clk;
    reg rst_n;
    reg start;
    
    wire busy_p1, busy_p2;
    wire [M*W-1:0] result_p1, result_p2;

    FSMD_4_P1 #(.M(M), .N(N), .SIZE(SIZE)) dut_p1 (
        .clk(clk), .rst_n(rst_n), 
        .start(start), .busy(busy_p1),
        .result_vector(result_p1)
    );

    FSMD_4_P2 #(.M(M), .N(N), .SIZE(SIZE)) dut_p2 (
        .clk(clk), .rst_n(rst_n), 
        .start(start), .busy(busy_p2),
        .result_vector(result_p2)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    integer file, r, i, j;
    integer test_idx = 0;
    integer fail_p1 = 0;
    integer fail_p2 = 0;
    
    integer cycle_p1 = 0;
    integer cycle_p2 = 0;

    integer temp_val;
    reg signed [37:0] expected_Y [0:M-1];
    reg signed [W-1:0] actual_p1, actual_p2;

    // cycle count
    always @(posedge clk) begin
        if (busy_p1) cycle_p1 = cycle_p1 + 1;
        if (busy_p2) cycle_p2 = cycle_p2 + 1;
    end

    initial begin
        rst_n = 0;
        start = 0;
        #25 rst_n = 1;

        file = $fopen("Mat_vec_mul.txt", "r");
        if (file == 0) begin
            $display("ERROR: Khong the mo file Mat_vec_mul.txt");
            $stop;
        end

        $display("========================================================");
        $display("STARTING MATRIX-VECTOR MULTIPLING TEST (P1 & P2)");
        $display("========================================================");

        begin : read_loop
            while (1) begin
                rst_n = 0;
                #20;
                rst_n = 1;
                #10;
                
                // read data from txt
                r = $fscanf(file, "%d", temp_val);
                if (r <= 0) disable read_loop; 
                dut_p1.sram_A.sram[0] = temp_val;
                dut_p2.sram_A.sram[0][0*SIZE +: SIZE] = temp_val;

                // A matrix
                for (i = 0; i < M; i = i + 1) begin
                    for (j = (i==0 ? 1 : 0); j < N; j = j + 1) begin
                        $fscanf(file, "%d", temp_val);
                        dut_p1.sram_A.sram[i*N + j] = temp_val;
                        dut_p2.sram_A.sram[j][i*SIZE +: SIZE] = temp_val;
                    end
                end

                // X vector
                for (j = 0; j < N; j = j + 1) begin
                    $fscanf(file, "%d", temp_val);
                    dut_p1.sram_x.sram[j] = temp_val;
                    dut_p2.sram_x.sram_x[j*SIZE +: SIZE] = temp_val;
                end

                // Y output vector
                for (i = 0; i < M; i = i + 1) begin
                    $fscanf(file, "%d", expected_Y[i]);
                end

                test_idx = test_idx + 1;
                cycle_p1 = 0;
                cycle_p2 = 0;

                // start running
                @(negedge clk);
                start = 1;
                @(negedge clk);
                start = 0;
                wait(busy_p1 == 0 && busy_p2 == 0);
                #50;

                // Compare output
                for (i = 0; i < M; i = i + 1) begin
                    actual_p1 = $signed(result_p1[i*W +: W]);
                    actual_p2 = $signed(result_p2[i*W +: W]);

                    if (actual_p1 !== expected_Y[i]) begin
                        $display("[FAIL P1] Test %0d, Row %0d: Expected = %0d | Got = %0d", test_idx, i, expected_Y[i], actual_p1);
                        fail_p1 = fail_p1 + 1;
                    end
                    if (actual_p2 !== expected_Y[i]) begin
                        $display("[FAIL P2] Test %0d, Row %0d: Expected = %0d | Got = %0d", test_idx, i, expected_Y[i], actual_p2);
                        fail_p2 = fail_p2 + 1;
                    end
                end
            end
        end

        $fclose(file);

        $display("\n========================================================");
        $display("TEST SUMMARY (Total Test Cases: %0d)", test_idx);
        
        if (fail_p1 == 0) $display(" - P1: PASS ALL");
        else              $display(" - P1: FAIL (%0d elements)", fail_p1);

        if (fail_p2 == 0) $display(" - P2: PASS ALL");
        else              $display(" - P2: FAIL (%0d elements)", fail_p2);
        $display("========================================================");

        $display("\nPERFORMANCE REPORT (CYCLES/MATRIX)");
        $display(" - P1 (Sequential 2D) : %0d cycles", cycle_p1 + 1);
        $display(" - P2 (Adder Tree)    : %0d cycles\n", cycle_p2 + 1);

        $stop;
    end
endmodule